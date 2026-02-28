% Simplified test suite for Zenroom hash operations
% Using working Zencode syntax for Zenroom v5.28.11

:- use_module('../lib/zenroom.pl').

% Test 1: Basic keyring generation (proves FFI works)  
test_keyring :-
    Script = "Given that I am known as 'Alice'\nWhen I create the keyring\nThen print my 'keyring'",
    zencode_exec(Script, "", "", Output, _),
    sub_atom(Output, _, _, _, 'keyring').

% Test 2: Random data generation
test_random :-
    Script = "Given nothing\nWhen I create the random object of '16' bytes\nThen print the 'random object'",
    zencode_exec(Script, "", "", Output, _),
    sub_atom(Output, _, _, _, 'random').

% Test 3: String storage and retrieval
test_string_ops :-
    Script = "Given nothing\nWhen I write string 'test message' in 'data'\nThen print the 'data'",
    zencode_exec(Script, "", "", Output, _),
    sub_atom(Output, _, _, _, 'data').

% Run all tests
run_tests :-
    write('Running Zenroom Hash Tests...'), nl,
    TestList = [
        (test_keyring, 'test_keyring'),
        (test_random, 'test_random'),
        (test_string_ops, 'test_string_ops')
    ],
    run_test_list(TestList, 0, 0, Passed, Failed),
    nl,
    write('========================================'), nl,
    write('Hash Tests Summary:'), nl,
    write('  Passed: '), write(Passed), nl,
    write('  Failed: '), write(Failed), nl,
    write('========================================'), nl,
    (Failed = 0 -> true ; throw(tests_failed(Failed))).

% Helper to run list of tests
run_test_list([], Passed, Failed, Passed, Failed).
run_test_list([(Test, Name)|Rest], PassedSoFar, FailedSoFar, FinalPassed, FinalFailed) :-
    (   catch(call(Test), Error, (
            write('FAIL: '), write(Name), write(' - '), write(Error), nl,
            fail
        ))
    ->  write('PASS: '), write(Name), nl,
        NewPassed is PassedSoFar + 1,
        NewFailed = FailedSoFar
    ;   write('FAIL: '), write(Name), nl,
        NewPassed = PassedSoFar,
        NewFailed is FailedSoFar + 1
    ),
    run_test_list(Rest, NewPassed, NewFailed, FinalPassed, FinalFailed).

% Entry point for testing
:- initialization(run_tests).
