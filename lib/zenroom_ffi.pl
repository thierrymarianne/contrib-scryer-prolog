:- module(zenroom_ffi, [
    ffi_zencode_exec/5,
    ffi_zenroom_exec/5
]).

/** <module> Zenroom FFI Low-Level Bindings

This module provides low-level FFI bindings to the Zenroom C API.
It handles direct interaction with the Zenroom shared library.

@author Thierry Marianne
@license BSD-3-Clause (same as Scryer Prolog)
@see https://github.com/dyne/Zenroom
*/

:- use_module(library(ffi)).
:- use_module(library(error)).
:- use_module(library(charsio)).
:- use_module(library(lists)).
:- use_module(library(iso_ext)).

% Configuration: Path to Zenroom shared library
% This should be set by the user via set_zenroom_library_path/1
:- dynamic(zenroom_lib_path/1).

% Default library paths to try
default_lib_paths([
    './libzenroom.so',           % Current directory (Linux)
    './libzenroom.dylib',         % Current directory (macOS)
    './zenroom.dll',              % Current directory (Windows)
    '/usr/local/lib/libzenroom.so',
    '/usr/local/lib/libzenroom.dylib',
    '/usr/lib/libzenroom.so',
    '/opt/homebrew/lib/libzenroom.dylib'
]).

% Buffer sizes for output
% Zenroom can produce large outputs, especially for cryptographic operations
stdout_buffer_size(65536).  % 64KB for stdout
stderr_buffer_size(8192).   % 8KB for stderr/logs

%% load_zenroom_library(-LibPath)
%
% Load the Zenroom shared library, trying various paths
load_zenroom_library(LibPath) :-
    (zenroom_lib_path(UserPath) ->
        LibPath = UserPath
    ;   default_lib_paths(Paths),
        member(LibPath, Paths)
    ),
    % Attempt to load the library with FFI bindings
    use_foreign_module(LibPath, [
        'zencode_exec_tobuf'([cstr, cstr, cstr, cstr, cstr, cstr, ptr, uint64, ptr, uint64], int),
        'zenroom_exec_tobuf'([cstr, cstr, cstr, cstr, cstr, cstr, ptr, uint64, ptr, uint64], int),
        'malloc'([uint64], ptr),
        'free'([ptr], void)
    ]).

%% set_zenroom_library_path(+Path)
%
% Set the path to the Zenroom shared library
% This should be called before using any FFI functions
set_zenroom_library_path(Path) :-
    must_be(atom, Path),
    retractall(zenroom_lib_path(_)),
    assertz(zenroom_lib_path(Path)).

%% ffi_zencode_exec(+Script, +Keys, +Data, -Output, -Errors)
%
% Execute a Zencode script via FFI
% - Script: Zencode script (string/atom)
% - Keys: JSON keys (string/atom)
% - Data: JSON data (string/atom)
% - Output: Stdout output from Zenroom
% - Errors: Stderr output from Zenroom
ffi_zencode_exec(Script, Keys, Data, Output, Errors) :-
    ffi_exec_common('zencode_exec_tobuf', Script, Keys, Data, Output, Errors).

%% ffi_zenroom_exec(+Script, +Keys, +Data, -Output, -Errors)
%
% Execute a Lua script in Zenroom via FFI
ffi_zenroom_exec(Script, Keys, Data, Output, Errors) :-
    ffi_exec_common('zenroom_exec_tobuf', Script, Keys, Data, Output, Errors).

%% ffi_exec_common(+FuncName, +Script, +Keys, +Data, -Output, -Errors)
%
% Common execution logic for both zencode_exec and zenroom_exec
ffi_exec_common(FuncName, Script, Keys, Data, Output, Errors) :-
    % Ensure library is loaded
    catch(
        load_zenroom_library(_),
        E,
        throw(error(zenroom_library_not_found, context(ffi_exec_common/6, E)))
    ),
    
    % Convert inputs to C strings
    to_cstr(Script, ScriptStr),
    to_cstr(Keys, KeysStr),
    to_cstr(Data, DataStr),
    
    % Config, Extra, Context are empty for basic execution
    ConfigStr = "",
    ExtraStr = "",
    ContextStr = "",
    
    % Allocate output buffers
    stdout_buffer_size(StdoutSize),
    stderr_buffer_size(StderrSize),
    
    % Allocate output buffers on HEAP using malloc to avoid stack smashing
    stdout_buffer_size(StdoutSize),
    stderr_buffer_size(StderrSize),
    
    % Allocate first buffer
    ffi:malloc(StdoutSize, StdoutBuf),
    setup_call_cleanup(
        % Allocate second buffer
        ffi:malloc(StderrSize, StderrBuf),
        % Body
        (
            call_zenroom_func(FuncName, ScriptStr, ConfigStr, KeysStr, DataStr, 
                             ExtraStr, ContextStr, StdoutBuf, StdoutSize, 
                             StderrBuf, StderrSize, RetCode),
            
            % Check return code
            check_return_code(RetCode),
            
            % Debug: Print raw buffer pointers
            % write('DEBUG: StdoutBuf: '), write(StdoutBuf), nl,
            % write('DEBUG: StderrBuf: '), write(StderrBuf), nl,

            % Read output buffers safely from heap pointers
            read_ptr(cstr, StdoutBuf, StdoutChars),
            read_ptr(cstr, StderrBuf, StderrChars),
            
            % Debug: Print what we read
            % write('DEBUG: StdoutChars: '), write(StdoutChars), nl,
            % write('DEBUG: StderrChars: '), write(StderrChars), nl,

            % Ensure Chars are instantiated before conversion
            (var(StdoutChars) -> StdoutChars = [] ; true),
            (var(StderrChars) -> StderrChars = [] ; true),

            chars_to_atom(StdoutChars, Output),
            chars_to_atom(StderrChars, ErrAtom),
            % Convert errors if empty
            (ErrAtom == '' -> Errors = '' ; Errors = ErrAtom)
        ),
        % Cleanup: Free both buffers
        (
            ffi:free(StderrBuf),
            ffi:free(StdoutBuf)
        )
    ).

%% call_zenroom_func(+FuncName, +Script, +Config, +Keys, +Data, +Extra, +Context, 
%%                   +StdoutBuf, +StdoutSize, +StderrBuf, +StderrSize, -RetCode)
%
% Call the appropriate Zenroom function
call_zenroom_func('zencode_exec_tobuf', Script, Config, Keys, Data, Extra, Context,
                  StdoutBuf, StdoutSize, StderrBuf, StderrSize, RetCode) :-
    ffi:'zencode_exec_tobuf'(Script, Config, Keys, Data, Extra, Context,
                             StdoutBuf, StdoutSize, StderrBuf, StderrSize, RetCode).

call_zenroom_func('zenroom_exec_tobuf', Script, Config, Keys, Data, Extra, Context,
                  StdoutBuf, StdoutSize, StderrBuf, StderrSize, RetCode) :-
    ffi:'zenroom_exec_tobuf'(Script, Config, Keys, Data, Extra, Context,
                            StdoutBuf, StdoutSize, StderrBuf, StderrSize, RetCode).

%% check_return_code(+RetCode)
%
% Check Zenroom return code (0 = success)
check_return_code(0) :- !.
check_return_code(RetCode) :-
    throw(error(zenroom_execution_failed(RetCode), context(check_return_code/1, 'Zenroom execution returned non-zero exit code'))).

%% to_cstr(+Input, -CStr)
%
% Convert Prolog atom/chars to C string
to_cstr(Input, CStr) :-
    atom(Input),
    !,
    atom_chars(Input, Chars),
    atom_chars(CStr, Chars).
to_cstr([H|T], CStr) :-
    !,
    % It's a list (character list)
    atom_chars(CStr, [H|T]).
to_cstr([], CStr) :-
    !,
    atom_chars(CStr, []).
to_cstr(Input, _) :-
    throw(error(type_error(text, Input), context(to_cstr/2, 'Expected atom or character list'))).

%% chars_to_atom(+Chars, -Atom)
%
% Convert character list to atom (handles both lists and atoms)
chars_to_atom(Chars, Atom) :-
    atom(Chars),
    !,
    Atom = Chars.
chars_to_atom(Chars, Atom) :-
    atom_chars(Atom, Chars).

