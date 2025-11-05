a fork of purs-nix that supports alternative backends


<general>
# General Software Development Rules

## Core Principles

- **Brutal Honesty**: Reject bad ideas directly. Bad ideas compound into technical debt. User prefers you point out problems with their suggestions.

- **Delete Completely**: Delete unneeded code entirely, don't comment out. Version control preserves history.

- **Fail Fast**: No defensive programming, no silent failures, no fallbacks without approval. Crash with clear error over silent data corruption. Throw exceptions/return errors for invalid states. If our "single way" fails, we want to know.

- **Code Consolidation Before Creation**: Search existing codebase before writing new functions. Search-first prevents duplication.

- **Document Technical Debt**: Record debt in specs with remediation plans.

- **Explicit Types**: Use Either/Maybe/Result types over exceptions. Explicit types make error handling visible and testable.

- **Test Outcomes, Not Processes**: Verify expected results. "Didn't crash" ≠ "worked correctly". Check actual effects (files, network calls), never use log output as success measure.

- **Assume Failure**: ALWAYS assume your code has bugs. Verify with tests, never assume success.

- **Immutable First**: Prefer immutable approaches. Immutability prevents entire classes of bugs.

- **Type Safety**: Make invalid states unrepresentable. If two properties both exist or both don't exist, nest them: `{both:: Maybe {a: String, b: String}}`

- **Don't Repeat Yourself (DRY)**: Every piece of knowledge must have ONE authoritative representation.

- **No File Backups**: Never create backup files - rely on git. Backup files pollute codebase.

- **Prefer Functional Languages**: PureScript, Elm, Haskell remove classes of bugs related to mutable state.

- **Prefer Libraries**: Search and evaluate existing libraries first. They're often more robust.

- **Prefer Statically Typed**: PureScript, Elm, Haskell, Rust catch errors at compile time.

- **Single Approach**: One code path/pattern per problem class. Consistency > optimality.

- **Single Responsibility**: Every module/function/script does one thing well.

- **Self-Documenting Code Only**: NEVER add code comments. Comments become outdated lies. Write clear code through:
  - Descriptive function/variable/type names
  - Type signatures documenting interfaces
  - Small, single-purpose functions
  - Tests as documentation
  - Exception: Brief module-level exports docs for public APIs

- **Avoid Hard Coded File Paths**: Avoid hard coded paths in all languages.

- **Suggest Guidance Improvements**: When overcoming technical hurdles, suggest adding learnings to guidance.

- **No Backwards Compatibility**: Our greenfield projects stay up to date. NEVER retain backwards compatibility. Just make the change and force downstream updates. Keeps codebase tight.

- **Rigorous Tooling**: Configure ALL lint/format/test tools through flake.nix only. Run via `nix flake check` or `nix run .#format-fix`. Platform configs define WHAT, flake.nix defines HOW. Tools: eslint, purs-tidy, prettier, nix format.

- **No Code in Plans**: Don't include untested code in planning documents.

- **No Documentation**: Don't create documentation. Code and tests better represent intent.

## When you are done

When you are done, check that formatting is correct (usually best to just run the format-fix command). Run the tests (usually nix flake check). Never assume just because you have written code, that it works. ALWAYS run tests before returning to the user.
</general>
<nix>
# Nix

We use Nix flakes for reproducible builds. This necessitates isolated "sandboxed" builds. Do not try to subvert this process. Treat Nix as our primary and first-class build system. Generally we use Determinate Nix.

- **Use checks**: CI and locally, we use `nix flake check` to run all our checks, this is the companies primary way of running build/test/lint/format etc. Make sure to add ALL targets to the checks: build, lint, format, and test (playback mode - isolated, no network). For side effects use run targets: .#record (capture live API interactions), .#integration (replay recorded fixtures). Our determinate CI builds everything so if things are not added as checks then developers will not catch this when doing a flake check locally.
- **Use run**: We use run targets for deployment and other side effecting functions like fixing formatting errors. For feature-specific test recording and integration, create targets following the pattern: `.#record-{feature}` and `.#integration-{feature}` where {feature} uses kebab-case (e.g., `.#record-auth-flow`, `.#integration-data-export`)
- **Make apps**: The default app should start the production application. So we can just `nix run`
- **Make dev**: Add a dev target so we can `nix run .#dev`  to uniformly start development servers etc. We can use process compose to add multiple services if needed.

## Core Principles

- **Single Source for Dev Commands**: flake.nix is the ONLY location for build/lint/format/test commands. DO NOT use package.json scripts, Makefile, cargo make, justfile, or any platform-specific task runners. These create multiple sources of truth and break reproducibility. All dev operations MUST go through `nix flake check`, `nix build`, or `nix run` targets.

- **Use Platform Integrations**: Our favoured platform integrations are purs-nix for PureScript projects (this also bundles js), uv2nix for python projects, and npmBuildPackaged for js projects.

- **No Network Access in Builds**: NEVER use commands that require network access in Nix build targets: npm install, npm ci, cargo build, wget/curl. When writing nix flakes, do not use operations that require internet access (npm install, spago install etc) in build commands. Network access makes builds non-reproducible. Nix's hermetic builds guarantee "if it built once, it builds forever." Nix guarantees reproducibility through hermetic builds, so nix build operates in a sandbox. You need to use specifically set-up derivations mkSpagoDerivation etc to deterministically get packages without internet access. Use third party derivations that install dependencies in a reproducible way (google-search). Doing any network calls or using tools that need network access in nix build targets will fail! It's fine to use these in impure nix run targets.

  **BAD:**
  ```
  npm install
  npm ci
  cargo build
  ```

  **GOOD:**
  ```
  cp -r ${deps}/node_modules ./
  cp -r ${build}/dist ./dist
  ```

- **Deps First**: Separate dependency installation from build/test/lint. Dependencies change rarely, builds change often. Separation and layering enables caching. We usually find the following steps useful:
  - deps (copy in just dependency listing files like package.json and spago.yaml. then install any dependencies, here you should be using buildNpmPackage or similar to get packages in a reproducible way)
  - working (copy in sources and build, ready for next steps, this means the next steps do not have to build again)
  - build (assemble any assets for production, package and copy to out)
  - test (run tests)
  - format (run the format checks)
  - lint (run linting checks on the codebase)

- **Use the Results Folder to Inspect Nix Working Directories**: If we are having problems in multi stage nix builds. Build the first target, then inspect the results folder (nix pops the outputs of the command here). Then check that this is what we expect to get out of this target. Do this step by step to work out what is going wrong.

- **Atomic Operations**: All-or-nothing builds. Partial builds create inconsistent states. Either everything works or nothing ships. Do not check for directories and use a fallback. If we expect a directory or file and its not there, CRASH.

- **Unified Environment**: Use direnv, nix devShell for development environment. Any apps/tools need to work through nix apps. "Works on my machine" is unacceptable.

- **Unified Testing**: Unify all tests that can be isolated (usually npm test), linting, formatting checks and build as nix flake checks.

- **Git Tracking**: Files need to be tracked in git in order to be included in nix builds. Remember to stage them.

- **Copying**: In nix builds, do not use `mv` or `cp` to copy files, this copies permissions as well which causes a host of issues, use `rsync -a --no-perms --no-owner --no-group --delete`. Symlink internally for speed if possible.

- **No Fallbacks**: If we expect to use something, be assertive. Never silently fall back or fail.

  **BAD:**
  ```
  npm run build || echo "No npm build script" --bad silently fails
  ```

- **Secrets Management**: NEVER commit secrets to flake files—the Nix store is world-readable. Use SOPS with age encryption for encrypted secrets in your repo. On Darwin, use direct `sops -d` commands in activation scripts rather than sops-nix (which has compatibility issues). Never commit `.env` files, API keys, or credentials.

- **Use direnv**: Setup direnv to use the devshell

- **shell.nx**: Add a backwards compatible shell.nix that points to our flake
---

## Flake Organization (2025)

- **Flakes as Entry Points Only**: Keep flakes lightweight - use as standardized entry points. Expose configurations by calling traditional Nix code. [Practical Nix Flake Anatomy](https://vtimofeenko.com/posts/practical-nix-flake-anatomy-a-guided-tour-of-flake.nix/)
- **Use flake-parts for Modular Organization**: Split flake outputs into focused modules. Prevents custom glue code proliferation. [flake-parts docs](https://flake.parts/) | [Writing Custom Modules](https://vtimofeenko.com/posts/flake-parts-writing-custom-flake-modules/)
- **Always Use inputs.follows**: Unify transitive dependencies to prevent conflicts. Pattern: `inputs.nixpkgs.follows = "nixpkgs"`. [Source](https://fzakaria.com/2024/07/31/automatic-nix-flake-follows.html)
- **Avoid with Imports**: Never use `with` - use explicit imports or inherit. [Nix Anti-patterns](https://nix.dev/anti-patterns/language.html#with-attrset-expression)
- **Checks Must Produce $out**: All checks must `touch $out` or checks may succeed silently
- **Use nixfmt-rfc-style**: Official Nix formatter (RFC 166). [nixfmt Repository](https://github.com/NixOS/nixfmt)

## Testing and Deployment (2025)

- **NixOS Integration Tests**: Use `pkgs.testers.runNixOSTest` for VM-based integration tests. [Official Tutorial](https://nix.dev/tutorials/nixos/integration-testing-using-virtual-machines.html) | [With Flakes](https://blakesmith.me/2024/03/02/running-nixos-tests-with-flakes.html)
- **Deployment with colmena**: Stateless multi-host NixOS deployments. [Colmena Manual](https://colmena.cli.rs/) | [Deployment Guide](https://baremetalblog.com/posts/tech/2024-02-04-deploying-nixos-configs-with-colmena/)

## Git
Nix flakes only see files that are either:

1. Committed to Git, or
2. Staged in Git

If you find you are having weird errors where things dong seem to be updating then check the files are staged.

## Dependency Updates

- **Automate Input Updates**: Use [update-flake-lock](https://github.com/DeterminateSystems/update-flake-lock) to automatically create weekly PRs updating flake.lock. Prevents stale dependencies (>30 days) from accumulating breaking changes. Always run `nix flake check` after updates to catch issues early.

## Troubleshooting
Sometimes it's useful to figure out what's going on in a Nix build and a good tactic here is to break the build into logical steps and then run the build and look at the results folder  that Nix will create. This shows you everything at the end of that build.
</nix>
<testing>
# Testing

## Test External Behavior, Not Implementation

- **Test Public APIs**: Libraries - test only exported functions and observable effects
- **Test User Interfaces**: UI - test user interactions and visible outcomes, not internal state. Use Playwright or Puppeteer.
- **Test Command Interfaces**: CLI - test command invocation and output, not internal logic. Actually run the cli.
- **Effect Verification**: Verify side effects (files, database changes, console output) independently

## Test Strategy

- **Behavior tests**: Test user-facing interfaces
- **No unit tests**: Test external APIs only, not internal implementation
- **BDD process**: Use BDD Markdown or Cucumber.js for behavior specifications

## Three Test Modes

All projects MUST support three distinct test execution modes:

- **Playback Mode** (`nix build .#test`) - Isolated tests using minimal fixtures, runs in Nix sandbox, no network access. Primary mode for `nix flake check`.
- **Record Mode** (`nix run .#record`) - Runs against live APIs/effects and captures interactions to fixtures. Use when APIs change or adding scenarios.
- **Integration Mode** (`nix run .#integration`) - Replays recorded fixtures to test full integration flows. Deterministic but tests complete behavior.

## Feature-Based Test Organization

Break tests into separately executable feature suites to enable targeted recording and integration testing.

**Naming Convention:**
- Use kebab-case for all feature suite names: `auth-flow`, `data-export`, `llm-streaming`
- Names should be concise, descriptive, and action-oriented
- Match the BDD feature file name (without extension)

**File Organization:**
- One BDD feature file maps to one test suite
- File: `test/features/auth-flow.feature.md` → Suite: `auth-flow`
- File: `test/features/data-export.feature.md` → Suite: `data-export`
- Fixtures organized by suite: `test/fixtures/auth-flow/`, `test/fixtures/data-export/`

**Nix Target Pattern:**
Create separate nix targets for each feature suite:
- Record: `.#record-{feature}` (e.g., `.#record-auth-flow`)
- Integration: `.#integration-{feature}` (e.g., `.#integration-auth-flow`)
- Playback: All features run together in `nix build .#test` and `nix flake check`

**Usage:**
- Record specific feature: `nix run .#record-auth-flow`
- Integration test specific feature: `nix run .#integration-auth-flow`
- Run all playback tests: `nix build .#test`

## Optimizing Side Effects

**Minimize expensive side effect calls** - Execute slow side effects (LLM calls, API requests) once and run multiple assertions on the result. Don't repeat 60+ second LLM calls for different checks. Call once, verify response format, content quality, error handling, and edge cases from the same result.

## Effects and Fixtures

- Use record/playback fixtures for effects (LLM calls, HTTP, file IO)
- Default to playback mode for isolated Nix builds
- Never use mocks - tests must be real or not exist

## Tools

- We use [BDD Markdown](https://github.com/bifravst/bdd-markdown)
- Use js for the steps.
- Use the following folder structure:
  - test/features/ for BDD Markdown feature files
  - test/steps/ for Step implementations (TypeScript/JS)
  - test/fixtures/ for Test data for three modes

## Retro-fitting
When retro-writing BDD tests for existing code. If it is known to be working, use the current output to generate correct results. Write the BDD tests and confirm they pass. Then temporarily add a fault to the implementation and check that the tests catch the error. Then we know we can rely on them.
</testing>


This file is generated, do not edit it directly. Edit either the project specific information in [agents.yml](./agents.yml) or the [company guidance](https://github.com/Cambridge-Vision-Technology/agen/wiki) and then rerun `agen`


To install the agen tool `nix profile add github:Cambridge-Vision-Technology/agen`