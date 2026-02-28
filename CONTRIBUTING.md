# Contributing to Scryer-Zenroom

Thank you for your interest in contributing to Scryer-Zenroom! This document provides guidelines and information for contributors.

## Development Philosophy

This project follows **Test-Driven Development (TDD)** methodology across 10 development cycles. We emphasize:

- ✅ Writing tests before implementation (Red-Green-Refactor)
- 📚 Clear, comprehensive documentation
- 🎯 Incremental, focused changes
- 🧪 High test coverage
- 🔍 Code review and collaboration

## Development Cycles

We're currently on **Cycle 1** (Foundation and Basic Execution). See the roadmap:

1. ✅ **Cycle 1:** Foundation and basic execution (COMPLETE)
2. 🚧 **Cycle 2:** Buffer management and error handling (NEXT)
3. 📅 **Cycle 3:** Extended execution parameters
4. 📅 **Cycle 4:** Validation predicates
5. 📅 **Cycles 5-6:** Cryptographic primitives
6. 📅 **Cycle 7:** Introspection
7. 📅 **Cycle 8:** High-level helpers
8. 📅 **Cycle 9:** JSON integration
9. 📅 **Cycle 10:** Documentation and release

## Getting Started

### Prerequisites

- Scryer Prolog (latest version recommended)
- Zenroom shared library
- Git
- Basic knowledge of Prolog and FFI concepts

### Setting Up Development Environment

1. **Fork and clone:**
   ```bash
   git fork https://github.com/your-org/scryer-zenroom
   git clone https://github.com/YOUR-USERNAME/scryer-zenroom
   cd scryer-zenroom
   ```

2. **Build Zenroom:**
   ```bash
   ./scripts/build-zenroom.sh
   ```

3. **Run tests:**
   ```bash
   scryer-prolog tests/zenroom_basic.pl
   ```

## Contribution Workflow

### 1. Pick an Issue or Cycle

- Check [open issues](https://github.com/your-org/scryer-zenroom/issues)
- Review the current development cycle
- Comment on the issue to claim it

### 2. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

Branch naming conventions:
- `feature/` - New features
- `bugfix/` - Bug fixes
- `docs/` - Documentation updates
- `test/` - Test improvements
- `cycle/N` - Development cycle work

### 3. Follow TDD

#### Red Phase
Write failing tests first:

```prolog
test_your_new_feature :-
    % Test that should fail initially
    your_new_predicate(Input, Output),
    Output = expected_value.
```

#### Green Phase
Implement the minimum code to pass:

```prolog
your_new_predicate(Input, Output) :-
    % Implementation
    ...
```

#### Refactor Phase
Improve code quality without breaking tests.

### 4. Write Documentation

- Add PlDoc comments to all public predicates
- Update README.md if adding user-facing features
- Add examples to `examples/` directory
- Update cycle documentation in `docs/`

### 5. Run Tests

```bash
# Run all tests
scryer-prolog tests/zenroom_basic.pl

# Add more test files as they're created
scryer-prolog tests/zenroom_*.pl
```

### 6. Commit Changes

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```bash
git commit -m "feat: add hash_data/3 predicate for one-step hashing"
git commit -m "test: add tests for SHA256 hashing"
git commit -m "docs: update API reference with hash predicates"
git commit -m "fix: correct buffer overflow in large outputs"
```

Commit types:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `test:` - Tests
- `refactor:` - Code refactoring
- `chore:` - Maintenance

### 7. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Create a PR with:
- **Title:** Clear, descriptive summary
- **Description:** What, why, and how
- **Tests:** Confirmation that all tests pass
- **Cycle:** Which cycle this contributes to

## Code Style Guidelines

### Prolog Style

1. **Indentation:** 4 spaces (no tabs)

2. **Predicate naming:**
   - Use `snake_case`
   - Be descriptive: `hash_data/3` not `hash/2`
   - Avoid abbreviations unless standard

3. **Documentation:**
   ```prolog
   %% predicate_name(+Arg1, -Arg2)
   %
   % Brief description.
   %
   % @param Arg1 Description of Arg1
   % @param Arg2 Description of Arg2
   %
   % ## Example
   % ```prolog
   % ?- predicate_name(input, Output).
   % ```
   ```

4. **Error handling:**
   - Use `must_be/2` for type checking
   - Throw descriptive errors with context
   - Validate inputs before FFI calls

5. **Module structure:**
   ```prolog
   :- module(module_name, [
       exported_predicate/N,
       ...
   ]).
   
   :- use_module(library(...)).
   
   % Public predicates
   
   % Private predicates
   ```

### Shell Script Style

1. **Shebang:** `#!/usr/bin/env bash`
2. **Safety:** `set -euo pipefail`
3. **Functions:** Clear, single-purpose functions
4. **Comments:** Explain non-obvious logic

## Testing Guidelines

### Test Structure

```prolog
% Test file: tests/feature_name.pl
:- use_module(library(zenroom)).

test_feature_basic :-
    % Setup
    Input = ...,
    % Execute
    your_predicate(Input, Output),
    % Assert
    Output = expected_value.

test_feature_edge_case :-
    % Test edge cases
    ...

run_tests :-
    catch(test_feature_basic, E, (write('FAIL: '), write(E), nl, fail)),
    write('PASS: test_feature_basic'), nl,
    ...
```

### Test Coverage

Aim for:
- **Core predicates:** 100% coverage
- **Helper predicates:** 90% coverage
- **Error paths:** 80% coverage

### What to Test

- ✅ Happy path (normal usage)
- ✅ Edge cases (empty inputs, large data)
- ✅ Error conditions (invalid inputs)
- ✅ Integration with other predicates
- ✅ Cross-platform compatibility

## Documentation Guidelines

### PlDoc Comments

Use comprehensive PlDoc for all exported predicates:

```prolog
%% zencode_exec(+Script, +Keys, +Data, -Output, -Errors)
%
% Execute a Zencode script with keys and data.
%
% Zencode is a domain-specific language...
%
% @param Script The Zencode script (atom, string, or char list)
% @param Keys JSON string with cryptographic keys
% @param Data JSON string with input data  
% @param Output JSON string with execution output
% @param Errors String with error messages
%
% @throws error(zenroom_library_not_found, _) if library missing
% @throws error(zenroom_execution_failed(Code), _) if execution fails
%
% ## Examples
%
% Simple execution:
% ```prolog
% ?- zencode_exec("Given nothing\nThen print 'test'", "", "", O, _).
% ```
```

### README Updates

When adding features:
1. Update "Features" section
2. Add to "API Overview"
3. Include in "Examples"
4. Update roadmap if completing a cycle

## Review Process

### For Contributors

1. Ensure all tests pass
2. Add tests for new functionality
3. Update documentation
4. Self-review your code
5. Respond to review feedback promptly

### For Reviewers

Focus on:
- ✅ Tests are comprehensive
- ✅ Code follows style guide
- ✅ Documentation is clear
- ✅ Changes align with current cycle
- ✅ No breaking changes (or properly noted)

## Reporting Issues

### Bug Reports

Include:
- **Description:** Clear description of the bug
- **Reproduction:** Steps to reproduce
- **Expected:** What should happen
- **Actual:** What actually happens
- **Environment:** OS, Scryer version, Zenroom version
- **Logs:** Error messages, stack traces

### Feature Requests

Include:
- **Use case:** Why is this needed?
- **Proposed solution:** How should it work?
- **Alternatives:** Other approaches considered
- **Cycle alignment:** Which cycle should include this?

## Communication

- **GitHub Issues:** Bug reports, feature requests
- **GitHub Discussions:** Questions, ideas, general discussion
- **Pull Requests:** Code review, implementation discussion

## Recognition

Contributors will be:
- Listed in README.md authors section
- Credited in release notes
- Acknowledged in commit messages

## Questions?

Feel free to:
- Open a GitHub Discussion
- Comment on relevant issues
- Reach out to maintainers

Thank you for contributing to Scryer-Zenroom! 🙏
