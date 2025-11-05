# Package Set Locking for Pure Evaluation

This guide explains how to use locked package sets with purs-nix for reproducible, pure evaluation builds with backend support.

## Overview

By default, when using URL-based package sets with git tags (like purerl), Nix requires `--impure` mode because it needs to resolve tags to commit hashes at evaluation time. Package set locking solves this by pre-resolving all git tags to commit hashes, enabling full pure evaluation.

### Benefits

- ✅ **Pure evaluation**: Build without `--impure` flag
- ✅ **Full reproducibility**: Exact commit hashes ensure identical builds
- ✅ **Binary cache compatibility**: Pure builds can be cached and shared reliably
- ✅ **Offline builds**: Once inputs are fetched, no network access needed
- ✅ **CI/CD friendly**: Works in restricted environments

## Quick Start

### 1. Generate a Locked Package Set

```bash
# Generate from a URL
nix run github:purs-nix/purs-nix#lock-package-set -- \
  https://raw.githubusercontent.com/purerl/package-sets/erl-0.15.3-20220629/packages.json \
  purerl-packages-locked.nix

# Or use the local version if you have purs-nix cloned
nix run .#lock-package-set -- <url> <output-file>
```

This will:
- Fetch the JSON package set
- Resolve each git tag to a commit hash using `git ls-remote`
- Generate a Nix expression with all commit hashes embedded
- Save it to `purerl-packages-locked.nix`

### 2. Use the Locked Package Set in Your Flake

```nix
{
  inputs.purs-nix.url = "github:purs-nix/purs-nix";

  outputs = { self, purs-nix, nixpkgs }:
    let
      system = "aarch64-darwin";  # or your system
      purs-nix-instance = purs-nix { inherit system; };

      ps = purs-nix-instance.purs {
        dependencies = [ "console" "effect" "prelude" ];

        backend = {
          cmd = "purerl";
          package = yourPurerlPackage;
        };

        # Use locked package set for pure evaluation
        package-set = import ./purerl-packages-locked.nix;

        dir = ./.;
      };
    in {
      packages.${system}.default = ps.output {};
    };
}
```

### 3. Build in Pure Mode

```bash
# No --impure flag needed!
nix build
```

## Updating Dependencies

When the package set changes (new package versions, new packages, etc.), refresh your locked file:

```bash
nix run github:purs-nix/purs-nix#refresh-package-set -- purerl-packages-locked.nix
```

This will:
- Read the source URL from the locked file
- Re-fetch the package set
- Resolve all tags again
- Show a diff of what changed
- Update the locked file

## Locked Package Set Format

The generated file is a Nix function that takes `self` and returns an attribute set of packages:

```nix
# Generated from: https://raw.githubusercontent.com/purerl/package-sets/...
# Generated at: 2025-11-04T14:42:47Z
# To refresh: nix run github:purs-nix/purs-nix#refresh-package-set -- <this-file>

self: {
  "console" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-console.git";
      rev = "abc123...";  # Resolved from tag v5.0.0-erl1
    };
    info = {
      version = "v5.0.0-erl1";
      dependencies = [ "effect" "prelude" ];
    };
  };

  "prelude" = {
    src.git = {
      repo = "https://github.com/purerl/purescript-prelude.git";
      rev = "def456...";  # Resolved from tag v5.0.1-erl1
    };
    info = {
      version = "v5.0.1-erl1";
      dependencies = [];
    };
  };

  # ... more packages ...
}
```

## Package Set Formats

purs-nix supports three package set formats:

### 1. Locked Nix Function (Recommended for Pure Evaluation)

```nix
package-set = import ./purerl-packages-locked.nix;
```

- ✅ Pure evaluation
- ✅ Fastest (no fetching during evaluation)
- ✅ Fully reproducible with commit hashes

### 2. URL-based JSON (Convenient but Impure)

```nix
package-set = {
  url = "https://raw.githubusercontent.com/purerl/package-sets/erl-0.15.3-20220629/packages.json";
  sha256 = "...";
};
```

- ❌ Requires `--impure` flag
- ✅ Simple to use
- ✅ Direct from source

### 3. Local JSON File

```nix
package-set = {
  file = ./packages.json;
};
```

- ❌ Requires `--impure` if using git tags
- ✅ Useful for development

## Troubleshooting

### Package Resolution Failures

Some packages may fail to resolve if they use commit hashes instead of tags in the `version` field:

```
Warning: Failed to resolve 4 packages:
  - datetime-parsing
  - simple-json
```

These packages are omitted from the locked set. If you need them:

1. Manually add the packages to your locked file with the correct commit hash
2. Or report the issue to the package set maintainers

### Refreshing Shows No Changes

If `refresh-package-set` shows no changes, the package set hasn't been updated. This is normal if the upstream package set is stable.

### Pure Mode Still Fails

If you get errors about accessing absolute paths in pure mode, check that:

1. Your `dir` parameter uses a relative path (`./.`) not an absolute path (`/some/path`)
2. All source files are within your flake directory

## Workflow Example

Here's a complete workflow for a PureScript Erlang project:

```bash
# 1. Initialize your project
mkdir my-purerl-project && cd my-purerl-project
git init

# 2. Create your flake.nix with backend configuration
cat > flake.nix << 'EOF'
{
  inputs.purs-nix.url = "github:purs-nix/purs-nix";
  # ... rest of flake
}
EOF

# 3. Generate locked package set
nix run github:purs-nix/purs-nix#lock-package-set -- \
  https://raw.githubusercontent.com/purerl/package-sets/erl-0.15.3-20220629/packages.json \
  purerl-packages-locked.nix

# 4. Update flake to use locked package set
# (Edit flake.nix to set package-set = import ./purerl-packages-locked.nix)

# 5. Build in pure mode
nix build

# 6. Later, when you want to update packages
nix run github:purs-nix/purs-nix#refresh-package-set -- purerl-packages-locked.nix

# 7. Commit the locked file
git add purerl-packages-locked.nix
git commit -m "Add/update locked package set"
```

## Migration Guide

### From Impure URL-based Package Sets

**Before** (requires `--impure`):
```nix
package-set = {
  url = "https://raw.githubusercontent.com/purerl/package-sets/.../packages.json";
  sha256 = "...";
};
```

**After** (pure evaluation):
```nix
# 1. Generate locked file once
# nix run github:purs-nix/purs-nix#lock-package-set -- <url> packages-locked.nix

# 2. Update flake
package-set = import ./packages-locked.nix;
```

### From Spago with Vendored Dependencies

**Before** (spago with .spago/ directory):
```bash
spago build --offline  # Uses vendored .spago/ (82MB)
```

**After** (purs-nix with locked package set):
```bash
nix build  # Pure evaluation, per-package caching, no vendored directory
```

Benefits:
- No 82MB `.spago/` directory in git
- Per-package caching (only changed packages rebuild)
- Truly reproducible builds with commit hashes
- Works in pure Nix environments

## Technical Details

### How Tag Resolution Works

The locking script uses `git ls-remote` to resolve tags:

```bash
git ls-remote https://github.com/purerl/purescript-prelude.git refs/tags/v5.0.1-erl1
# Returns: abc123... refs/tags/v5.0.1-erl1
```

This commit hash is then embedded in the locked file for pure evaluation.

### Pure vs Impure Evaluation

**Impure Mode** (`nix build --impure`):
- Nix can access network during evaluation
- Git tags resolved on-the-fly
- Different evaluations might get different commit hashes if tags move
- Required for URL-based package sets with tags

**Pure Mode** (`nix build`):
- No network access during evaluation
- All inputs must be fully specified with hashes
- Guarantees reproducibility
- Required for binary caching and offline builds
- Enabled by locked package sets

## See Also

- [Erlang Backend Support](./erlang-backend.md) - Full guide to backend configuration
- [purs-nix Documentation](https://github.com/purs-nix/purs-nix) - Main purs-nix docs
- [Nix Flakes](https://nixos.wiki/wiki/Flakes) - Understanding Nix flakes
- [PureRL Package Sets](https://github.com/purerl/package-sets) - PureScript Erlang packages

## Contributing

Found an issue or have a suggestion? Please report it at:
https://github.com/purs-nix/purs-nix/issues
