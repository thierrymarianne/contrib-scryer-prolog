# Scryer-Zenroom

A Prolog library for integrating [Zenroom](https://zenroom.org) cryptographic operations into [Scryer Prolog](https://scryer.pl) via FFI.

[![License: BSD-3-Clause](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

## Overview

Scryer-Zenroom provides declarative Prolog predicates for executing Zencode scripts and performing cryptographic operations using the Zenroom secure execution environment.

**Features:**
- 🔐 Execute Zencode scripts declaratively
- 🔧 Access Zenroom's cryptographic primitives
- 📦 Standalone package - no Scryer Prolog core modifications
- 🧪 Comprehensive test suite
- 📚 Extensive documentation

## Quick Start

### Installation

1. **Install Scryer Prolog** (if not already installed):
   ```bash
   cargo install scryer-prolog
   ```

2. **Clone this package:**
   ```bash
   git clone https://github.com/your-org/scryer-zenroom
   cd scryer-zenroom
   ```

3. **Build Zenroom library:**
   ```bash
   ./scripts/build-zenroom.sh
   ```

4. **Add to Scryer's library path:**
   ```bash
   export SCRYER_PROLOG_LIBRARY_PATH="$PWD/lib:$SCRYER_PROLOG_LIBRARY_PATH"
   ```

### Usage

```prolog
?- use_module(library(zenroom)).

% Simple execution
?- zencode_exec(
     "Given nothing\nThen print the 'string' 'Hello Zenroom!'",
     "", "", Output, Errors).
Output = "{\"output\":[\"Hello_Zenroom!\"]}".

% Create ECDH keypair
?- zencode_exec(
     "Scenario 'ecdh': Create keypair\n\
      Given that I am known as 'Alice'\n\
      When I create the ecdh key\n\
      Then print my 'keyring'",
     "", "", Output, _).
Output = "{\"Alice\":{\"keyring\":{\"ecdh\":\"...\"}}}", ...
```

## Features by Development Cycle

### ✅ Cycle 1: Foundation (Current)
- Basic Zencode script execution
- Lua script execution in Zenroom
- FFI bindings to Zenroom C API
- Buffer management and error handling

### 🚧 Cycle 2: Enhanced Error Handling (Planned)
- Improved error messages
- Large output handling
- Validation helpers

### 📅 Future Cycles
- **Cycle 3:** Extended execution with config/extra/context
- **Cycle 4:** Input and code validation predicates
- **Cycle 5-6:** Cryptographic primitives (hashing, signing)
- **Cycle 7:** Zencode introspection
- **Cycle 8:** High-level cryptographic helpers
- **Cycle 9:** JSON integration
- **Cycle 10:** Complete documentation

## Documentation

- [Getting Started Guide](docs/ZENROOM_CYCLE1.md)
- [API Reference](lib/zenroom.pl) (see PlDoc comments)
- [Examples](examples/)
- [Contributing](CONTRIBUTING.md)

## Requirements

### Runtime
- Scryer Prolog (>= 0.9.0 recommended)
- Zenroom shared library (libzenroom.so/.dylib/.dll)

### Build
- Git
- CMake or Make
- GCC or Clang
- Optional: Rust toolchain (for building custom Zenroom)

## Project Structure

```
scryer-zenroom/
├── lib/                    # Prolog library modules
│   ├── zenroom.pl         # User-facing API
│   └── zenroom_ffi.pl     # FFI bindings
├── tests/                  # Test suite
│   └── zenroom_basic.pl   # Basic functionality tests
├── scripts/                # Build scripts
│   └── build-zenroom.sh   # Zenroom library builder
├── docs/                   # Documentation
│   └── ZENROOM_CYCLE1.md  # Cycle 1 guide
├── examples/               # Example programs
├── README.md              # This file
├── LICENSE                # BSD-3-Clause license
└── CONTRIBUTING.md        # Contribution guidelines
```

## API Overview

### Core Predicates

```prolog
%% zencode_exec(+Script, +Keys, +Data, -Output, -Errors)
% Execute a Zencode script

%% zenroom_exec(+Script, +Keys, +Data, -Output, -Errors)
% Execute a Lua script in Zenroom

%% set_zenroom_library_path(+Path)
% Configure Zenroom library location
```

See [API Documentation](lib/zenroom.pl) for complete details.

## Testing

Run the test suite:

```bash
cd scryer-zenroom
scryer-prolog tests/zenroom_basic.pl
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

## Examples

### Cryptographic Key Generation

```prolog
?- zencode_exec(
     "Scenario 'ecdh': Create keypair\n\
      Given that I am known as 'Alice'\n\
      When I create the ecdh key\n\
      Then print my 'keyring'",
     "", "", Output, _).
```

### Data Processing

```prolog
?- zencode_exec(
     "Given I have a 'string' named 'message'\n\
      Then print the 'message'",
     "",
     "{\"message\":\"Hello World\"}",
     Output, _).
```

See [examples/](examples/) directory for more.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

This project follows a Test-Driven Development (TDD) approach with 10 planned development cycles. We're currently on Cycle 1.

## Development Roadmap

- [x] Cycle 1: Foundation and basic execution
- [ ] Cycle 2: Buffer management and error handling
- [ ] Cycle 3: Extended execution parameters
- [ ] Cycle 4: Validation predicates
- [ ] Cycles 5-6: Cryptographic primitives
- [ ] Cycle 7: Introspection
- [ ] Cycle 8: High-level helpers
- [ ] Cycle 9: JSON integration
- [ ] Cycle 10: Documentation and release

## License

BSD-3-Clause License - see [LICENSE](LICENSE) file for details.

This is the same license as Scryer Prolog for compatibility.

## Acknowledgments

- [Zenroom](https://zenroom.org) by Dyne.org - Secure execution environment
- [Scryer Prolog](https://scryer.pl) - Modern Prolog implementation
- [Scryer Prolog community](https://github.com/mthom/scryer-prolog/graphs/contributors) - Scryer Prolog Contributors

## Links

- **Zenroom:** https://zenroom.org
- **Zenroom GitHub:** https://github.com/dyne/Zenroom
- **Zencode Documentation:** https://dev.zenroom.org
- **Scryer Prolog:** https://scryer.pl
- **Scryer GitHub:** https://github.com/mthom/scryer-prolog

## Support

- Report issues: [GitHub Issues](https://github.com/your-org/scryer-zenroom/issues)
- Discussions: [GitHub Discussions](https://github.com/your-org/scryer-zenroom/discussions)

## Version

Current: **0.1.0-alpha** (Cycle 1 complete)
