% Test for FFI C string with invalid UTF-8
% This test verifies that read_ptr(cstr, ...) handles invalid UTF-8 gracefully
% See: https://github.com/mthom/scryer-prolog/issues/XXXX

:- use_module(library(ffi)).
:- initialization(test).

test :-
    % Load the test library
    use_foreign_module(LIB, [
        'get_invalid_utf8'([], cstr),
        'get_hex_json'([], cstr)
    ]),
    
    % Test 1: Invalid UTF-8 should not panic
    % Before fix: panics with Utf8Error
    % After fix: returns string with valid prefix or replacement char
    ffi:'get_invalid_utf8'([], InvalidUTF8),
    
    % Should be able to check if it's an atom (not crash)
    atom(InvalidUTF8),
    
    % Should contain the valid prefix
    atom_codes(InvalidUTF8, Codes),
    Codes = [86, 97, 108, 105, 100, 32, 85, 84, 70, 45, 56, 32, 116, 101, 120, 116|_],
    write('Valid UTF-8 text'),
    write(','),
    
    % Test 2: Valid UTF-8 (hex JSON) should work normally  
    ffi:'get_hex_json'([], HexJSON),
    atom(HexJSON),
    sub_atom(HexJSON, _, _, _, 'hash'),
    sub_atom(HexJSON, _, _, _, 'c24463f5'),
    write('hex_ok'),
    nl,
    
    halt.

test :-
    write('Test failed'),
    nl,
    halt(1).
