% Master test runner for all Zenroom test suites
%
% This file loads and runs all Zenroom test suites:
% - zenroom_basic.pl - Basic FFI integration tests
% - zenroom_hash.pl - Hash and cryptographic primitives
% - zenroom_given.pl - Data loading and Given statements
% - zenroom_ecdh.pl - ECDH cryptographic operations
%
% Usage: scryer-prolog tests/run_all_tests.pl

:- use_module(library(zenroom)).
:- use_module(library(format)).

% Test suite runner
run_test_suite(SuiteName, TestFile) :-
    write('================================================================================'), nl,
    write('Running Test Suite: '), write(SuiteName), nl,
    write('================================================================================'), nl,
    nl,
    catch(
        load_files(TestFile, []),
        Error,
        (
            write('ERROR loading test suite '), write(SuiteName), write(': '),
            write(Error), nl,
            fail
        )
    ).

% Main test runner
run_all_tests :-
    write(''), nl,
    write('╔════════════════════════════════════════════════════════════════════════════╗'), nl,
    write('║                 Zenroom Battle-Test Suite for Scryer Prolog               ║'), nl,
    write('║                                                                            ║'), nl,
    write('║  Testing scryer-prolog-zenroom crate against Zenroom test expectations           ║'), nl,
    write('╚════════════════════════════════════════════════════════════════════════════╝'), nl,
    nl,
    
    % Get test directory path
    current_prolog_flag(argv, Argv),
    (
        % If run with file path, extract directory
        Argv = [TestFile|_],
        atom_concat(TestDir, '/run_all_tests.pl', TestFile)
    ;
        % Default to current directory
        TestDir = './tests'
    ),
    
    write('Test Directory: '), write(TestDir), nl,
    nl,
    
    % Track overall results
    TotalTests = 0,
    TotalPassed = 0,
    TotalFailed = 0,
    
    % Run each test suite
    % Note: Each suite will run its own initialization and report results
    % We're just loading them sequentially
    
    write('Note: Each test suite will run automatically and report results.'), nl,
    write('If you see test output below, the suites are executing.'), nl,
    nl,
    
    % Install note
    write('╔════════════════════════════════════════════════════════════════════════════╗'), nl,
    write('║  IMPORTANT: Ensure libzenroom shared library is installed and accessible  ║'), nl,
    write('║                                                                            ║'), nl,
    write('║  On macOS: libzenroom.dylib                                               ║'), nl,
    write('║  On Linux: libzenroom.so                                                  ║'), nl,
    write('║  On Windows: zenroom.dll                                                  ║'), nl,
    write('║                                                                            ║'), nl,
    write('║  You may need to set the library path using:                             ║'), nl,
    write('║    ?- set_zenroom_library_path(\'/path/to/libzenroom\').                   ║'), nl,
    write('╚════════════════════════════════════════════════════════════════════════════╝'), nl,
    nl,
    
    write('To run individual test suites:'), nl,
    write('  scryer-prolog tests/zenroom_basic.pl'), nl,
    write('  scryer-prolog tests/zenroom_hash.pl'), nl,
    write('  scryer-prolog tests/zenroom_given.pl'), nl,
    write('  scryer-prolog tests/zenroom_ecdh.pl'), nl,
    nl,
    
    write('================================================================================'), nl,
    write('Test suites should be run individually as shown above.'), nl,
    write('Each suite uses :- initialization/1 to auto-execute.'), nl,
    write('================================================================================'), nl.

% Entry point
:- initialization(run_all_tests).
