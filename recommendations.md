Recommendations for the alternative‑backends fork

- Generalize backend separation
  - Replace the current “dependency detection by .erl files” heuristic in `purs-nix.nix` with an explicit dependency list derived from the already computed closure (create-closure[-set]). This avoids Erlang-specific assumptions and works for any backend.
  - Use the known dependency directory set to move/copy only true dependencies during whole‑project backend runs, instead of scanning for backend-specific artifacts.

- Package-set purity and locking
  - Make `package-set.url` require a `sha256` and fail fast when missing. Direct users to the `lock-package-set` app to produce locked sets for pure evaluation.
  - Prefer locked package sets (`import ./packages-locked.nix`) for CI and flake checks; reserve unlocked JSON/URL usage for impure/dev shells only.

- Flake hygiene and consistency
  - Add `inputs.follows = "nixpkgs"` (and other relevant follows) for all transitive inputs to avoid version skew across inputs.
  - Add `aarch64-linux` to the `systems` list in the top-level `apply-systems` and ensure backend checks build on that platform in CI.
  - Switch `formatter` and formatting check to `nixfmt-rfc-style` (RFC 166) to match current guidance.
  - Reduce `with` usage across Nix files (use `inherit`/explicit attrs) to improve readability and statix signal.

- Reproducibility and networking
  - Tests/examples currently download backend tool archives with `fetchurl`. Promote these tools to flake inputs (or a vendor subflake) so checks don’t rely on ad‑hoc URLs and are easier to cache.
  - If keeping `fetchurl`, ensure tarball hashes are stable and backed by an internal cache for offline CI.

- Tests and portability
  - Keep backend tests in `checks`, but remove hardcoded `system = "aarch64-darwin"` in standalone test flakes under `tests/backends/`; use a parameter or `eachDefaultSystem`.
  - Extend tests with multi‑module projects and FFI scenarios for both JS and non‑JS backends (you already sketched these in docs/tests; wiring them into checks will raise confidence).

- CLI (optional nicety)
  - Consider exposing optimizer/backend operations via `purs-nix command` subcommands/flags for parity with the Nix API. The Nix path remains the authoritative interface; CLI shims help discoverability.

- Small quality-of-life fixes
  - Add a root `.gitignore` entry for `result` symlinks to prevent accidental commits.
  - Re‑enable disabled statix lints where feasible (`bool_comparison`, `useless_has_attr`) and address findings.

Quick wins checklist

- [ ] Replace `.erl` heuristic with closure‑based dependency separation
- [ ] Require `sha256` for `package-set.url`; recommend lock tool
- [ ] Add `inputs.follows` for all inputs; add `aarch64-linux`
- [ ] Switch formatter to `nixfmt-rfc-style` and update checks
- [ ] De‑`with` Nix sources where easy wins exist
- [ ] Move backend tool tarballs into inputs (or vendor subflake)
- [ ] Parameterize systems in `tests/backends` flakes
- [ ] Add `.gitignore` rule for `result/`; tighten statix rules
