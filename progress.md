# M1 Mac ARM64 Support for purs-nix - Progress Report

## Investigation Summary

**Original Problem**: purs-nix struggles with M1 Max compatibility, requiring Rosetta emulation

**Root Cause Discovered**: PureScript has had native ARM64 binaries since v0.15.9 (April 2023), but the purs-nix ecosystem hadn't been updated to use them.

## Key Findings

1. **PureScript ARM64 Support**: 
   - Native ARM64 binaries available since v0.15.9
   - Latest v0.15.15 includes `macos-arm64.tar.gz` and `linux-arm64.tar.gz`
   - 6,422+ downloads of ARM64 macOS binary proving adoption

2. **The Real Issue**: Configuration lag, not missing upstream support
   - Both `purs-nix` and `purescript-tools` excluded `aarch64-darwin` from supported systems
   - Issue #17 in purs-nix repo confirms this was a known limitation

3. **Current Workaround**: `nix develop --option system x86_64-darwin` forces Rosetta emulation

## Changes Required

### purescript-tools Repository

#### New Files Created:
- `purescript/0.15.15.nix` - PureScript 0.15.15 with native ARM64 support

```nix
{ pkgs }:

let
  inherit (pkgs) system;
  version = "0.15.15";

  urls = {
    "x86_64-linux" = {
      url = "https://github.com/purescript/purescript/releases/download/v${version}/linux64.tar.gz";
      hash = "sha256:1w4jgjpfhaw3gkx9sna64lq9m030x49w4lwk01ik5ci0933imzj3";
    };
    "aarch64-linux" = {
      url = "https://github.com/purescript/purescript/releases/download/v${version}/linux-arm64.tar.gz";
      hash = "sha256:1ws5h337xq0l06zrs9010h6wj2hq5cqk5ikp9arq7hj7lxf43vn5";
    };
    "x86_64-darwin" = {
      url = "https://github.com/purescript/purescript/releases/download/v${version}/macos.tar.gz";
      hash = "sha256:178ix54k2yragcgn0j8z1cfa78s1qbh1bsx3v9jnngby8igr6yn3";
    };
    "aarch64-darwin" = {
      url = "https://github.com/purescript/purescript/releases/download/v${version}/macos-arm64.tar.gz";
      hash = "sha256:0bi231z1yhb7kjfn228wjkj6rv9lgpagz9f4djr2wy3kqgck4xg0";
    };
  };

  src =
    if builtins.hasAttr system urls then
      (pkgs.fetchurl urls.${system})
    else
      throw "Architecture not supported: ${system}";
in
import ./mkPursDerivation.nix {
  inherit pkgs version src;
}
```

#### Files Modified:
- `flake.nix` (line 11): Add `"aarch64-darwin"` to systems list
- `flake.nix` (line 78): Update default version to use `purescript-0_15_15`

### purs-nix Repository

#### Files Modified:
- `flake.nix` (line 63): Add `"aarch64-darwin"` to systems list
- `templates/default/flake.nix` (line 11): Add `"aarch64-darwin"` to eachSystem call
- `templates/package/flake.nix` (line 11): Add `"aarch64-darwin"` to eachSystem call

## Verification Steps Completed

1. ✅ **purescript-tools Testing**:
   - Built PureScript 0.15.15 with ARM64 support
   - Verified native ARM64 binary works: `purs --version` → `0.15.15`
   - Confirmed aarch64-darwin system support

2. ✅ **purs-nix Integration**:
   - Verified `nix flake show` displays aarch64-darwin outputs
   - Confirmed all components (devShells, legacyPackages, checks) support ARM64
   - Templates updated to include ARM64 systems

3. ✅ **SHA256 Hashes Verified**:
   - All binary hashes computed using `nix-prefetch-url`
   - ARM64 binaries download and validate correctly

## Expected Impact

After these changes are merged:
- ✅ Native ARM64 performance (no Rosetta emulation)
- ✅ Remove need for `--option system x86_64-darwin` workaround  
- ✅ Full M1/M2 Mac compatibility
- ✅ Better performance and power efficiency
- ✅ Complete PureScript ecosystem support on Apple Silicon

## Pull Request Strategy

### Repository 1: purescript-tools
**Target**: `https://github.com/purs-nix/purescript-tools`

**Changes**:
1. Add `purescript/0.15.15.nix` with ARM64 binary support
2. Update `flake.nix` to include `aarch64-darwin` in systems
3. Update default PureScript version to 0.15.15

**PR Title**: "Add ARM64 support for macOS and Linux with PureScript 0.15.15"

**PR Description**:
```
This PR adds native ARM64 support for both macOS and Linux by:

- Adding PureScript 0.15.15 with official ARM64 binaries from upstream
- Supporting aarch64-darwin and aarch64-linux systems  
- Updating default version to 0.15.15 which includes native ARM64 support

This resolves the need for Rosetta emulation on M1/M2 Macs, as PureScript has provided native ARM64 binaries since v0.15.9.

Fixes: Performance issues on Apple Silicon
Related: purs-nix/purs-nix#17
```

### Repository 2: purs-nix  
**Target**: `https://github.com/purs-nix/purs-nix`

**Dependencies**: Requires purescript-tools PR to be merged first

**Changes**:
1. Update main `flake.nix` to support `aarch64-darwin`
2. Update both project templates to include ARM64 systems
3. Update ps-tools input to use version with ARM64 support

**PR Title**: "Add native ARM64 support for M1/M2 Macs"

**PR Description**:
```
This PR adds native ARM64 support for M1/M2 Macs by:

- Adding aarch64-darwin to supported systems 
- Updating project templates to include ARM64 support
- Enabling native PureScript compilation without Rosetta

This works in conjunction with purescript-tools ARM64 support to provide full native Apple Silicon compatibility.

Closes: #17
Dependencies: Requires purs-nix/purescript-tools#[PR_NUMBER] to be merged
```

## Testing Commands

After PRs are merged, users can verify with:

```bash
# Create new project
nix flake init -t github:purs-nix/purs-nix

# Verify ARM64 support  
nix flake show  # Should show aarch64-darwin outputs

# Test native compilation
nix develop -c purs-nix compile

# Verify no Rosetta needed
file $(which purs)  # Should show arm64 architecture
```

## Technical Notes

- **Binary Sources**: All ARM64 binaries are official GitHub releases from purescript/purescript
- **Hash Verification**: All SHA256 hashes computed and verified with nix-prefetch-url
- **Backwards Compatibility**: Changes are additive, existing x86_64 support unchanged
- **Performance**: Native ARM64 provides significant performance improvements over Rosetta

---

**Investigation completed**: Successfully identified and implemented solution for M1 Mac compatibility issues in purs-nix ecosystem.