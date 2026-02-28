# Scryer-Zenroom Package - Build Automation

# Default recipe shows all tasks
default:
    @just --list

# Install Zenroom library (macOS)
install-zenroom-macos:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -f /usr/local/lib/libzenroom.dylib ]; then
        echo "Building Zenroom..."
        ./scripts/build-zenroom.sh macos
        echo "Installing to /usr/local/lib..."
        sudo cp build/libzenroom.dylib /usr/local/lib/
        echo "✓ Zenroom library installed"
    else
        echo "✓ Zenroom library already installed"
    fi

# Install Zenroom library (Linux)
install-zenroom-linux:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -f /usr/local/lib/libzenroom.so ]; then
        echo "Building Zenroom..."
        ./scripts/build-zenroom.sh linux
        echo "Installing to /usr/local/lib..."
        sudo cp build/libzenroom.so /usr/local/lib/
        echo "✓ Zenroom library installed"
    else
        echo "✓ Zenroom library already installed"
    fi

# Build Zenroom library without installing (macOS)
build-zenroom-macos:
    ./scripts/build-zenroom.sh macos

# Build Zenroom library without installing (Linux)
build-zenroom-linux:
    ./scripts/build-zenroom.sh linux

# Run all tests
test: test-basic test-hash test-given test-ecdh

# Run basic tests
test-basic:
    @echo "Running basic tests..."
    @cd tests && ../../target/release/scryer-prolog zenroom_basic.pl || \
        (cd .. && ../target/release/scryer-prolog tests/zenroom_basic.pl) || \
        scryer-prolog tests/zenroom_basic.pl

# Run hash tests
test-hash:
    @echo "Running hash tests..."
    @cd tests && ../../target/release/scryer-prolog zenroom_hash.pl || \
        (cd .. && ../target/release/scryer-prolog tests/zenroom_hash.pl) || \
        scryer-prolog tests/zenroom_hash.pl

# Run given tests
test-given:
    @echo "Running given tests..."
    @cd tests && ../../target/release/scryer-prolog zenroom_given.pl || \
        (cd .. && ../target/release/scryer-prolog tests/zenroom_given.pl) || \
        scryer-prolog tests/zenroom_given.pl

# Run ECDH tests
test-ecdh:
    @echo "Running ECDH tests..."
    @cd tests && ../../target/release/scryer-prolog zenroom_ecdh.pl || \
        (cd .. && ../target/release/scryer-prolog tests/zenroom_ecdh.pl) || \
        scryer-prolog tests/zenroom_ecdh.pl

# Clean build artifacts
clean:
    rm -rf build/
    rm -f lib/*.o

# Install package locally for development
install-dev:
    @echo "Installing to ~/scryer_libs/scryer-zenroom..."
    @mkdir -p ~/scryer_libs/scryer-zenroom
    @cp -r lib/* ~/scryer_libs/scryer-zenroom/
    @cp scryer-manifest.pl ~/scryer_libs/scryer-zenroom/
    @echo "✓ Package installed locally"

# Check if Zenroom library is available
check-zenroom:
    #!/usr/bin/env bash
    if [ -f /usr/local/lib/libzenroom.dylib ] || [ -f /usr/local/lib/libzenroom.so ]; then
        echo "✓ Zenroom library found"
        exit 0
    else
        echo "✗ Zenroom library not found"
        echo "Run: just install-zenroom-macos (or install-zenroom-linux)"
        exit 1
    fi

# Run all checks (lint, test)
ci: check-zenroom test
    @echo "✓ All checks passed"

# Build Scryer Prolog for WASM (requires wasm-pack)
build-wasm:
    @echo "Building Scryer Prolog for WASM..."
    # Go to repo root, build, and output directly to the browser example folder
    cd .. && wasm-pack build --target web --out-dir scryer-zenroom/examples/browser --no-typescript --no-default-features
    @echo "✓ WASM artifacts built in examples/browser/"

# Serve browser example (requires Node.js)
serve-browser:
    @echo "Serving browser example at http://localhost:8080..."
    @echo "Ensure you have built Scryer WASM first!"
    @cd examples/browser && npx -y srf@latest

# List available commands
help:
    @just --list
