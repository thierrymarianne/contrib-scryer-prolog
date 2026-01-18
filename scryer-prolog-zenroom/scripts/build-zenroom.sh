#!/usr/bin/env bash
# Build Zenroom shared library from source
set -euo pipefail

PLATFORM="${1:-$(uname -s | tr '[:upper:]' '[:lower:]')}"
BUILD_DIR="build"
ZENROOM_REPO="https://github.com/dyne/Zenroom.git"
ZENROOM_DIR="${BUILD_DIR}/zenroom-src"

echo "Building Zenroom for platform: ${PLATFORM}"

# Create build directory
mkdir -p "${BUILD_DIR}"

# Clone or update Zenroom repository
if [ ! -d "${ZENROOM_DIR}" ]; then
    echo "Cloning Zenroom repository..."
    git clone --depth 1 "${ZENROOM_REPO}" "${ZENROOM_DIR}"
else
    echo "Zenroom repository exists, updating..."
    cd "${ZENROOM_DIR}"
    git fetch origin
    git reset --hard origin/master
    cd -
fi

# Build for the specified platform
cd "${ZENROOM_DIR}"

case "${PLATFORM}" in
    macos|darwin)
        echo "Building for macOS..."
        make clean || true
        make osx
        if [ -f "src/libzenroom.dylib" ]; then
            cp src/libzenroom.dylib "../../libzenroom.dylib"
            echo "✓ Built: ${BUILD_DIR}/libzenroom.dylib"
        else
            echo "✗ Build failed: libzenroom.dylib not found"
            exit 1
        fi
        ;;
    linux)
        echo "Building for Linux..."
        make clean || true
        make linux
        if [ -f "src/libzenroom.so" ]; then
            cp src/libzenroom.so "../../libzenroom.so"
            echo "✓ Built: ${BUILD_DIR}/libzenroom.so"
        else
            echo "✗ Build failed: libzenroom.so not found"
            exit 1
        fi
        ;;
    *)
        echo "✗ Unsupported platform: ${PLATFORM}"
        echo "Supported platforms: macos, linux"
        exit 1
        ;;
esac

cd ../..
echo ""
echo "Zenroom library built successfully!"
echo "To install system-wide, run:"
if [ "${PLATFORM}" = "macos" ] || [ "${PLATFORM}" = "darwin" ]; then
    echo "  sudo cp ${BUILD_DIR}/libzenroom.dylib /usr/local/lib/"
else
    echo "  sudo cp ${BUILD_DIR}/libzenroom.so /usr/local/lib/"
fi
