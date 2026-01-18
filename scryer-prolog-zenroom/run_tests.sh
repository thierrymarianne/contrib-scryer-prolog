#!/bin/bash
# Test runner for scryer-prolog-zenroom battle-tests
# Runs tests with proper library path configuration

SCRYER_BIN="./target/release/scryer-prolog"
ZENROOM_LIB_DIR="$PWD/scryer-prolog-zenroom/lib"

export SCRY

ER_LIBRARY_PATH="$ZENROOM_LIB_DIR"

echo "==================================="
echo "Scryer-Zenroom Battle-Test Runner"
echo "==================================="
echo ""
echo "Scryer Binary: $SCRYER_BIN"
echo "Zenroom Library: $ZENROOM_LIB_DIR"
echo ""

# Function to run a single test suite
run_test() {
    local test_file=$1
    local test_name=$(basename "$test_file" .pl)
    
    echo "──────────────────────────────────"
    echo "Running: $test_name"
    echo "──────────────────────────────────"
    
    # Run from scryer-prolog-zenroom directory so relative lib/ path works
    cd scryer-prolog-zenroom
    ../$SCRYER_BIN "tests/$test_name.pl" 2>&1
    local exit_code=$?
    cd ..
    
    echo ""
    return $exit_code
}

# Run individual test suites
echo "Running test suites..."
echo ""

run_test "scryer-prolog-zenroom/tests/zenroom_basic.pl"
run_test "scryer-prolog-zenroom/tests/zenroom_hash.pl"
run_test "scryer-prolog-zenroom/tests/zenroom_given.pl"
run_test "scryer-prolog-zenroom/tests/zenroom_ecdh.pl"

echo "==================================="
echo "Test run complete"
echo "==================================="
