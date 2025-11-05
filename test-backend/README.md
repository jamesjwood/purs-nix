# Backend Support Tests

This directory contains automated tests for purs-nix's backend support (PureScript-to-Erlang compilation with purerl).

## Test Suite

### Test Cases

1. **`minimal-locked-pure`** - Minimal project with locked package set
   - Tests pure evaluation (no `--impure` needed)
   - Tests basic backend compilation
   - Dependencies: console, effect, prelude

2. **`minimal-locked-erl-files`** - Verify .erl file generation
   - Checks that purerl generates `.erl` files
   - Validates output structure
   - Ensures all expected files exist

3. **`medium-locked-pure`** - Medium complexity with Erlang-specific packages
   - Tests erl-atom, erl-lists, erl-maps, erl-process
   - Validates Erlang-specific package compilation
   - Tests more complex dependency graphs

4. **`lock-script-works`** - Package set locking script functionality
   - Verifies lock-package-set.sh shows help
   - Tests basic script functionality
   - Validates script invocation

5. **`locked-format-valid`** - Locked package set format validation
   - Checks locked file syntax
   - Verifies commit hashes (rev) are present
   - Validates Nix function structure

## Running Tests

### Run All Tests

```bash
cd test-backend
nix flake check
```

### Run Individual Tests

```bash
# Test minimal project (pure evaluation)
nix build .#checks.aarch64-darwin.minimal-locked-pure

# Test .erl file generation
nix build .#checks.aarch64-darwin.minimal-locked-erl-files

# Test medium complexity
nix build .#checks.aarch64-darwin.medium-locked-pure

# Test lock script
nix build .#checks.aarch64-darwin.lock-script-works

# Test locked format
nix build .#checks.aarch64-darwin.locked-format-valid
```

Replace `aarch64-darwin` with your system:
- `aarch64-darwin` - Apple Silicon Mac
- `x86_64-linux` - Linux x86_64
- `aarch64-linux` - Linux ARM64

### Build Example

```bash
# Build the minimal example
nix build .#packages.aarch64-darwin.minimal-example
```

## Test Structure

```
test-backend/
├── flake.nix                      # Test suite definition
├── minimal-locked/                # Minimal test project
│   └── src/Main.purs
├── medium-locked/                 # Medium complexity test
│   └── src/Main.purs
├── minimal-locked-packages.nix    # Locked package set (104 packages)
└── README.md                      # This file
```

## What's Being Tested

### Pure Evaluation
- All tests run without `--impure` flag
- Package sets use commit hashes instead of tags
- Ensures full reproducibility

### Backend Compilation
- PureScript compiles to CoreFn
- Purerl generates `.erl` files from CoreFn
- Output structure is correct

### Package Set Integration
- Locked package sets load correctly
- Erlang-specific packages resolve properly
- Per-package caching works

### Tooling
- Lock script is executable and functional
- Locked file format is valid Nix
- Error handling works

## Integration with Main Flake

These tests are automatically included in the main purs-nix checks:

```bash
cd ..  # Back to purs-nix root
nix flake check
```

The backend tests run on all platforms, not just x86_64-linux like the original tests.

## Test Results

All tests should pass with these outcomes:

| Test | Expected Result |
|------|----------------|
| minimal-locked-pure | Builds successfully in pure mode |
| minimal-locked-erl-files | Verifies .erl files exist |
| medium-locked-pure | Compiles with erl-* packages |
| lock-script-works | Script shows help message |
| locked-format-valid | Locked file has correct syntax |

## Troubleshooting

### Test Failures

**Build fails in pure mode:**
- Check that locked package set is properly generated
- Verify all packages have `rev` (not `ref`) entries
- Ensure source files are in correct locations

**`.erl` files not generated:**
- Check purerl is installed correctly
- Verify backend configuration in flake
- Check purerl command output for errors

**Package not found:**
- Verify package exists in locked package set
- Check dependencies list is complete
- Regenerate locked package set if needed

### Regenerating Test Data

If you need to regenerate the locked package set:

```bash
nix run github:purs-nix/purs-nix#lock-package-set -- \
  https://raw.githubusercontent.com/purerl/package-sets/erl-0.15.3-20220629/packages.json \
  minimal-locked-packages.nix
```

## CI/CD Integration

These tests are designed to run in CI/CD:

```yaml
# Example GitHub Actions
- name: Test backend support
  run: |
    cd test-backend
    nix flake check
```

Benefits:
- Fast (leverages Nix caching)
- Multi-platform (aarch64-darwin, x86_64-linux)
- Pure evaluation (no network during build)
- Reproducible across environments

## Adding New Tests

To add a new test:

1. Create test source in a new directory
2. Add test case to `flake.nix` checks section
3. Document the test in this README
4. Run `nix flake check` to verify

Example:

```nix
my-new-test = let
  ps = purs-nix-instance.purs {
    dependencies = [ "my" "deps" ];
    backend = { cmd = "purerl"; package = purerl; };
    package-set = locked-package-set;
    dir = ./my-test-dir;
  };
in ps.output {};
```

## See Also

- [Package Set Locking Guide](../docs/package-set-locking.md)
- [PureRL Hello Example](../examples/purerl-hello/)
- [Main Test Suite](../test/)
