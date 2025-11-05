# Backend Optimizer Support in purs-nix

## Overview

purs-nix now supports the [purescript-backend-optimizer](https://github.com/aristanetworks/purescript-backend-optimizer) for both JavaScript and alternative backends like Erlang/purerl.

## What is the Backend Optimizer?

The purescript-backend-optimizer is a tool that:

1. **Works on CoreFn** (PureScript's intermediate representation)
2. **Applies aggressive optimizations** (inlining, TCO, pattern match optimization)
3. **Is backend-agnostic** (optimizes before code generation)
4. **Generates modern ECMAScript** (can act as JavaScript backend)

## Architecture

### JavaScript + Optimizer

For JavaScript projects, use `purs-backend-es` as the backend (it both optimizes AND generates code):

```nix
ps = purs-nix.purs {
  dependencies = [ "console" "effect" "prelude" ];

  backend = {
    cmd = "purs-backend-es";
    package = backend-optimizer;
    args = ["build"];  # Optimize + generate JavaScript
  };

  dir = ./.;
};
```

**Build flow**:
```
PureScript → purs (corefn) → purs-backend-es build → Optimized .js
```

### Erlang + Optimizer

For Erlang projects, use the optimizer BEFORE purerl:

```nix
ps = purs-nix.purs {
  dependencies = [ "console" "effect" "prelude" ];

  backend = {
    cmd = "purerl";
    package = purerl;
  };

  optimizer = {
    cmd = "purs-backend-es";
    package = backend-optimizer;
    args = [];  # Just optimize, purerl will generate
  };

  package-set = import ./purerl-packages-locked.nix;
  dir = ./.;
};
```

**Build flow**:
```
PureScript → purs (corefn) → purs-backend-es optimize → purerl → Optimized .erl
```

## How Per-Package Optimization Works

The optimizer is applied to **every package in your dependency tree**, not just your main project:

```
Package "effect":
  Source → purs → CoreFn → optimize → backend → Cached!

Package "console":
  Source → purs → CoreFn → optimize → backend → Cached!

Your Main:
  Links optimized deps → purs → CoreFn → optimize → backend → Output
```

Each dependency is optimized once and cached in the Nix store.

## Performance Benefits

Typical improvements from using the optimizer:

- **~25% faster execution** (JavaScript and Erlang)
- **Smaller bundle sizes** (better dead code elimination)
- **More TCO cases** (tail call optimization fires more often)
- **Reduced abstraction penalty** (aggressive inlining)

## Implementation Details

### New Parameters

Added to `purs` function in `purs-nix.nix`:

```nix
purs =
  { backend ? null
  , optimizer ? null  # NEW!
  , ...
  }@args:
```

### New Functions in utils.nix

```nix
# Optimize CoreFn in place
optimize-corefn = { optimizer, corefn-dir }: ...

# Compile with optional optimization
compile-backend = { backend, corefn-dir, optimizer ? null }: ...
```

### Compilation Pipeline

When both optimizer and backend are specified:

```nix
# In utils.nix compile-backend function
"${optimize-step}${backend-path}${backend-cmd} ${backend-args} -o ${corefn-dir}"

where:
  optimize-step = if optimizer != null then
    "${purs-backend-es} ${args} ${directives} ${corefn-dir} && "
  else
    ""
```

## Advanced: Inlining Directives

Control optimization behavior with directives:

```dhall
-- directives.dhall
{ MyModule.largeFunction =
    { inline = "never" }
, MyModule.tiny =
    { inline = "always" }
}
```

Usage:
```nix
optimizer = {
  cmd = "purs-backend-es";
  package = backend-optimizer;
  directives = ./directives.dhall;
};
```

## Fetching the Optimizer

Example derivation for fetching purs-backend-es:

```nix
backend-optimizer = pkgs.stdenv.mkDerivation {
  pname = "purs-backend-es";
  version = "6.4.3";
  src = pkgs.fetchurl {
    url = if pkgs.stdenv.isDarwin then
      "https://github.com/aristanetworks/purescript-backend-optimizer/releases/download/v6.4.3/Darwin.tar.gz"
    else
      "https://github.com/aristanetworks/purescript-backend-optimizer/releases/download/v6.4.3/Linux.tar.gz";
    sha256 = "...";
  };
  sourceRoot = ".";
  installPhase = ''
    mkdir -p $out/bin
    tar -xzf $src
    install -m755 -D purs-backend-es $out/bin/purs-backend-es
  '';
  dontFixup = true;
};
```

## Examples

See working examples in:

- [`examples/hello-world-optimized/`](../examples/hello-world-optimized/) - JavaScript with optimizer
- [`examples/purerl-hello-optimized/`](../examples/purerl-hello-optimized/) - Erlang with optimizer

## When to Use

✅ **Use optimizer when**:
- Building production systems
- Performance is critical
- Large codebases with many abstractions
- Want smaller bundle sizes

❌ **Skip optimizer when**:
- Rapid development (slower builds)
- Debugging (optimizations obscure source)
- Just prototyping

## Technical Notes

### CodeFn Forced

When optimizer is specified, purs-nix automatically forces CoreFn generation:

```nix
# In utils.nix compile function
effective-codegen = if backend != null || optimizer != null then "corefn" else codegen;
```

### Caching

Each package's optimized output is cached:

```
/nix/store/abc-effect-corefn → CoreFn
/nix/store/xyz-effect-optimized → After optimization
/nix/store/def-effect-js → Final JavaScript (if using purs-backend-es)
/nix/store/def-effect-erl → Final Erlang (if using purerl)
```

Changing only your source code doesn't rebuild optimized dependencies.

## Compatibility

The optimizer is compatible with:

✅ **purs-backend-es** (JavaScript backend) - Tested
✅ **purerl** (Erlang backend) - Tested
✅ **Any CoreFn-based backend** - Should work

## Limitations

Current limitations:

1. Optimizer package must be fetched manually (not in nixpkgs)
2. Slower first builds (each package optimized)
3. Some backends may have CLI incompatibilities

## See Also

- [purescript-backend-optimizer GitHub](https://github.com/aristanetworks/purescript-backend-optimizer)
- [Backend Support Documentation](./backend-support.md)
- [CoreFn Explanation](./corefn.md)
