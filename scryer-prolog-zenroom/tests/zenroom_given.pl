% Test suite for Zenroom "Given" statements and data loading
% Adapted from _src-zenroom/test/zencode/given.bats

:- use_module('../lib/zenroom.pl').
:- use_module(library(charsio)).

% Helper predicate to check if output contains expected substring
contains_substring(String, Substring) :-
    (atom(Substring) -> SubAtom = Substring ; atom_chars(SubAtom, Substring)),
    sub_atom(String, _, _, _, SubAtom).

% Helper to check if JSON output contains a field with expected value
% Uses simple substring matching (JSON library causes segfault)
check_json_field(Output, Field, ExpectedValue) :-
    (atom(Field) -> F = Field ; atom_chars(F, Field)),
    (atom(ExpectedValue) -> V = ExpectedValue ; atom_chars(V, ExpectedValue)),
    sub_atom(Output, _, _, _, F),
    sub_atom(Output, _, _, _, V).

% Test 1: Given nothing - basic random generation
test_given_nothing :-
    Script = "rule check version 1.0.0\nGiven nothing\nWhen I create the random of '256' bits\nThen print the 'random'",
    zencode_exec(Script, "", "", Output, _),
    % Just verify output contains "random" field (value is deterministic in Zenroom tests)
    contains_substring(Output, "random").

% Test 2: Given I have a 'string' named 'anykey'
test_given_string_named :-
    Script = "rule check version 1.0.0\nrule input encoding string\nrule output encoding string\nGiven I have a 'string' named 'anykey'\nThen print the 'anykey'",
    Data = "{\"anykey\": \"anyvalue\"}",
    zencode_exec(Script, "", Data, Output, _),
    check_json_field(Output, "anykey", "anyvalue").

% Test 3: Given I have a 'hex' named 'anykey' and print as string
test_given_hex_named :-
    Script = "rule check version 1.0.0\nGiven I have a 'hex' named 'anykey'\nThen print the 'anykey' as 'string'",
    Data = "{\"anykey\": \"616e7976616c7565\"}",
    zencode_exec(Script, "", Data, Output, _),
    check_json_field(Output, "anykey", "anyvalue").

% Test 4: Given I have a 'number' named 'myNumber' inside 'myObject'
test_given_number_inside :-
    Script = "rule check version 1.0.0\nGiven I have a 'number' named 'myNumber' inside 'myObject'\nThen print the 'myNumber'",
    Data = "{\"myObject\":{\"myNumber\":1000,\"myString\":\"Hello World!\",\"myArray\":[\"String1\",\"String2\",\"String3\"]}}",
    zencode_exec(Script, "", Data, Output, _),
    check_json_field(Output, "myNumber", "1000").

% Test 5: Given I have a valid arrays and nested data
test_given_valid_arrays :-
    Script = "Given I have a valid 'string array' named 'myArray' in 'myObject'\nGiven I have a valid 'string' named 'myString' in 'myObject'\nGiven I have a valid 'number' named 'myNumber' in 'myObject'\nWhen I randomize the 'myArray' array\nThen print all data",
    Data = "{\"myObject\":{\"myNumber\":1000,\"myString\":\"Hello World!\",\"myArray\":[\"String1\",\"String2\",\"String3\"]}}",
    zencode_exec(Script, "", Data, Output, _),
    contains_substring(Output, "myArray"),
    contains_substring(Output, "myString"),
    contains_substring(Output, "myNumber").

% Test 6: Given I have my 'keyring' (identity-based)
test_given_my_keyring :-
    Script = "rule check version 1.0.0\nscenario 'ecdh'\nGiven I am 'Andrea'\nand I have my 'keyring'\nThen print the 'keyring'",
    Data = "{\"Andrea\":{\"keyring\":{\"ecdh\":\"IIiTD89L6/sbIvaUc5jAVR88ySigaBXppS5GLUjm7Dv2OLKbNIVdiZ48jpLGskKVDPpukKe4R0A=\"}}}",
    zencode_exec(Script, "", Data, Output, _),
    check_json_field(Output, "keyring", "ecdh").

% Test 7: Given I have a 'number' named 'robba' inside 'stuff'
test_given_inside_nested :-
    Script = "rule check version 1.0.0\nscenario 'ecdh'\nGiven I have a 'number' named 'robba' inside 'stuff'\nThen print the 'robba'",
    Data = "{\"stuff\":{\"robba\":\"1000\",\"quantity\":1000,\"peppe\":[\"peppe2\",\"peppe3\",\"peppe4\"]}}",
    zencode_exec(Script, "", Data, Output, _),
    check_json_field(Output, "robba", "1000").

% Test 8: Given I have a 'string array' named 'peppe' inside 'stuff'
test_given_array_inside :-
    Script = "rule check version 1.0.0\nscenario 'ecdh'\nGiven I have a 'string array' named 'peppe' inside 'stuff'\nThen print the 'peppe'",
    Data = "{\"stuff\":{\"robba\":\"1000\",\"quantity\":1000,\"peppe\":[\"peppe2\",\"peppe3\",\"peppe4\"]}}",
    zencode_exec(Script, "", Data, Output, _),
    contains_substring(Output, "peppe2"),
    contains_substring(Output, "peppe3"),
    contains_substring(Output, "peppe4").

% Test 9: Given I have a 'string' named by 'friend' (dynamic reference)
test_given_named_by :-
    Script = "Given I have a 'string' named by 'friend'\nThen print all data",
    Data = "{\"friend\": \"Bob\",\"Bob\": \"Gnignigni\"}",
    zencode_exec(Script, "", Data, Output, _),
    check_json_field(Output, "Bob", "Gnignigni").

% Test 10: Given I have a '' in path '' (JSON path access)
test_given_in_path :-
    Script = "Given I have a 'string array' in path 'my_dict.result.my_string_array'\nand I have a 'number array' in path 'my_dict.result.my_number_array'\nand I have a 'hex' in path 'my_dict.result.my_hex'\nand I have a 'base64' in path 'my_dict.result.my_base64'\nand I have a 'base58' in path 'my_dict.result.my_base58'\nThen print the data",
    Data = "{\"my_dict\":{\"result\":{\"my_string_array\":[\"hello\",\"world\"],\"my_number_array\":[1,2,3],\"my_hex\":\"0123\",\"my_base64\":\"W8ZFMccV+jErS2wLP3nn6jH46WgNp8vzzfzuFMxmWtA=\",\"my_base58\":\"6nLf3J6QhF94jE6A6BNVcHEyjBXdS1H1YqGBfaWgTULv\"}}}",
    zencode_exec(Script, "", Data, Output, _),
    contains_substring(Output, "my_string_array"),
    contains_substring(Output, "my_number_array"),
    contains_substring(Output, "my_hex").

% Test 11: Given I have a 'uuid' encoded data
test_given_uuid :-
    Script = "Given I have a 'uuid' named 'data1'\nGiven I have a 'base64' named 'data2'\nThen print the 'data2' as 'uuid'",
    Data = "{\"data1\":\"urn:uuid:550e8400-e29b-41d4-a716-446655440000\",\"data2\":\"VQ6EAOKbQdSnFkRmVUQAAA==\"}",
    zencode_exec(Script, "", Data, Output, _),
    check_json_field(Output, "data2", "550e8400-e29b-41d4-a716-446655440000").

% Test 12: Given to decode partials with string prefix
test_given_decode_prefix :-
    Script = "Given I have a 'base58' part of 'identity' after string prefix 'did:dyne:sandbox:'\nThen print the 'identity' as 'hex'",
    Data = "{\"identity\":\"did:dyne:sandbox:2s5wmQjZeYtpckyHakLiP5ujWKDL1M2b8CiP6vwajNrK\"}",
    zencode_exec(Script, "", Data, Output, _),
    check_json_field(Output, "identity", "1bb0515e4fe007600355be41f4d7d93508b3b11b6741b9af51ec295a1b544c40").

% Test 13: Given to decode partials with string suffix
test_given_decode_suffix :-
    Script = "Given I have a 'base58' part of 'pk' before string suffix ':pk'\nThen print the 'pk' as 'hex'",
    Data = "{\"pk\":\"2s5wmQjZeYtpckyHakLiP5ujWKDL1M2b8CiP6vwajNrK:pk\"}",
    zencode_exec(Script, "", Data, Output, _),
    check_json_field(Output, "pk", "1bb0515e4fe007600355be41f4d7d93508b3b11b6741b9af51ec295a1b544c40").

% Test 14: Rename in Given statement
test_given_rename :-
    Script = "Given that I have a 'string' named 'eddsa public key'\nGiven that I rename 'eddsa_public_key' to 'eddsa string'\nGiven that I have a 'base58' named 'eddsa public key'\nGiven I have a 'string' named 'comment'\nWhen I append 'comment' to 'eddsa string'\nThen print all data",
    Data = "{\"eddsa_public_key\":\"2s5wmQjZeYtpckyHakLiP5ujWKDL1M2b8CiP6vwajNrK\",\"comment\":\" è una stringa\"}",
    zencode_exec(Script, "", Data, Output, _),
    contains_substring(Output, "eddsa_string"),
    contains_substring(Output, "comment").

% Test 15: Nested dictionary with "in" clause
test_given_nested_dict_in :-
    Script = "Given that I have a 'string' named 'id' in 'authentication'\nThen print all data",
    Data = "{\"@context\":[\"https://www.w3.org/ns/did/v1\",\"https://w3id.org/security/suites/ed25519-2020/v1\"],\"id\":\"did:example:123456789abcdefghi\",\"authentication\":[{\"id\":\"did:example:123456789abcdefghi#keys-1\",\"type\":\"Ed25519VerificationKey2020\",\"controller\":\"did:example:123456789abcdefghi\",\"publicKeyMultibase\":\"zH3C2AVvLMv6gmMNam3uVAjZpfkcJCwDwnZn6z3wXmqPV\"}]}",
    zencode_exec(Script, "", Data, Output, _),
    check_json_field(Output, "id", "did:example:123456789abcdefghi#keys-1").

% Run all given tests
run_tests :-
    write('Running Zenroom Given Tests...'), nl,
    TestList = [
        (test_given_nothing, 'test_given_nothing'),
        (test_given_string_named, 'test_given_string_named'),
        (test_given_hex_named, 'test_given_hex_named'),
        (test_given_number_inside, 'test_given_number_inside'),
        (test_given_valid_arrays, 'test_given_valid_arrays'),
        (test_given_my_keyring, 'test_given_my_keyring'),
        (test_given_inside_nested, 'test_given_inside_nested'),
        (test_given_array_inside, 'test_given_array_inside'),
        (test_given_named_by, 'test_given_named_by'),
        (test_given_in_path, 'test_given_in_path'),
        (test_given_uuid, 'test_given_uuid'),
        (test_given_decode_prefix, 'test_given_decode_prefix'),
        (test_given_decode_suffix, 'test_given_decode_suffix'),
        (test_given_rename, 'test_given_rename'),
        (test_given_nested_dict_in, 'test_given_nested_dict_in')
    ],
    run_test_list(TestList, 0, 0, Passed, Failed),
    nl,
    write('========================================'), nl,
    write('Given Tests Summary:'), nl,
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
