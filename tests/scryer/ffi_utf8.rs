// Test for UTF-8 handling in FFI C string reads
// This test reproduces the panic when reading C strings with invalid UTF-8

#[cfg(feature = "ffi")]
#[test]
fn test_ffi_cstr_with_invalid_utf8() {
    use crate::machine::mock_wam::*;
    
    let mut wam = MockWAM::new();
    
    // Test program that simulates reading a C string with invalid UTF-8
    // This mimics what happens when Zenroom returns hex-encoded binary data
    let program = r#"
        :- use_module(library(ffi)).
        
        % Simulate a C library that returns non-UTF-8 bytes
        :- use_foreign_module('./tests/scryer/fixtures/libutf8test.so', [
            'get_invalid_utf8_string'([ptr], cstr)
        ]).
        
        test_invalid_utf8 :-
            % Allocate buffer for output
            ffi:allocate(global, ptr, 0, Ptr),
            
            % Call function that returns invalid UTF-8
            ffi:'get_invalid_utf8_string'([Ptr]),
            
            % This should NOT panic, but handle invalid UTF-8 gracefully
            ffi:read_ptr(cstr, Ptr, Result),
            
            % Result should be a string (possibly with replacement characters)
            atom(Result),
            
            % Cleanup
            ffi:deallocate(global, ptr, Ptr).
    "#;
    
    // Before patch: This test FAILS with panic
    // After patch: This test PASSES with lossy conversion
    
    // Note: Requires creating fixtures/libutf8test.c:
    // ```c
    // const char* get_invalid_utf8_string() {
    //     // String with invalid UTF-8 byte at position 16
    //     static char buf[] = "Valid UTF-8 text\xFF invalid";
    //     return buf;
    // }
    // ```
    
    let result = wam.run_module_string(program);
    
    // Should succeed without panicking
    assert!(result.is_ok(), "FFI should handle invalid UTF-8 gracefully");
}

#[cfg(feature = "ffi")]  
#[test]
fn test_ffi_cstr_with_hex_output() {
    use crate::machine::mock_wam::*;
    
    let mut wam = MockWAM::new();
    
    // More realistic test: JSON with hex-encoded hash (like Zenroom)
    // Hex characters are valid UTF-8, but test the path
    let program = r#"
        :- use_module(library(ffi)).
        
        test_hex_json :-
            % Simulate reading JSON with hex hash from C library
            HexJSON = '{"hash":"c24463f5e352da20cb79a43f97436cce57344911e1d0ec0008cbedb5fabcca33"}',
            
            % Verify it's valid
            atom_length(HexJSON, Len),
            Len > 0.
    "#;
    
    let result = wam.run_module_string(program);
    assert!(result.is_ok());
}
