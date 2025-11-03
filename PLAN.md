# Erlang Backend Support for purs-nix

## Goal
Add Erlang backend support to purs-nix while maintaining its core benefits:
- Nix-managed dependencies (no spago downloads)
- Proper build caching for each package
- Deterministic builds
- Clean separation between dependency management and compilation

## Current State Analysis

### How PureScript Erlang Projects Currently Work
- Use `spago` with `backend = "purerl"` in `spago.dhall`
- Use purerl-specific package sets from https://github.com/purerl/package-sets
- Compilation flow: `purs compile --codegen corefn` → `purerl` → `.erl` files
- Nix environment includes multiple overlays:
  - `nixpkgs-nixerl` for Erlang toolchain
  - `nixpkgs-purerl` for purerl compiler
  - `easy-purescript-nix` for PureScript tooling

### What purs-nix Provides
- Direct dependency management through Nix package sets
- Cached compilation of each package as separate derivations
- No network calls during build (everything pre-fetched)
- Thin wrapper around `purs compile` with proper dependency resolution

## Implementation Plan

### Phase 1: Core Backend Compilation Support

#### 1.1 Extend `compile` function in `utils.nix`
```nix
compile = 
  purescript:
  { globs
  , output ? null
  , backend ? null  # NEW: backend configuration
  , verbose-errors ? false
  , comments ? false
  , codegen ? null
  , no-prefix ? false
  , json-errors ? false
  }:
```

**Key changes:**
- Add `backend` parameter accepting backend configuration
- When backend is specified, force `--codegen corefn` (required for backends)
- Add backend compilation step after purs compilation
- Handle different output file types (`.erl` vs `.js`)

#### 1.2 Backend Configuration Structure
```nix
backend = {
  cmd = "purerl";           # Backend compiler command
  args = [];                # Optional additional args
  outputExt = ".erl";       # Output file extension
};
```

### Phase 2: Package Set Integration

#### 2.1 Backend-Aware Package Resolution
- Modify package set loading to support backend-specific sets
- Add purerl package set integration
- Ensure dependency resolution works with Erlang-specific packages

#### 2.2 Package Set Configuration
```nix
ps = purs-nix.purs {
  dependencies = [ "console" "erl-process" "erl-atom" ];
  backend = {
    cmd = "purerl";
    packageSet = "https://github.com/purerl/package-sets/releases/download/erl-0.15.3-20220629/packages.dhall";
  };
  dir = ./.;
};
```

### Phase 3: Build Pipeline Extensions

#### 3.1 Backend-Aware Bundling
- Extend `bundle` function to handle Erlang outputs
- Create Erlang-specific bundling logic (if applicable)
- Handle different runtime requirements

#### 3.2 Backend-Aware Running
- Extend `run` commands to work with Erlang outputs
- Add Erlang VM execution support
- Handle different argument passing

### Phase 4: Environment Integration

#### 4.1 Overlay Integration
- Include necessary overlays (nixerl, purerl) in purs-nix
- Make backend toolchain available automatically
- Ensure version compatibility

#### 4.2 Development Tooling
- Ensure IDE support works (JSON errors, etc.)
- Add backend-specific REPL support if available
- Maintain existing development workflow

## Test Case: id3as/demo-ps

We'll use the id3as/demo-ps project as our test case because:
- Real-world PureScript Erlang application with modern setup
- **Already uses purs-nix for client** - we just need to extend it for server
- Uses Spago Next (0.93.x) with spago.yaml and `workspace.backend.cmd`
- Well-documented and actively maintained
- Complete Nix flake with reproducible builds

### Current State Analysis
**✅ What works well:**
- Client: Using purs-nix with proper caching and Nix-native builds
- Server: Uses spago with vendored `.spago/` (82MB) for reproducibility
- Complete deployment: Full Nix derivation with Erlang/OTP runtime
- Modern tooling: Spago Next, flake.nix, process-compose

**❌ What we can improve:**
- Server still uses spago: Missing purs-nix benefits (per-package caching)
- Mixed approach: Client uses purs-nix, server uses spago
- Vendored dependencies: 82MB checked into git instead of Nix caching
- Rebuild inefficiency: Server rebuilds everything on any change

### Test Goals
1. **Extend purs-nix** to support `workspace.backend.cmd: purerl` configuration
2. **Convert server** from spago to purs-nix while maintaining functionality
3. **Eliminate vendored .spago/** - use Nix dependency management instead
4. **Enable per-package caching** for Erlang backend builds
5. **Maintain compatibility** with existing Erlang toolchain and workflow

### Success Criteria
- Server uses purs-nix with `backend = { cmd = "purerl"; }` configuration
- Per-package caching: Only changed packages rebuild
- No vendored dependencies: Remove 82MB `.spago/` directory
- Same build outputs: Identical `.erl` files and functionality
- Development workflow preserved: IDE, REPL, hot reloading
- Build time improvement: Faster incremental builds

## Lessons Learned from demo-ps

### Their Successful Patterns
1. **Overlay integration**: Uses `purescript-overlay` for PureScript tooling
2. **Binary fetching**: Downloads purerl binary from GitHub releases
3. **Mixed approach**: purs-nix for client, spago for server
4. **Vendored deps**: Checks in `.spago/` directory for reproducibility
5. **Modern spago**: Uses spago.yaml with `workspace.backend.cmd: purerl`

### Key Insights
1. **Configuration format**: They use the exact spago.yaml format we want to support
2. **Package sets**: Server uses purerl package set, client uses registry
3. **Build pipeline**: `spago build --offline` → purerl generates `.erl` files
4. **Integration**: Copy compiled outputs to rebar3 source directory

### What We Can Improve
1. **Unified approach**: Both client and server use purs-nix
2. **No vendored deps**: Nix manages all dependencies
3. **Better caching**: Per-package builds instead of monolithic
4. **Cleaner config**: Single purs-nix configuration for both targets

## Implementation Strategy

### Step 1: Analysis and Setup ✅
- Clone id3as/demo-ps to our workspace ✅
- Analyze current build structure ✅  
- Understand spago.yaml backend configuration ✅
- Document current approach and improvements needed ✅

### Step 2: Basic Backend Support ✅
- Add `backend` parameter to purs-nix configuration ✅
- Extend `compile` function in `utils.nix` for backend support ✅
- Add purerl overlay integration to purs-nix ✅
- Test basic compilation with simple example ✅

### Step 3: Package Set Integration  
- Add support for purerl package sets (URL-based)
- Ensure proper dependency resolution with Erlang packages
- Test compilation with demo-ps server dependencies
- Verify `.erl` output generation

### Step 4: Configuration Interface
- Design clean purs-nix API for backend configuration
- Support both registry and custom package sets
- Maintain backwards compatibility for JS-only projects
- Add proper error handling and validation

### Step 5: Full Integration Testing
- Convert demo-ps server from spago to purs-nix
- Remove vendored `.spago/` directory
- Verify identical build outputs and functionality
- Measure build time improvements

### Step 6: Polish and Documentation
- Clean up configuration interface
- Add comprehensive documentation
- Create migration guide from spago to purs-nix
- Submit upstream to purs-nix project

## Benefits of This Approach

✅ **Maintains purs-nix advantages:**
- Nix dependency management
- Build caching
- Deterministic builds
- No spago downloads

✅ **Adds Erlang backend support:**
- Native purerl integration
- Proper package set support
- Backend-aware compilation

✅ **Backwards compatible:**
- No breaking changes for JS projects
- Opt-in backend support
- Clean configuration interface

✅ **Future extensible:**
- Framework for other backends
- Clean separation of concerns
- Maintainable architecture

## Next Steps
1. Clone id3as/demo-ps project
2. Analyze current build structure
3. Begin Phase 1 implementation
4. Test with simple examples
5. Iterate based on findings