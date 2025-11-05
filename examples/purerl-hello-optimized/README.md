# Erlang Backend with Optimizer

This example demonstrates using `purescript-backend-optimizer` with the Erlang/purerl backend.

## The Power of Backend-Agnostic Optimization

The purescript-backend-optimizer is **backend-agnostic** - it optimizes CoreFn (PureScript's intermediate representation), not JavaScript. This means the **same optimizations benefit Erlang output!**

## How It Works

When you specify both optimizer and backend, purs-nix creates a three-stage pipeline:

```
PureScript Source
    ↓
purs compile --codegen corefn
    ↓
CoreFn (intermediate representation)
    ↓
purs-backend-es optimize  ← Aggressive inlining, TCO, etc.
    ↓
Optimized CoreFn
    ↓
purerl compile  ← Generate Erlang from optimized CoreFn
    ↓
.erl files (optimized!)
```

## Benefits for Erlang Backend

✅ **Better tail call optimization** - Inlining exposes more TCO opportunities
✅ **Reduced function call overhead** - Aggressive inlining eliminates abstraction penalties
✅ **Optimized pattern matching** - Redundant tests eliminated
✅ **Smaller .erl files** - Dead code eliminated at CoreFn level

## Configuration

```nix
# Backend generates Erlang
backend = {
  cmd = "purerl";
  package = purerl;
};

# Optimizer runs BEFORE backend
optimizer = {
  cmd = "purs-backend-es";
  package = backend-optimizer;
  args = [];  # Don't generate JS, just optimize
};
```

## Build Flow

```bash
# Build optimized Erlang output
nix build

# Inspect the generated .erl files
ls -la result/Main/

# Development shell
nix develop
```

## Performance Impact

The optimizer's impact on Erlang backend:

**Without Optimizer**:
- Standard PureScript compilation
- Each abstraction (map, fold, etc.) is a function call
- Pattern matching as written in source

**With Optimizer**:
- Aggressive inlining of small functions
- Abstractions like `exists` inlined → enables TCO
- Optimized pattern matching with test elimination
- Better code generation for purerl

## Example: TCO Improvement

```purescript
-- Your code
loop :: Int -> Boolean
loop n =
  if n > 1000000
  then true
  else exists (_ == n) someList || loop (n + 1)
```

**Without optimizer**: `exists` not inlined → no TCO → stack overflow
**With optimizer**: `exists` inlined → TCO detected → constant stack usage

## Per-Package Optimization

**Every dependency is optimized!** When you build:

```
Package "effect":
  purs → CoreFn → optimize → purerl → .erl (cached!)

Package "console":
  purs → CoreFn → optimize → purerl → .erl (cached!)

Your Main:
  Links optimized dependencies
  purs → CoreFn → optimize → purerl → .erl
```

Each package optimized once, cached forever.

## When to Use

✅ **Use optimizer with Erlang when**:
- Building production systems
- Performance-critical applications
- Large codebases with many abstractions
- Long-running processes (servers, agents)

❌ **Skip optimizer when**:
- Rapid prototyping
- Debugging (optimizations can obscure source)
- Small scripts

## Comparison

| Aspect | Standard purerl | With Optimizer |
|--------|----------------|----------------|
| Build time | Faster | Slower (first build) |
| Runtime performance | Good | Better (~25% typical) |
| .erl file size | Larger | Smaller |
| TCO cases | Standard | More cases |
| Abstraction cost | Present | Reduced/eliminated |

## See Also

- [JavaScript with Optimizer](../hello-world-optimized/) - Same optimizer with JavaScript backend
- [Optimizer Documentation](https://github.com/aristanetworks/purescript-backend-optimizer)
- [purerl Documentation](https://github.com/purerl/purerl)
