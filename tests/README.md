# PureScript Backend Tests

This directory contains tests for the three-stage architecture that supports multiple PureScript backends (JavaScript, Erlang, etc.) with optional optimization.

## Architecture

Three-stage compilation:
1. **Stage 1**: Source → CoreFn (per-package, highly cacheable)
2. **Stage 2**: CoreFn → Optimized CoreFn (whole-project, optional)
3. **Stage 3**: CoreFn → Backend output (whole-project)

## Test Organization

### `backends/javascript/`

- **minimal/** - Single file, no dependencies, standard JS compilation
- **with-deps/** - Tests dependency resolution (prelude, effect, console, arrays)
- **with-optimizer/** - Tests purs-backend-es optimizer (dead code elimination)
- **with-ffi/** - Tests JavaScript foreign function interface (FFI)

### `backends/erlang/`

- **minimal/** - Single file, no dependencies, basic Erlang backend
- **with-deps/** - Tests dependency resolution with Erlang backend
- **with-erl-packages/** - Tests Erlang-specific packages (erl-lists, erl-atom)
- **with-ffi/** - Tests Erlang foreign function interface (FFI)

## Running Tests

Each test is a standalone Nix flake:

```bash
# Build a specific test
cd tests/backends/javascript/with-deps
nix build

# Check the output
ls -la result/
```

## Test Coverage

✅ **JavaScript minimal** - Verifies basic JS compilation
✅ **JavaScript with dependencies** - Verifies package resolution works
✅ **JavaScript with optimizer** - Verifies purs-backend-es integration
✅ **JavaScript with FFI** - Verifies foreign function interface works
✅ **Erlang minimal** - Verifies basic Erlang backend
✅ **Erlang with dependencies** - Verifies package resolution for Erlang
✅ **Erlang with erl-packages** - Verifies Erlang-specific bindings work
✅ **Erlang with FFI** - Verifies Erlang foreign function interface works

## Key Findings

1. **Dependency Resolution**: Standard PureScript packages (prelude, effect, console, arrays) work with both JS and Erlang backends
2. **Optimization**: purs-backend-es successfully optimizes code, eliminating dead code (e.g., `compose identity identity 42` → `42`)
3. **Erlang Bindings**: Native Erlang types and functions (erl-lists, erl-atom) integrate correctly
4. **FFI Works**: Foreign function interfaces work correctly for both JavaScript and Erlang backends
5. **Caching**: Stage 1 (CoreFn) is per-package for optimal caching; Stages 2-3 are whole-project

## Future Work

- **Optimizer + Dependencies**: Integration of purs-backend-es with full dependency resolution
- **Multi-module projects**: Tests with multiple source files and internal modules
- **Foreign Functions**: Tests with FFI (foreign imports)
- **Additional Backends**: Tests for other backends as they become available
