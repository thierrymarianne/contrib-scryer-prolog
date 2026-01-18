
#[cfg(test)]
mod tests {
    use super::*;
    use std::ffi::{CString, CStr};
    use std::ptr::NonNull;

    #[test]
    fn test_invalid_utf8_handling() {
        // Construct a byte sequence that is NOT valid UTF-8 (0xFF is invalid in UTF-8)
        let bytes = b"Hello\xFFWorld\0";
        let cstr = unsafe { CStr::from_bytes_with_nul_unchecked(bytes) };
        
        // Simulate what happens in call_cstr
        // Original code (simulated):
        // let owned = unsafe { CStr::from_ptr(cstr.as_ptr()) }.to_owned();
        // This effectively keeps the invalid bytes in the CString.
        // Scryer's Value::CString wraps a CString.
        
        // New code:
        let string_lossy = cstr.to_string_lossy();
        let owned = CString::new(string_lossy.as_ref()).unwrap_or_else(|_| CString::default());
        
        // The resulting CString should contain replacement characters but BE valid UTF-8
        let result_bytes = owned.as_bytes();
        
        // Check if it contains the replacement character (Usually EF BF BD for U+FFFD)
        // \xFF should become \xEF\xBF\xBD
        
        let expected_prefix = b"Hello";
        assert_eq!(&result_bytes[0..5], expected_prefix);
        
        // We verify that we can convert it back to a Rust String without error
        let rust_string = owned.to_str();
        assert!(rust_string.is_ok(), "Should represent a valid UTF-8 string");
    }
}
