# Zenroom Integration for Scryer Prolog - Cycle 1 Complete

## What Has Been Implemented (Cycle 1)

✅ **Foundation and Basic Execution** - Complete

### Files Created

1. **`src/lib/zenroom_ffi.pl`** - Low-level FFI bindings
   - Direct bindings to Zenroom C API (`zencode_exec_tobuf`, `zenroom_exec_tobuf`)
   - Buffer allocation and management (64KB stdout, 8KB stderr)
   - Error handling and return code checking
   - Multiple library path detection

2. **`src/lib/zenroom.pl`** - High-level user interface  
   - `zencode_exec/5` - Execute Zencode scripts
   - `zenroom_exec/5` - Execute Lua scripts in Zenroom
   - `set_zenroom_library_path/1` - Configure library location
   - Comprehensive documentation and examples

3. **`tests-pl/zenroom_basic.pl`** - Test suite (TDD Red phase)
   - Test basic Zencode execution
   - Test simple output generation
   - Test execution with keys
   - Test execution with data

4. **`scripts/build-zenroom.sh`** - Build automation script
   - Clones Zenroom repository
   - Builds shared library
   - Installs to Scryer directory

## Next Steps - Testing

### Option 1: Build Zenroom from Source

```bash
cd scryer-prolog
./scripts/build-zenroom.sh
```

This will:
1. Clone Zenroom repository
2. Build the shared library
3. Copy it to the Scryer directory

### Option 2: Use Pre-built Zenroom

If you already have Zenroom built:

```bash
# Copy your libzenroom library
cp /path/to/your/libzenroom.so .
# or
cp /path/to/your/libzenroom.dylib .
```

### Running Tests

Once the library is available:

```bash
cd scryer-prolog

# Run the test suite
scryer-prolog tests-pl/zenroom_basic.pl
```

Expected output:
```
Running Zenroom Basic Tests...
PASS: test_basic_zencode_exec
PASS: test_simple_output
PASS: test_zencode_with_keys
PASS: test_zencode_with_data
All tests passed!
```

### Quick Test in REPL

```prolog
$ scryer-prolog
?- use_module(library(zenroom)).
   true.

?- zencode_exec(
     "Given nothing\nThen print the 'string' 'Hello Zenroom!'",
     "", "", Output, Errors).
   Output = "{\"output\":[\"Hello_Zenroom!\"]}",
   Errors = "".
```

## Architecture Overview

```
┌─────────────────────────────────────────┐
│         User Application                │
└──────────────┬──────────────────────────┘
               │ uses library(zenroom)
               ▼
┌─────────────────────────────────────────┐
│  src/lib/zenroom.pl                     │
│  - zencode_exec/5                       │
│  - zenroom_exec/5                       │
│  - High-level predicates                │
└──────────────┬──────────────────────────┘
               │ uses library(zenroom_ffi)
               ▼
┌─────────────────────────────────────────┐
│  src/lib/zenroom_ffi.pl                 │
│  - FFI bindings                         │
│  - Buffer management                    │
│  - Error handling                       │
└──────────────┬──────────────────────────┘
               │ uses library(ffi)
               ▼
┌─────────────────────────────────────────┐
│  Zenroom C Library                      │
│  - libzenroom.so/.dylib/.dll            │
│  - Cryptographic operations             │
│  - Zencode execution                    │
└─────────────────────────────────────────┘
```

## API Summary

### Basic Execution

```prolog
zencode_exec(+Script, +Keys, +Data, -Output, -Errors)
```
Execute a Zencode script.

```prolog
zenroom_exec(+Script, +Keys, +Data, -Output, -Errors)
```
Execute a Lua script in Zenroom.

### Configuration

```prolog
set_zenroom_library_path(+Path)
```
Set the path to Zenroom shared library.

## Example Scripts

### 1. Simple Output
```prolog
?- zencode_exec(
     "Given nothing\nThen print the 'string' 'test'",
     "", "", Output, _).
```

### 2. Create ECDH Keypair
```prolog
?- zencode_exec(
     "Scenario 'ecdh': Create keypair\n\
      Given that I am known as 'Alice'\n\
      When I create the ecdh key\n\
      Then print my 'keyring'",
     "", "", Output, _).
```

### 3. Process Data
```prolog
?- zencode_exec(
     "Given I have a 'string' named 'message'\n\
      Then print the 'message'",
     "",
     "{\"message\":\"Hello World\"}",
     Output, _).
```

## Known Limitations (Cycle 1)

- ⚠️ Config, Extra, and Context parameters not yet exposed (Cycle 3)
- ⚠️ No validation predicates (Cycle 4)
- ⚠️ No cryptographic primitives yet (Cycles 5-6)
- ⚠️ No high-level helpers (Cycle 8)
- ⚠️ No JSON integration helpers (Cycle 9)

These will be implemented in subsequent TDD cycles.

## Troubleshooting

### Error: `zenroom_library_not_found`

The Zenroom shared library is not found. Try:

1. Build using `./scripts/build-zenroom.sh`
2. Set explicit path: `set_zenroom_library_path('/path/to/libzenroom.so')`
3. Check library is in current directory or standard paths

### Error: `zenroom_execution_failed(N)`

Zenroom execution returned exit code N. Check:
- Script syntax is valid Zencode
- Keys/Data are valid JSON
- Errors parameter for details

### Tests fail to load module

Ensure you're running from the Scryer Prolog root directory.

## Next Cycle: Cycle 2

The next TDD cycle will implement:
- Improved buffer management
- Enhanced error handling
- `zenroom_exec/5` for Lua scripts
- Tests for error conditions and large outputs

## References

- Zenroom: https://github.com/dyne/Zenroom
- Zencode Documentation: https://dev.zenroom.org
- Scryer Prolog FFI: See `src/lib/ffi.pl`
