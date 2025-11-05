# PureScript Alternative Backends

This fork adds support for alternative PureScript backends (purerl, etc.) and optimizers (purs-backend-es, etc.) through a three-stage compilation architecture.

## Three-Stage Architecture

```
Stage 1: Source → CoreFn (per-package, cached)
Stage 2: CoreFn → Optimized CoreFn (optional, whole-project)
Stage 3: CoreFn → Backend Output (whole-project)
```

**Benefits:**
- **Per-package caching** at Stage 1 for fast incremental builds
- **Optional optimization** at Stage 2 for dead code elimination
- **Backend flexibility** at Stage 3 for JavaScript, Erlang, or custom targets

## Basic Usage

### Erlang Backend (purerl)

```nix
ps = purs-nix.purs {
  dependencies = [ "prelude" "effect" "console" ];

  backend = {
    package = purerl;  # Nix package
    cmd = "purerl";    # Command to run
  };

  # Use a custom package set for Erlang-specific packages
  package-set = import ./purerl-packages-locked.nix;

  dir = ./.;
};
```

### JavaScript with Optimizer

```nix
ps = purs-nix.purs {
  dependencies = [ "prelude" ];

  optimizer = {
    package = purs-backend-es;
    cmd = "purs-backend-es";
    args = [ "build" ];
  };

  dir = ./.;
};
```

### Both Optimizer and Backend

```nix
ps = purs-nix.purs {
  dependencies = [ "prelude" "effect" ];

  optimizer = {
    package = purs-backend-es;
    cmd = "purs-backend-es";
    args = [ "build" ];
  };

  backend = {
    package = purerl;
    cmd = "purerl";
  };

  package-set = import ./packages-locked.nix;

  dir = ./.;
};
```

## Configuration Options

### Backend Configuration

```nix
backend = {
  package = <derivation>;  # Nix package containing the backend compiler
  cmd = "<command>";       # Command name to execute
  args = [ ];              # Optional: Additional arguments (default: [])
}
```

### Optimizer Configuration

```nix
optimizer = {
  package = <derivation>;  # Nix package containing the optimizer
  cmd = "<command>";       # Command name to execute
  args = [ ];              # Optional: Additional arguments (default: [])
}
```

### Custom Package Sets

For backends like purerl that need custom packages:

```nix
# Locked format (pure evaluation, no --impure)
package-set = import ./packages-locked.nix;

# URL format (requires --impure)
package-set = {
  url = "https://raw.githubusercontent.com/purerl/package-sets/erl-0.15.3-20220629/packages.json";
  sha256 = "sha256-...";
};
```

## Locking Package Sets

For reproducible pure evaluation, lock package sets with resolved commit hashes:

```bash
# Generate locked package set
nix run .#lock-package-set -- \
  https://raw.githubusercontent.com/purerl/package-sets/erl-0.15.3-20220629/packages.json \
  purerl-packages-locked.nix

# Use in your flake
package-set = import ./purerl-packages-locked.nix;

# Build without --impure
nix build
```

## Foreign Function Interface (FFI)

### JavaScript FFI

```purescript
-- src/Main.purs
module Main where
foreign import greet :: String -> String
```

```javascript
// src/Main.js
export const greet = (name) => `Hello, ${name}!`;
```

### Erlang FFI

```purescript
-- src/Main.purs
module Main where
foreign import erlGreet :: String -> String
```

```erlang
%% src/Main.erl
-module(main@foreign).
-export([erlGreet/1]).

erlGreet(Name) ->
    <<"Hello from Erlang, ", Name/binary, "!">>.
```

## Examples

Complete working examples are in `tests/backends/`:

- **javascript/minimal** - Basic JS compilation
- **javascript/with-deps** - JS with dependencies
- **javascript/with-optimizer** - JS with purs-backend-es
- **javascript/with-ffi** - JS with foreign functions
- **erlang/minimal** - Basic Erlang compilation
- **erlang/with-deps** - Erlang with dependencies
- **erlang/with-erl-packages** - Erlang native bindings
- **erlang/with-ffi** - Erlang with foreign functions

## Build Artifacts

### JavaScript Output
- `.js` files in `output/` directory
- ESM modules by default

### Erlang Output
- `.erl` files in `output/` directory
- Erlang/OTP compatible modules
- Includes `.hrl` header files

## Performance

The three-stage architecture provides significant performance benefits:

- **First build**: All packages compile
- **After code change**: Only changed package rebuilds (Stage 1 cached)
- **After dependency change**: Optimizer and backend re-run (Stage 1 cached)

Example build times:
```
Full build:     prelude(3s) + effect(3s) + console(3s) + app(3s) = 12s
After change:   CACHED + CACHED + CACHED + app(3s) = 3s  (4x faster!)
```

## Backward Compatibility

All parameters are optional - existing JavaScript-only projects continue to work without changes:

```nix
# Standard purs-nix usage (no backend/optimizer)
ps = purs-nix.purs {
  dependencies = [ "prelude" "effect" ];
  dir = ./.;
};
```

## Supported Backends

Currently tested:
- **JavaScript** (default, no backend needed)
- **Erlang** (via purerl)

The architecture supports any backend that accepts CoreFn input. To add a new backend, provide a `backend` configuration with the appropriate compiler.

## Troubleshooting

### Pure Evaluation Errors

If you see errors about "not available in pure evaluation mode":
- Use locked package sets: `nix run .#lock-package-set`
- Or run with `--impure` flag (not recommended for production)

### Permission Denied

The three-stage architecture resolves permission issues automatically. If you encounter permission errors, ensure you're using a recent version of purs-nix.

### Missing Dependencies

If backend-specific packages aren't found:
- Verify your package set includes the required packages
- For purerl, use the purerl package set, not the standard registry
- Lock your package set for reproducibility

## Further Reading

- [Test Suite](../tests/README.md) - Complete working examples
- [Architecture Details](../PLAN.md) - Implementation notes
- [purerl Documentation](https://github.com/purerl/purescript) - Erlang backend
- [purs-backend-es](https://github.com/aristanetworks/purescript-backend-optimizer) - ES optimizer
