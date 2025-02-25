use crate::helper::{load_module_test, load_module_test_with_tokio_runtime};
use serial_test::serial;

// issue #831
#[serial]
#[test]
#[cfg_attr(miri, ignore = "blocked on streams.rs UB")]
fn call_0() {
    load_module_test(
        "tests-pl/issue831-call0.pl",
        "   error(existence_error(procedure,call/0),call/0).\n",
    );
}

#[test]
#[cfg_attr(miri, ignore = "unsupported operation when isolation is enabled")]
fn issue2588_load_html() {
    load_module_test("tests-pl/issue2588.pl", "[element(html,[],[element(head,[],[element(title,[],[[H,e,l,l,o,!]])]),element(body,[],[])])]");
}

// issue #2361
#[serial]
#[test]
#[cfg_attr(miri, ignore = "it takes too long to run")]
fn call_qualification() {
    load_module_test("tests-pl/issue2361-call-qualified.pl", "");
}

// issue #2361
#[test]
#[cfg(feature = "http")]
#[cfg_attr(miri, ignore = "it takes too long to run")]
fn http_open_hanging() {
    load_module_test_with_tokio_runtime("tests-pl/issue-http_open-hanging.pl", "received response with status code(200)\nreceived response with status code(200)\nreceived response with status code(200)");
}
