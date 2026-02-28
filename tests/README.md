# Running the Battle-Tests

This directory contains comprehensive tests for the scryer-zenroom crate, adapted from the Zenroom project's test suite.

## Prerequisites

The Zenroom shared library must be installed and accessible:

- **macOS**: `libzenroom.dylib`
- **Linux**: `libzenroom.so`
- **Windows**: `zenroom.dll`

### Installing Zenroom

```bash
# Clone and build Zenroom
git clone https://github.com/dyne/Zenroom.git
cd Zenroom
make linux  # or 'make osx' on macOS

# Copy the library to a standard location
sudo cp src/libzenroom.so /usr/local/lib/  # Linux
# or
sudo cp src/libzenroom.dylib /usr/local/lib/  # macOS
```

Alternatively, you can set a custom library path in your Prolog session:

```prolog
?- set_zenroom_library_path('/path/to/libzenroom.dylib').
```

## Test Suites

### 1. Basic Integration Tests (`zenroom_basic.pl`)

Basic FFI integration and simple Zencode execution.

```bash
scryer-prolog tests/zenroom_basic.pl
```

**Coverage:**
- Simple Zencode execution
- Basic output tests
- Execution with keys
- Execution with data

### 2. Hash Operations (`zenroom_hash.pl`)

Comprehensive tests for cryptographic hash operations (16 tests).

```bash
scryer-prolog tests/zenroom_hash.pl
```

**Coverage:**
- SHA256, SHA512 hashing
- SHA3-256, SHA3-512 hashing
- Key Derivation Functions (KDF)
- Password-Based KDF (PBKDF)
- HMAC generation
- Multihash format
- Hash to elliptic curve points

### 3. Given Statements (`zenroom_given.pl`)

Tests for Zencode data loading patterns (15 tests).

```bash
scryer-prolog tests/zenroom_given.pl
```

**Coverage:**
- Basic data loading (`Given nothing`, `Given I have...`)
- Nested data structures
- JSON path access
- Dynamic references (`named by`)
- Encoding conversions (hex, base58, base64, UUID)
- String prefix/suffix parsing
- Data renaming

### 4. ECDH Cryptography (`zenroom_ecdh.pl`)

ECDH cryptographic operations (10 tests).

```bash
scryer-prolog tests/zenroom_ecdh.pl
```

**Coverage:**
- Random password generation
- Symmetric encryption/decryption
- Keypair generation (Alice, Bob)
- Public key extraction
- Message signing (standard and deterministic)
- Signature verification
- Immutability checks

## Running All Tests

While each test suite runs independently with `initialization/1`, you can view the test inventory:

```bash
scryer-prolog tests/run_all_tests.pl
```

This will display information about all available test suites.

## Test Architecture

Each test file follows this pattern:

1. **Test Predicates**: Individual test predicates (e.g., `test_hash_sha256/0`)
2. **Helper Predicates**: Shared validation helpers (e.g., `check_json_field/3`)
3. **Test Runner**: `run_tests/0` that executes all tests and reports results
4. **Initialization**: `:- initialization(run_tests).` for auto-execution

### Expected Output

When tests pass, you'll see:

```
Running Zenroom Hash Tests...
PASS: test_hash_sha256
PASS: test_hash_sha512
...
========================================
Hash Tests Summary:
  Passed: 16
  Failed: 0
========================================
```

## Debugging Failed Tests

If a test fails:

1. **Check Library Path**: Ensure Zenroom library is accessible
2. **Check Zenroom Version**: These tests are designed for Zenroom's deterministic test mode
3. **Run Individual Tests**: Load the test file and run specific predicates:

```prolog
?- consult('tests/zenroom_hash.pl').
?- test_hash_sha256.
```

4. **Check Output Manually**:

```prolog
?- zencode_exec("Given nothing\nWhen I write string 'test' in 'x'\nThen print 'x'", "", "", Out, Err).
Out = ...
Err = ...
```

## Test Coverage Summary

| Test Suite | Tests | Coverage |
|------------|-------|----------|
| Basic | 4 | FFI Integration |
| Hash | 16 | SHA256/512, SHA3, KDF, PBKDF, HMAC, Multihash |
| Given | 15 | Data loading, JSON paths, encoding |
| ECDH | 10 | Encryption, key generation, signing |
| **Total** | **45** | **Core Zenroom functionality** |

## Contributing Tests

To add new tests from Zenroom's test suite:

1. Find the relevant `.bats` test file in `_src-zenroom/test/zencode/`
2. Extract the Zencode script and expected output
3. Create a new test predicate in the appropriate test file
4. Add it to the `TestList` in `run_tests/0`

Example:

```prolog
test_my_new_feature :-
    Script = "Given nothing\nWhen ...\nThen ...",
    zencode_exec(Script, "", "", Output, _),
    check_json_field(Output, "field", "expected_value").
```

Then add to the test list:

```prolog
TestList = [
    ...,
    (test_my_new_feature, 'test_my_new_feature')
].
```
