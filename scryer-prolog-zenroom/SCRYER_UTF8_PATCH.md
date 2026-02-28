# Patch for Scryer Prolog UTF-8 Handling in FFI

## Issue

Scryer Prolog panics when reading C strings via FFI that contain non-UTF-8 bytes:
```
thread 'main' panicked at src/machine/system_calls.rs:5130:70:
called `Result::unwrap()` on an `Err` value: Utf8Error { valid_up_to: 16, error_len: Some(1) }
```

This blocks FFI libraries that return binary/cryptographic data (e.g., Zenroom).

## Patch

**File**: `src/machine/system_calls.rs`  
**Line**: 5130  
**Function**: `unify_ffi_result()`

### Current Code (Panics):

```rust
Value::CString(cstr) => {
    let str_cell = resource_error_call_result!(
        self.machine_st,
        self.machine_st.heap.allocate_cstr(cstr.to_str().unwrap())  // <- PANICS HERE
    );

    unify!(self.machine_st, str_cell, return_value);
}
```

### Proposed Fix (Option 1 - Graceful Degradation):

```rust
Value::CString(cstr) => {
    // Handle potentially invalid UTF-8 by replacing invalid sequences
    let str_value = cstr.to_str()
        .unwrap_or_else(|e| {
            // Try to salvage valid UTF-8 prefix
            let bytes = cstr.to_bytes();
            std::str::from_utf8(&bytes[..e.utf8_error().valid_up_to()])
                .unwrap_or("")
        });
    
    let str_cell = resource_error_call_result!(
        self.machine_st,
        self.machine_st.heap.allocate_cstr(str_value)
    );

    unify!(self.machine_st, str_cell, return_value);
}
```

### Proposed Fix (Option 2 - Use Lossy Conversion):

```rust
Value::CString(cstr) => {
    // Convert to String, replacing invalid UTF-8 with replacement character
    let str_value = cstr.to_string_lossy();
    
    let str_cell = resource_error_call_result!(
        self.machine_st,
        self.machine_st.heap.allocate_cstr(&str_value)
    );

    unify!(self.machine_st, str_cell, return_value);
}
```

### Proposed Fix (Option 3 - Add Byte List Support):

Add a new FFI type for reading raw bytes as a Prolog list:

```rust
// In src/ffi.rs or wherever FFI types are defined
pub enum FfiType {
    // ... existing types ...
    CStr,
    Bytes,  // NEW: Read as byte list instead of string
}

// In system_calls.rs, update ffi_read_ptr()
pub(crate) fn ffi_read_ptr(&mut self) -> CallResult {
    // ... existing code ...
    let value = match ffi_type {
        atom!("cstr") => {
            // Existing C string handling with lossy conversion
            self.foreign_function_table
                .read_ptr_as_cstr(ptr, &mut self.machine_st.arena)
        },
        atom!("bytes") => {
            // NEW: Read as byte list
            self.foreign_function_table
                .read_ptr_as_bytes(ptr, &mut self.machine_st.arena)
        },
        _ => { /* error */ }
    };
    // ...
}
```

## Recommendation

**Option 2 (Lossy Conversion)** is the best immediate fix because:
1. Simple - one line change
2. Never panics
3. Preserves valid UTF-8
4. Replaces invalid bytes with � (U+FFFD)
5. Matches Rust ecosystem conventions

**Option 3** should be added later for users who need raw bytes.

## Testing

### Test Case (Zenroom Hash):

```prolog
:- use_module(library(ffi)).

test_utf8_fix :-
    % This previously panicked
    use_foreign_module('libzenroom.dylib', [
        'zencode_exec_tobuf'([cstr, cstr, cstr, cstr, cstr, cstr, ptr, uint64, ptr, uint64], int)
    ]),
    
    Script = "rule output encoding hex\nGiven nothing\nWhen I write string 'test' in 'source'\nand I create the hash of 'source'\nThen print the 'hash'",
    
    with_locals([
        let(StdoutBuf, uint8, 0),
        let(StderrBuf, uint8, 0)
    ], (
        ffi:'zencode_exec_tobuf'(Script, "", "", "", "", "", StdoutBuf, 65536, StderrBuf, 8192, _),
        
        % This should now work instead of panicking
        read_ptr(cstr, StdoutBuf, Output),
        writeln(Output)
    )).
```

### Expected Output:
```json
{"hash":"9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08"}
```

## Impact

This fix enables:
- ✅ Cryptographic libraries (Zenroom, OpenSSL bindings)
- ✅ Binary data processing libraries
- ✅ Any FFI library with non-ASCII output
- ✅ Better error handling for malformed C strings

## Files to Modify

1. `src/machine/system_calls.rs` (line 5130)
2. Optional: Update FFI documentation to mention lossy UTF-8 conversion

## Patch File

```diff
--- a/src/machine/system_calls.rs
+++ b/src/machine/system_calls.rs
@@ -5127,7 +5127,8 @@ impl MachineState {
             Value::CString(cstr) => {
                 let str_cell = resource_error_call_result!(
                     self.machine_st,
-                    self.machine_st.heap.allocate_cstr(cstr.to_str().unwrap())
+                    // Use lossy conversion to handle invalid UTF-8
+                    self.machine_st.heap.allocate_cstr(&cstr.to_string_lossy())
                 );

                 unify!(self.machine_st, str_cell, return_value);
```

## Verification

After applying patch:
```bash
cd scryer-prolog
cargo build --release
export DYLD_LIBRARY_PATH=$HOME/.local/lib
./target/release/scryer-prolog scryer-prolog-zenroom/tests/zenroom_hash.pl
# Should run all 16 hash tests without panicking
```

## Submitting to Scryer Prolog

1. Fork https://github.com/mthom/scryer-prolog
2. Create branch: `fix/ffi-utf8-handling`
3. Apply patch
4. Add test case in `src/tests/` if applicable
5. Submit PR with:
   - Title: "Fix: Handle invalid UTF-8 in FFI C strings using lossy conversion"
   - Reference this issue
   - Include test case showing Zenroom integration

## Contact

For questions about this patch:
- Issue: Zenroom FFI integration
- Test repository: scryer-prolog-zenroom package
- Reporter: [Your name/GitHub handle]
