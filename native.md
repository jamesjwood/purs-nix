# purescript-native Backend Implementation - INCOMPATIBLE

Research into adding purescript-native (psgo/pscpp) backends.

**Status**: ❌ Not Compatible
**Started**: 2025-11-06
**Concluded**: 2025-11-06
**Result**: purescript-native is **incompatible** with modern PureScript tooling

---

## Executive Summary

**purescript-native cannot be integrated** with modern purs-nix due to fundamental compatibility issues:

1. **Compiler Coupling**: Tightly coupled to PureScript compiler internals (not CoreFn)
2. **Unmaintained**: Last updated March 2023 (Go), December 2020 (C++)
3. **API Breakage**: Built for PureScript 0.13.x, incompatible with 0.15.x
4. **No Prebuilt Binaries**: Must compile from source, which fails with modern tooling

### Why It Doesn't Work

```
Error: Could not find module 'Language.PureScript.Constants'
Perhaps you meant: Language.PureScript.Constants.TH
```

- purescript-native imports internal compiler modules directly
- PureScript 0.14+ refactored internal APIs (e.g., split `Constants` into `Constants.TH` and `Constants.Libs`)
- purescript-native hasn't been updated to track these changes
- Requires extensive patching or pinning to old PureScript version (breaks other packages)

### Recommendation

**Do not use purescript-native.** Instead:
- ✅ Use **purerl** for Erlang backend (actively maintained, works great)
- ✅ Use **purs-backend-erl** for alternative Erlang backend (npm-based)
- ✅ Wait for community to create modern native backends using stable CoreFn format

---

## Detailed Findings

Below is the research and attempted implementation for reference.

## Implementation Checklist

### Phase 1: Add Backend Tools to tools.nix

- [x] **1.1 Add psgo (Go backend)**
  - [x] Fetch purescript-native Go branch from GitHub
  - [x] Build Haskell binary using callCabal2nix
  - [x] Support Darwin (macOS) platform
  - [x] Get correct source hash
  - [ ] Verify build succeeds

- [x] **1.2 Add pscpp (C++ backend)**
  - [x] Fetch purescript-native C++ branch from GitHub
  - [x] Build Haskell binary using callCabal2nix
  - [x] Support Darwin (macOS) platform
  - [x] Get correct source hash
  - [ ] Verify build succeeds

### Phase 2: Create Test Structure

- [ ] **2.1 Create test directory structure**
  ```
  tests/backends/native/
  ├── go/
  │   ├── minimal/
  │   ├── with-deps/
  │   ├── with-optimizer/
  │   └── with-ffi/
  └── cpp/
      ├── minimal/
      ├── with-deps/
      ├── with-optimizer/
      └── with-ffi/
  ```

- [ ] **2.2 Implement go/minimal test**
  - [ ] flake.nix
  - [ ] src/Main.purs

- [ ] **2.3 Implement go/with-deps test**
  - [ ] flake.nix with dependencies
  - [ ] src/Main.purs

- [ ] **2.4 Implement go/with-optimizer test**
  - [ ] flake.nix with purs-backend-es
  - [ ] src/Main.purs

- [ ] **2.5 Implement go/with-ffi test**
  - [ ] flake.nix
  - [ ] src/Main.purs
  - [ ] src/Main.go (FFI)

- [ ] **2.6 Implement cpp/minimal test**
  - [ ] flake.nix
  - [ ] src/Main.purs

- [ ] **2.7 Implement cpp/with-deps test**
  - [ ] flake.nix with dependencies
  - [ ] src/Main.purs

- [ ] **2.8 Implement cpp/with-optimizer test**
  - [ ] flake.nix with purs-backend-es
  - [ ] src/Main.purs

- [ ] **2.9 Implement cpp/with-ffi test**
  - [ ] flake.nix
  - [ ] src/Main.purs
  - [ ] src/Main.cpp (FFI)

### Phase 3: Create Locked Package Sets

- [ ] **3.1 Research go-ffi package set**
  - [ ] Check official purescript-native package set
  - [ ] Document which packages work with Go backend

- [ ] **3.2 Generate go-packages-locked.nix**
  - [ ] Use `nix run .#lock-package-set`
  - [ ] Start with minimal working packages
  - [ ] Document unsupported packages

- [ ] **3.3 Create cpp-packages-locked.nix**
  - [ ] Same process for C++ backend

### Phase 4: Create Examples

- [ ] **4.1 examples/psgo-hello/**
  - [ ] flake.nix
  - [ ] src/Main.purs
  - [ ] README.md

- [ ] **4.2 examples/psgo-hello-optimized/**
  - [ ] flake.nix with optimizer
  - [ ] src/Main.purs
  - [ ] README.md

- [ ] **4.3 examples/pscpp-hello/**
  - [ ] flake.nix
  - [ ] src/Main.purs
  - [ ] README.md

### Phase 5: Documentation

- [ ] **5.1 Update README.md**
  - [ ] Add purescript-native to alternatives section
  - [ ] Link to examples

- [ ] **5.2 Create docs/backends/purescript-native.md**
  - [ ] Architecture explanation
  - [ ] Usage for psgo and pscpp
  - [ ] FFI conventions
  - [ ] Package set limitations
  - [ ] Optimizer integration
  - [ ] Known limitations

- [ ] **5.3 Update docs/backends.md**
  - [ ] Add psgo section
  - [ ] Add pscpp section
  - [ ] Configuration examples

### Phase 6: Integration with tests.nix

- [ ] **6.1 Add test definitions**
  - [ ] native-go-minimal
  - [ ] native-go-with-deps
  - [ ] native-go-with-optimizer
  - [ ] native-cpp-minimal
  - [ ] native-cpp-with-deps

### Phase 7: Verification

- [ ] **7.1 Build tests**
  - [ ] Run `nix flake check`
  - [ ] Verify all tests build
  - [ ] Fix any build errors

- [ ] **7.2 Manual testing**
  - [ ] Test Go backend in devShell
  - [ ] Test C++ backend in devShell
  - [ ] Verify FFI examples work
  - [ ] Verify optimizer integration

## Architecture

**Three-stage pipeline with purescript-native:**

```
Stage 1: Source → CoreFn (purs compile --codegen corefn)
Stage 2: [Optional] CoreFn → Optimized CoreFn (purs-backend-es)
Stage 3: CoreFn → Native Code (psgo/pscpp)
```

**purescript-native internal stages:**

```
CoreFn JSON → CoreImp IL → Optimizer → Backend (Go/C++)
```

## Backend Specification

### Basic Usage

```nix
backend = {
  cmd = "psgo";  # or "pscpp"
  package = psgo;  # or pscpp
};
```

### With Optimizer

```nix
optimizer = {
  cmd = "purs-backend-es";
  package = pursBackendEs;
};
backend = {
  cmd = "psgo";
  package = psgo;
};
```

## Key Decisions

1. **Both backends**: Implementing psgo and pscpp together
2. **Optimizer support**: Supporting both built-in and purs-backend-es
3. **Package sets**: Creating locked package sets from the start
4. **Platform**: Darwin (macOS) priority, Linux later

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Unmaintained project | Document "use at own risk", fork if needed |
| Package compatibility | Start with minimal package set, expand carefully |
| FFI complexity | Provide clear examples and documentation |
| Build failures | Test incrementally, fix issues as discovered |

## Notes

- purescript-native last updated: March 2023 (Go), December 2020 (C++)
- Uses CoreImp IL internally (not exposed to us)
- Built-in optimizer includes: Inliner, TCO, MagicDo
- FFI conventions differ from JavaScript FFI

### Implementation Notes

**Build Approach:**
- Using `haskellPackages.callCabal2nix` for proper Nix packaging
- Using `doJailbreak` to remove outdated version constraints
- Dependencies were constrained to old versions (aeson <1.5, bytestring <0.11, etc.)
- Modern nixpkgs has newer versions that work fine with jailbreak

**Source Hashes:**
- psgo (golang branch): `sha256-ucXGv/fi4GU8rx3Mwomdwq1Xy78V7b+Cbx43C4mjXTs=`
- pscpp (cpp branch): `sha256-zKMnaXoP67fRW8+0yjPJbS81DyoTPZ0U8HIeMUPiKXU=`

## Files Modified

- [ ] `tools.nix`
- [ ] `tests.nix`
- [ ] `README.md`
- [ ] `.gitignore` (if needed)

## Files Created

- [x] `native.md` (this file)
- [ ] `tests/backends/native/go/minimal/flake.nix`
- [ ] `tests/backends/native/go/with-deps/flake.nix`
- [ ] `tests/backends/native/go/with-optimizer/flake.nix`
- [ ] `tests/backends/native/go/with-ffi/flake.nix`
- [ ] `tests/backends/native/cpp/minimal/flake.nix`
- [ ] `tests/backends/native/cpp/with-deps/flake.nix`
- [ ] `tests/backends/native/cpp/with-optimizer/flake.nix`
- [ ] `tests/backends/native/cpp/with-ffi/flake.nix`
- [ ] `examples/psgo-hello/flake.nix`
- [ ] `examples/psgo-hello-optimized/flake.nix`
- [ ] `examples/pscpp-hello/flake.nix`
- [ ] `docs/backends/purescript-native.md`
- [ ] Package set files (TBD)

---

**Last Updated**: 2025-11-06

---

## Alternative: purec (C Backend)

We also researched **purec** (https://github.com/pure-c/purec) as an alternative C backend.

**Status**: ❌ Also Not Recommended

### Why purec Doesn't Work

1. **Unmaintained**: Last updated February 2021 (4+ years ago)
2. **Alpha Quality**: Self-described as "alpha quality" by developers
3. **Recent Critical Issue**: Issue #66 (November 2024) reports project is "unusable"
4. **Monolithic Architecture**: Tightly couples optimization and code generation
   - Optimizer works on C AST, not CoreFn
   - Cannot reuse for other backends
   - Incompatible with three-stage architecture
5. **Would Require Major Refactoring**: To fit three-stage model

### Comparison: purescript-native vs purec

| Aspect | purescript-native | purec |
|--------|------------------|-------|
| **Last Update** | March 2023 (Go), Dec 2020 (C++) | February 2021 |
| **Architecture** | CoreFn → CoreImp IL → Optimizer → Backend | CoreFn → C AST + Optimizer → C |
| **Compatibility** | Coupled to compiler internals | Uses CoreFn (better) |
| **Build Status** | Fails with modern PureScript | Would need major refactoring |
| **Modularity** | Some (shared optimizer) | Monolithic |
| **Recommendation** | ❌ Don't use | ❌ Don't use |

### Conclusion

**Neither purescript-native nor purec** are viable options for native code generation with modern PureScript tooling. Both projects:
- Are unmaintained
- Have significant architectural or compatibility issues
- Would require substantial effort to integrate and maintain

**Better approach**: Wait for the PureScript community to develop modern native backends that:
- Use stable CoreFn format (no compiler coupling)
- Are actively maintained
- Follow three-stage architecture patterns

---

**Research completed by**: Claude Code
**Date**: 2025-11-06
