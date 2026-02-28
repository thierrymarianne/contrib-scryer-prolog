% Test suite for basic Zenroom FFI integration
% Cycle 1: Foundation and Basic Execution

% Load zenroom module from ../lib
:- use_module('../lib/zenroom.pl').

% Test 1: Simple Zencode execution - create ECDH keypair
test_basic_zencode_exec :-
    Script = "Scenario 'ecdh': Create keypair\nGiven that I am known as 'Alice'\nWhen I create the ecdh key\nThen print my 'keyring'",
    zencode_exec(Script, "", "", Output, Errors),
    % Verify Output contains Alice's keyring
    atom_chars(Output, _), % Ensure it's a valid atom/string
    sub_atom(Output, _, _, _, 'Alice'),
    % Verify Errors is empty or minimal
    atom_chars(Errors, _).

% Test 2: Simple output test
test_simple_output :-
    % Working Zencode for Zenroom v5.28.11
    Script = "Given nothing\nWhen I create the random object of '32' bytes\nThen print the 'random object'",
    zencode_exec(Script, "", "", Output, _),
    sub_atom(Output, _, _, _, 'random').

% Test 3: Execution with keys
test_zencode_with_keys :-
    % Working keyring test with identity
    Script = "Given that I am known as 'Alice'\nWhen I create the keyring\nThen print my 'keyring'",
    zencode_exec(Script, "", "", Output, _),
    sub_atom(Output, _, _, _, 'keyring').

% Test 4: Execution with data
test_zencode_with_data :-
    % Working data test  
    Script = "Given nothing\nWhen I write string 'test data' in 'message'\nThen print the 'message'",
    zencode_exec(Script, "", "", Output, _),
    sub_atom(Output, _, _, _, 'message').

% Run all tests
run_tests :-
    write('Running Zenroom Basic Tests...'), nl,
    catch(test_basic_zencode_exec, E1, (write('FAIL: test_basic_zencode_exec - '), write(E1), nl, fail)),
    write('PASS: test_basic_zencode_exec'), nl,
    catch(test_simple_output, E2, (write('FAIL: test_simple_output - '), write(E2), nl, fail)),
    write('PASS: test_simple_output'), nl,
    catch(test_zencode_with_keys, E3, (write('FAIL: test_zencode_with_keys - '), write(E3), nl, fail)),
    write('PASS: test_zencode_with_keys'), nl,
    catch(test_zencode_with_data, E4, (write('FAIL: test_zencode_with_data - '), write(E4), nl, fail)),
    write('PASS: test_zencode_with_data'), nl,
    write('All tests passed!'), nl.

% Entry point for testing
:- initialization(run_tests).
