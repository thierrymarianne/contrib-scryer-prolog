:- module(zenroom, [
    zencode_exec/5,
    zenroom_exec/5,
    set_zenroom_library_path/1
]).

/** <module> Zenroom Integration for Scryer Prolog

This module provides a high-level interface to Zenroom, a secure execution
environment for cryptographic operations and smart contracts.

Zenroom executes scripts written in Zencode (a human-readable DSL) or Lua,
providing cryptographic primitives, verifiable computing, and secure data processing.

## Quick Start

First, ensure the Zenroom shared library is available:

```prolog
?- set_zenroom_library_path('./libzenroom.so').
```

Then execute Zencode scripts:

```prolog
?- zencode_exec(
     "Given nothing\nThen print the 'string' 'Hello Zenroom!'",
     "", "", Output, Errors).
Output = "{\"output\":[\"Hello_Zenroom!\"]}",
Errors = "".
```

## Requirements

- Zenroom shared library (libzenroom.so, libzenroom.dylib, or zenroom.dll)
- Build from: https://github.com/dyne/Zenroom

@author Thierry Marianne
@license BSD-3-Clause (same as Scryer Prolog)
@see https://github.com/dyne/Zenroom
@see https://dev.zenroom.org
*/

:- use_module('zenroom_ffi.pl').
:- use_module(library(error)).
:- use_module(library(charsio)).

%% zencode_exec(+Script, +Keys, +Data, -Output, -Errors)
%
% Execute a Zencode script with keys and data.
%
% Zencode is a domain-specific language for cryptographic operations.
% Scripts are written in a human-readable format and compiled/executed by Zenroom.
%
% @param Script The Zencode script to execute (atom, string, or char list)
% @param Keys JSON string containing cryptographic keys (use "" for none)
% @param Data JSON string containing input data (use "" for none)
% @param Output JSON string containing execution output
% @param Errors String containing error messages and logs
%
% @throws error(zenroom_library_not_found, _) if Zenroom library cannot be loaded
% @throws error(zenroom_execution_failed(RetCode), _) if execution fails
% @throws error(type_error(text, Input), _) if inputs are not text
%
% ## Examples
%
% Simple output:
% ```prolog
% ?- zencode_exec(
%      "Given nothing\nThen print the 'string' 'test'",
%      "", "", Output, _).
% ```
%
% Create ECDH keypair:
% ```prolog
% ?- zencode_exec(
%      "Scenario 'ecdh': Create keypair\n\
%       Given that I am known as 'Alice'\n\
%       When I create the ecdh key\n\
%       Then print my 'keyring'",
%      "", "", Output, _).
% ```
%
% Process data:
% ```prolog
% ?- zencode_exec(
%      "Given I have a 'string' named 'message'\n\
%       Then print the 'message'",
%      "",
%      "{\"message\":\"Hello World\"}",
%      Output, _).
% ```
zencode_exec(Script, Keys, Data, Output, Errors) :-
    must_be_text(Script, zencode_exec/5),
    must_be_text(Keys, zencode_exec/5),
    must_be_text(Data, zencode_exec/5),
    ffi_zencode_exec(Script, Keys, Data, Output, Errors).

%% zenroom_exec(+Script, +Keys, +Data, -Output, -Errors)
%
% Execute a Lua script in the Zenroom environment.
%
% This allows executing arbitrary Lua code within Zenroom's secure environment,
% with access to Zenroom's cryptographic libraries.
%
% @param Script Lua script to execute
% @param Keys JSON keys (use "" for none)
% @param Data JSON data (use "" for none)
% @param Output Execution output
% @param Errors Error messages and logs
%
% ## Example
%
% ```prolog
% ?- zenroom_exec(
%      "print('Hello from Lua in Zenroom')",
%      "", "", Output, _).
% ```
zenroom_exec(Script, Keys, Data, Output, Errors) :-
    must_be_text(Script, zenroom_exec/5),
    must_be_text(Keys, zenroom_exec/5),
    must_be_text(Data, zenroom_exec/5),
    ffi_zenroom_exec(Script, Keys, Data, Output, Errors).

%% set_zenroom_library_path(+Path)
%
% Set the path to the Zenroom shared library.
%
% This must be called before executing any Zenroom scripts if the library
% is not in a standard location.
%
% @param Path Absolute or relative path to libzenroom.so/.dylib/.dll
%
% ## Example
%
% ```prolog
% ?- set_zenroom_library_path('/usr/local/lib/libzenroom.so').
% ```
set_zenroom_library_path(Path) :-
    must_be(atom, Path),
    zenroom_ffi:set_zenroom_library_path(Path).

%% must_be_text(+Input, +Context)
%
% Validate that Input is a text type (atom or char list)
% In Scryer Prolog, strings are character lists
must_be_text(Input, _Context) :-
    (atom(Input) ; is_char_list(Input)),
    !.
must_be_text(Input, Context) :-
    throw(error(type_error(text, Input), Context)).

%% is_char_list(+Input)
%
% Check if Input is a list of characters
is_char_list([]) :- !.
is_char_list([H|T]) :-
    atom(H),
    atom_length(H, 1),
    is_char_list(T).
