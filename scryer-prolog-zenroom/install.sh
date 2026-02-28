#!/usr/bin/env bash
# Installation script for Scryer-Zenroom package

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(dirname "$SCRIPT_DIR")"
INSTALL_TYPE="${1:-user}"  # 'user' or 'system'

echo "========================================="
echo "Scryer-Zenroom Installation"
echo "========================================="
echo ""

# Detect Scryer Prolog installation
detect_scryer() {
    if command -v scryer-prolog &> /dev/null; then
        SCRYER_BIN="$(command -v scryer-prolog)"
        echo "✓ Found Scryer Prolog: $SCRYER_BIN"
        return 0
    else
        echo "✗ Scryer Prolog not found in PATH"
        echo ""
        echo "Please install Scryer Prolog first:"
        echo "  cargo install scryer-prolog"
        echo "or visit: https://scryer.pl"
        exit 1
    fi
}

# Determine installation directory
get_install_dir() {
    case $INSTALL_TYPE in
        user)
            INSTALL_DIR="$HOME/.scryer-prolog/lib"
            echo "Installation type: User (~/.scryer-prolog/lib)"
            ;;
        system)
            if [ -w /usr/local/lib/scryer-prolog ]; then
                INSTALL_DIR="/usr/local/lib/scryer-prolog"
            else
                echo "System installation requires sudo privileges."
                read -p "Install to /usr/local/lib/scryer-prolog? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    INSTALL_DIR="/usr/local/lib/scryer-prolog"
                    NEED_SUDO=true
                else
                    echo "Installation cancelled."
                    exit 1
                fi
            fi
            echo "Installation type: System ($INSTALL_DIR)"
            ;;
        *)
            echo "Unknown installation type: $INSTALL_TYPE"
            echo "Usage: $0 [user|system]"
            exit 1
            ;;
    esac
}

# Build Zenroom if needed
build_zenroom() {
    if [ -f "$PACKAGE_DIR/libzenroom.so" ] || [ -f "$PACKAGE_DIR/libzenroom.dylib" ]; then
        echo "✓ Zenroom library already built"
        return 0
    fi
    
    echo ""
    read -p "Zenroom library not found. Build it now? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        bash "$PACKAGE_DIR/scripts/build-zenroom.sh"
    else
        echo "⚠ Warning: Zenroom library not built. You'll need to build or provide it manually."
    fi
}

# Install library files
install_files() {
    echo ""
    echo "Installing library files..."
    
    # Create installation directory
    if [ "${NEED_SUDO:-false}" = true ]; then
        sudo mkdir -p "$INSTALL_DIR/zenroom"
    else
        mkdir -p "$INSTALL_DIR/zenroom"
    fi
    
    # Copy library files
    if [ "${NEED_SUDO:-false}" = true ]; then
        sudo cp "$PACKAGE_DIR/lib/"*.pl "$INSTALL_DIR/zenroom/"
    else
        cp "$PACKAGE_DIR/lib/"*.pl "$INSTALL_DIR/zenroom/"
    fi
    
    echo "✓ Installed library files to $INSTALL_DIR/zenroom/"
    
    # Copy Zenroom library if present
    if [ -f "$PACKAGE_DIR/libzenroom.so" ]; then
        if [ "${NEED_SUDO:-false}" = true ]; then
            sudo cp "$PACKAGE_DIR/libzenroom.so" "$INSTALL_DIR/zenroom/"
        else
            cp "$PACKAGE_DIR/libzenroom.so" "$INSTALL_DIR/zenroom/"
        fi
        echo "✓ Installed libzenroom.so"
    elif [ -f "$PACKAGE_DIR/libzenroom.dylib" ]; then
        if [ "${NEED_SUDO:-false}" = true ]; then
            sudo cp "$PACKAGE_DIR/libzenroom.dylib" "$INSTALL_DIR/zenroom/"
        else
            cp "$PACKAGE_DIR/libzenroom.dylib" "$INSTALL_DIR/zenroom/"
        fi
        echo "✓ Installed libzenroom.dylib"
    fi
}

# Setup environment
setup_environment() {
    echo ""
    echo "Setting up environment..."
    
    case $INSTALL_TYPE in
        user)
            SHELL_RC=""
            if [ -f "$HOME/.bashrc" ]; then
                SHELL_RC="$HOME/.bashrc"
            elif [ -f "$HOME/.zshrc" ]; then
                SHELL_RC="$HOME/.zshrc"
            fi
            
            if [ -n "$SHELL_RC" ]; then
                if ! grep -q "SCRYER_PROLOG_LIBRARY_PATH.*zenroom" "$SHELL_RC"; then
                    echo ""  >> "$SHELL_RC"
                    echo "# Scryer-Zenroom library path" >> "$SHELL_RC"
                    echo "export SCRYER_PROLOG_LIBRARY_PATH=\"$INSTALL_DIR:\$SCRYER_PROLOG_LIBRARY_PATH\"" >> "$SHELL_RC"
                    echo "✓ Added library path to $SHELL_RC"
                    echo "  Run: source $SHELL_RC"
                else
                    echo "✓ Library path already in $SHELL_RC"
                fi
            fi
            
            # Also set for current session
            export SCRYER_PROLOG_LIBRARY_PATH="$INSTALL_DIR:$SCRYER_PROLOG_LIBRARY_PATH"
            ;;
        system)
            echo "✓ System installation complete"
            echo "  Library will be available globally"
            ;;
    esac
}

# Run tests
run_tests() {
    echo ""
    read -p "Run tests to verify installation? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        echo "Running tests..."
        cd "$PACKAGE_DIR"
        scryer-prolog tests/zenroom_basic.pl || echo "⚠ Some tests failed. Check Zenroom library is available."
    fi
}

# Print usage information
print_usage() {
    echo ""
    echo "========================================="
    echo "✅ Installation Complete!"
    echo "========================================="
    echo ""
    echo "Usage in Scryer Prolog:"
    echo ""
    echo "  ?- use_module(library(zenroom))."
    echo "  ?- zencode_exec(\"Given nothing\\nThen print 'test'\", \"\", \"\", O, _)."
    echo ""
    echo "Examples:"
    echo "  scryer-prolog examples/01_simple_output.pl"
    echo ""
    echo "Documentation:"
    echo "  See README.md and docs/ directory"
    echo ""
}

# Main installation flow
main() {
    detect_scryer
    get_install_dir
    build_zenroom
    install_files
    setup_environment
    run_tests
    print_usage
}

main "$@"
