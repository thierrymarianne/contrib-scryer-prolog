# Installation Guide

## Using Bakage Package Manager

### Prerequisites
- [Scryer Prolog](https://github.com/mthom/scryer-prolog) installed
- [Bakage](https://github.com/bakaq/bakage) package manager
- Build tools (for Zenroom library): `git`, `make`, C compiler

### Quick Install

**1. Install via Bakage:**

In your project, add to `scryer-manifest.pl`:

```prolog
dependencies([
    dependency("scryer-zenroom", git("https://github.com/yourusername/scryer-zenroom.git"))
]).
```

Then install:

```bash
./bakage.pl install
```

**2. Build Zenroom Library:**

```bash
cd scryer_libs/scryer-zenroom

# macOS
just install-zenroom-macos

# Linux
just install-zenroom-linux
```

**3. Use in Your Code:**

```prolog
:- use_module(bakage).
:- use_module(pkg('scryer-zenroom')).

main :-
    zencode_exec(
        "Given nothing\nThen print the 'string' 'Hello Zenroom!'",
        "", "", Output, _),
    writeln(Output),
    halt.
```

---

## Manual Installation

### 1. Clone Repository

```bash
git clone https://github.com/yourusername/scryer-zenroom.git
cd scryer-zenroom
```

### 2. Build Zenroom Library

Using Just (recommended):

```bash
# macOS
just install-zenroom-macos

# Linux  
just install-zenroom-linux
```

Or manually:

```bash
./scripts/build-zenroom.sh macos  # or linux
sudo cp build/libzenroom.* /usr/local/lib/
```

### 3. Install Package

**Option A: System-wide** (requires sudo)

```bash
sudo mkdir -p /usr/local/lib/scryer-prolog/scryer-zenroom
sudo cp lib/* /usr/local/lib/scryer-prolog/scryer-zenroom/
```

**Option B: User-local**

```bash
mkdir -p ~/scryer_libs/scryer-zenroom
cp lib/* ~/scryer_libs/scryer-zenroom/
```

Or use just:

```bash
just install-dev
```

### 4. Use in Code

```prolog
% If installed system-wide
:- use_module(library('scryer-zenroom/zenroom')).

% If installed in ~/scryer_libs (ensure it's in library path)
:- use_module('../lib/zenroom.pl').

main :- 
    zencode_exec("Given nothing\nThen print 'test'", "", "", O, _),
    writeln(O).
```

---

## Verifying Installation

Run the test suite:

```bash
just test
```

Expected output:
```
Running basic tests...
PASS: test_basic_zencode_exec
PASS: test_simple_output
...
========================================
Hash Tests Summary:
  Passed: 16
  Failed: 0
========================================
```

All 45 tests should pass.

---

## Platform-Specific Notes

### macOS

Requires Xcode Command Line Tools:

```bash
xcode-select --install
```

### Linux

Requires build essentials:

```bash
# Debian/Ubuntu
sudo apt-get install build-essential git

# Fedora/RHEL
sudo dnf install gcc make git

# Arch
sudo pacman -S base-devel git
```

---

## Troubleshooting

### Zenroom Library Not Found

If tests fail with "library not found":

```bash
# Check if library exists
ls -la /usr/local/lib/libzenroom.*

# If not, rebuild:
just install-zenroom-macos  # or linux
```

### Permission Denied

If installation fails due to permissions:

```bash
# Use user-local installation instead
just install-dev
```

### Build Failures

If Zenroom build fails:

```bash
# Clean and retry
just clean
just build-zenroom-macos  # or linux

# Check build log in build/zenroom-src/
```

---

## Development Setup

For contributing:

```bash
git clone https://github.com/yourusername/scryer-zenroom.git
cd scryer-zenroom
just install-zenroom-macos  # or linux
just test
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details.
