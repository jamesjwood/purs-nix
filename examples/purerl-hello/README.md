# PureScript Erlang Hello World

This example demonstrates how to use purs-nix with the PureScript-to-Erlang backend (purerl).

## Features

- ✅ **Pure evaluation**: Builds without `--impure` flag
- ✅ **Locked package set**: Fully reproducible with commit hashes
- ✅ **Per-package caching**: Only changed packages rebuild
- ✅ **Backend compilation**: Generates `.erl` files automatically

## Quick Start

### 1. Generate Locked Package Set

First, generate a locked package set for reproducible builds:

```bash
nix run github:purs-nix/purs-nix#lock-package-set -- \
  https://raw.githubusercontent.com/purerl/package-sets/erl-0.15.3-20220629/packages.json \
  purerl-packages-locked.nix
```

This resolves all git tags to commit hashes for pure evaluation.

### 2. Build

```bash
nix build
```

No `--impure` flag needed! The build will:
1. Fetch all dependencies using commit hashes
2. Compile PureScript to CoreFn
3. Run purerl to generate `.erl` files

### 3. Check Output

```bash
ls result/Main/
# Output:
# corefn.json  externs.cbor  main.hrl  main@foreign.hrl  main@ps.erl
```

The `.erl` files can be compiled with Erlang and run on the BEAM VM.

## Development

Enter the development environment:

```bash
nix develop
```

This provides:
- PureRL compiler
- Erlang/OTP runtime
- Helper scripts

## Updating Dependencies

When the package set changes, refresh your locked file:

```bash
nix run github:purs-nix/purs-nix#refresh-package-set -- purerl-packages-locked.nix
```

This will:
- Re-fetch the package set
- Resolve all tags again
- Show a diff of changes
- Update the locked file

## How It Works

### flake.nix

The flake configuration:

```nix
backend = {
  cmd = "purerl";           # Backend compiler to use
  package = purerl;          # Nix package providing purerl
};

# Use locked package set for pure evaluation
package-set = import ./purerl-packages-locked.nix;
```

### Locked Package Set

The `purerl-packages-locked.nix` file contains:

```nix
self: {
  "console" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-console.git";
      rev = "abc123...";  # Exact commit hash
    };
    info = {
      version = "v5.0.0-erl1";
      dependencies = [ "effect" "prelude" ];
    };
  };
  # ... more packages
}
```

All git tags are pre-resolved to commit hashes, enabling pure evaluation.

## See Also

- [Package Set Locking Guide](../../docs/package-set-locking.md) - Full documentation
- [purs-nix Documentation](https://github.com/purs-nix/purs-nix) - Main docs
- [PureRL](https://github.com/purerl/purerl) - PureScript-to-Erlang compiler
- [PureRL Package Sets](https://github.com/purerl/package-sets) - Available packages
