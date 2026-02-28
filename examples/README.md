# Scryer-Zenroom Examples

This directory contains example programs demonstrating various features of the Scryer-Zenroom library.

## Running Examples

From the `scryer-zenroom` directory:

```bash
# Set library path
export SCRYER_PROLOG_LIBRARY_PATH="$PWD/lib:$SCRYER_PROLOG_LIBRARY_PATH"

# Run an example
scryer-prolog examples/01_simple_output.pl
```

## Available Examples

### 1. Simple Output (`01_simple_output.pl`)

**Demonstrates:** Basic Zencode execution with string output

```prolog
?- example_simple_output.
Output: {"output":["Hello from Zenroom!"]}
```

**Concepts:**
- Basic `zencode_exec/5` usage
- Empty keys and data parameters
- String output handling

---

### 2. ECDH Keypair Generation (`02_ecdh_keypair.pl`)

**Demonstrates:** Cryptographic key generation using Zencode scenarios

```prolog
?- example_ecdh_keypair.
=== ECDH Keypair Generation ===
Alice's keyring:
{"Alice":{"keyring":{"ecdh":"..."}}}
```

**Concepts:**
- Zencode scenarios (ECDH)
- Identity management ("known as")
- Cryptographic key generation
- JSON output parsing

---

### 3. Data Processing (`03_data_processing.pl`)

**Demonstrates:** Passing input data to Zencode scripts

```prolog
?- example_data_processing.
=== Data Processing Example ===
Input data: {"message":"Hello Zenroom from Prolog!","sender":"Alice"}
Output: {"message":"Hello Zenroom from Prolog!","sender":"Alice"}
```

**Concepts:**
- JSON data input
- Multiple data fields
- Data extraction and printing

---

## Coming Soon (Future Cycles)

### Cycle 4: Validation
- `04_validate_input.pl` - Input validation
- `05_validate_code.pl` - Zencode syntax validation

### Cycles 5-6: Cryptographic Operations
- `06_hashing.pl` - SHA256/SHA512 hashing
- `07_digital_signatures.pl` - Sign and verify messages
- `08_ecdsa_example.pl` - ECDSA signatures

### Cycle 8: High-Level Helpers
- `09_encryption.pl` - Message encryption/decryption
- `10_credentials.pl` - Verifiable credentials

### Cycle 9: JSON Integration
- `11_json_convenience.pl` - JSON encoding/decoding helpers

## Example Template

When creating new examples, use this template:

```prolog
% Example N: Brief Title
% Detailed description of what this example demonstrates

:- use_module(library(zenroom)).

example_name :-
    % Setup
    Script = "...",
    
    % Execute
    zencode_exec(Script, Keys, Data, Output, Errors),
    
    % Display results
    write('=== Example Title ==='), nl,
    write('Output: '), write(Output), nl,
    (Errors \= "" -> 
        (write('Errors: '), write(Errors), nl)
    ;   true
    ).

% Run the example
:- initialization(example_name).
```

## Tips

1. **Error Handling:** Always check the `Errors` parameter
2. **JSON Format:** Ensure input data is valid JSON
3. **Scenarios:** Use appropriate Zencode scenarios for cryptographic operations
4. **Documentation:** Read Zencode docs at https://dev.zenroom.org

## Contributing Examples

Have a useful example? Please contribute!

1. Create a new file: `NN_descriptive_name.pl`
2. Follow the template above
3. Add entry to this README
4. Submit a pull request

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.
