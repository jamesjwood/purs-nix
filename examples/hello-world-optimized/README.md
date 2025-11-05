# Hello World with Backend Optimizer

This example demonstrates using `purescript-backend-optimizer` with purs-nix for optimized JavaScript output.

## What is purescript-backend-optimizer?

The [purescript-backend-optimizer](https://github.com/aristanetworks/purescript-backend-optimizer) is a tool that:

1. **Optimizes at the CoreFn level** (backend-agnostic)
2. **Applies aggressive inlining** (more than standard purs)
3. **Generates modern ECMAScript** (ESM modules)
4. **Enables better TCO** (tail call optimization in more cases)

## Performance Benefits

- **~25% faster execution** (typical improvement)
- **Smaller bundle sizes** (better dead code elimination)
- **Better runtime performance** (optimized pattern matching)

## How It Works

When you specify the backend optimizer, purs-nix:

1. Compiles PureScript to CoreFn (`purs compile --codegen corefn`)
2. Runs optimizer on CoreFn (`purs-backend-es build`)
3. Generates optimized modern JavaScript
4. Caches each package's optimized output

**Every dependency gets optimized too!** Each package in your dependency tree is optimized once and cached.

## Usage

```nix
backend = {
  cmd = "purs-backend-es";
  package = backend-optimizer;
  args = ["build"];  # Optimize and generate JavaScript
};
```

## Build

```bash
# Build optimized output
nix build

# Run the optimized application
nix run

# Development shell with optimizer available
nix develop
```

## Comparison with Standard Build

**Standard (hello-world)**:
- `purs compile` → JavaScript directly
- Standard compiler optimizations
- CommonJS or ES modules

**Optimized (this example)**:
- `purs compile --codegen corefn` → CoreFn
- `purs-backend-es build` → Optimized modern ECMAScript
- Aggressive inlining and optimization
- Modern ES modules only

## Inlining Directives (Advanced)

You can control optimization behavior with directives:

```dhall
-- directives.dhall
{ MyModule.expensiveFunction =
    { inline = "never" }
, MyModule.smallHelper =
    { inline = "always" }
}
```

Then use it:
```nix
optimizer = {
  cmd = "purs-backend-es";
  package = backend-optimizer;
  directives = ./directives.dhall;
};
```

## When to Use Optimizer

✅ **Use optimizer when**:
- You need maximum runtime performance
- You want smaller bundle sizes
- You're deploying to production
- You have complex PureScript code with many abstractions

❌ **Don't use optimizer when**:
- You're doing rapid development (slower builds)
- You need debugging (optimizations can obscure stack traces)
- You're just prototyping

## See Also

- [Erlang with Optimizer](../purerl-hello-optimized/) - Same optimizer with Erlang backend
- [Optimizer Documentation](https://github.com/aristanetworks/purescript-backend-optimizer)
