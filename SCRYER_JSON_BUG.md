# Segmentation Fault in library(serialization/json) - Bug Report for Scryer Prolog

## Environment

- **Scryer Prolog Version**: Built from source at commit referenced in `target/release/scryer-prolog`
- **OS**: macOS (Darwin)
- **Date**: 2026-01-18
- **Binary**: `scryer-prolog/target/release/scryer-prolog`

## Issue Summary

Segmentation fault occurs when using `library(serialization/json)` with `phrase/2` to parse JSON output from FFI calls.

## Minimal Reproduction

```prolog
:- use_module(library(serialization/json)).
:- use_module(library(lists)).

% Helper to parse JSON output
parse_json_output(Output, JsonTerm) :-
    atom_chars(Output, OutputChars),
    phrase(json(JsonTerm), OutputChars).

% Helper to check JSON field value
check_json_field(Output, Field, ExpectedValue) :-
    parse_json_output(Output, json(Obj)),
    atom_string(Field, FieldStr),
    atom_string(ExpectedValue, ExpValStr),
    member(FieldStr=ActualValue, Obj),
    (atom(ActualValue) -> atom_string(ActualValue, ActualStr) ; ActualStr = ActualValue),
    ActualStr = ExpValStr.

% Test that triggers segfault
test_hash_sha256 :-
    Script = "rule output encoding hex\nGiven nothing\nWhen I write string 'a string to be hashed' in 'source'\nand I create the hash of 'source'\nThen print the 'hash'",
    zencode_exec(Script, "", "", Output, _),
    check_json_field(Output, "hash", "c24463f5e352da20cb79a43f97436cce57344911e1d0ec0008cbedb5fabcca33").
```

## Steps to Reproduce

1. Load the test file with the above code
2. Query: `?- test_hash_sha256.`
3. **Result**: Segmentation fault

## Expected Behavior

JSON should be parsed successfully and fields extracted for validation.

## Actual Behavior

```
$ ./target/release/scryer-prolog tests/zenroom_hash.pl
Running Zenroom Hash Tests...
 .   Release version: v5.28.11
 .   Build commit hash: 1107b8c4
 .   ECP curve is BLS381
 .   ECDH curve is SECP256K1
[1]    70200 segmentation fault  ./target/release/scryer-prolog tests/zenroom_hash.pl
```

## Context

- Output from FFI call (`zencode_exec/5`) is an atom containing JSON
- Attempting to parse this JSON using `library(serialization/json)`
- The JSON is valid (e.g., `{"hash":"c24463..."}`)
- Simple substring matching with `sub_atom/5` works fine
- Issue only occurs when using `phrase(json(JsonTerm), OutputChars)`

## Workaround

Reverted to using `sub_atom/5` for string matching instead of JSON parsing:

```prolog
check_json_field(Output, Field, ExpectedValue) :-
    atom_string(Output, OutStr),
    atom_string(Field, FieldStr),
    atom_string(ExpectedValue, ExpValStr),
    sub_string(OutStr, _, _, _, FieldStr),
    sub_string(OutStr, _, _, _, ExpValStr).
```

## Additional Notes

- The segfault is consistent and reproducible
- Occurs in test suite with 16 hash operation tests
- All tests using JSON parsing library trigger the segfault
- Tests without JSON parsing library work correctly

## Possible Causes

1. Issue with `phrase/2` when parsing long JSON strings from FFI
2. Memory corruption in JSON term construction
3. Incompatibility between FFI output format and JSON parser expectations

## Request

Please investigate the crash in `library(serialization/json)` when parsing JSON from FFI calls. This is blocking proper test validation for FFI-based libraries.

## Files for Reference

- Test file: `scryer-zenroom/tests/zenroom_hash.pl`
- FFI module: `scryer-zenroom/lib/zenroom_ffi.pl`
- JSON parsing logic: Lines using `parse_json_output/2` and `check_json_field/3`
