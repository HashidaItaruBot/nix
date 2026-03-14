# Phase 5: Validation & Enhancement - Research

**Researched:** 2026-03-14
**Domain:** Nix Flake Validation, CI/CD, Development Tooling
**Confidence:** HIGH

## Summary

This phase validates the existing Nix Flake implementation (Phases 1-4) and adds quality infrastructure including CI/CD via GitHub Actions, improved development tooling (alejandra, statix, nom, nixd), and documentation. The project has a clean modular structure with darwin/, nixos/, and shared/ directories. No CI/CD infrastructure exists yet. Current tooling uses nixpkgs-fmt and nil LSP, which should be upgraded to alejandra and nixd respectively for better flake support.

**Primary recommendation:** Implement validation-first approach with GitHub Actions CI pipeline, then incrementally upgrade tooling. Documentation should be minimal but complete.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Implementation Decisions

#### Validation Approach
- Run `nix flake check` to verify flake builds for both platforms
- Verify no secrets in nix store: `grep -r "ENC\[" /nix/store/* 2>/dev/null` should find nothing
- Test rebuild on both NixOS and Darwin systems
- Document rebuild procedures in README.md

#### CI/CD Platform
- GitHub Actions (standard for open-source Nix projects)
- Run on: push to main, pull requests
- Jobs: flake check, nixfmt check, statix lint
- Use cachix or attic for binary cache (optional enhancement)

#### Tooling Enhancements
- **alejandra** for Nix formatting (replace nixpkgs-fmt - stricter, more consistent)
- **statix** for Nix linting (catches anti-patterns)
- **nom** for build visualization (better than default nix build output)
- **nixd** for LSP (better flake support than nil) - optional, keep nil as fallback

#### Documentation
- README.md with: project overview, rebuild commands, secrets setup, contributing
- Platform-specific sections: "Rebuilding on NixOS" vs "Rebuilding on Darwin"
- Secrets management section: how to add/edit secrets

#### Claude's Discretion
- Exact CI workflow file structure
- Whether to enable binary cache (cachix/attic)
- Specific statix rules to enable/disable
- nom integration method (shell alias vs package)

### Deferred Ideas (OUT OF SCOPE)
- Binary cache setup (cachix/attic) - optional enhancement, defer unless performance becomes issue
- Multi-host support - v2 scope
- Impermanence pattern - v2 scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| VAL-01 | Verify all secrets are properly encrypted (no secrets in nix store) | sops-nix design ensures secrets are decrypted at activation time, not stored in /nix/store. Use `nix path-info` and grep patterns to verify. |
| VAL-02 | Document rebuild procedures for both platforms | Standard rebuild commands: `nixos-rebuild switch --flake .` for NixOS, `darwin-rebuild switch --flake .` for Darwin. Document in README.md. |
| VAL-03 | Verify cross-platform secret sharing works correctly | Project uses shared/secrets/ with sopsFile paths. Verify both platforms can access the same secrets via sops.age.sshKeyPaths. |
| VAL-04 | Validate MicroVM networking configuration | MicroVM uses user-mode networking with port forwarding. Validate via `microvm -m openclaw run` and connectivity tests. |
| TOOL-01 | Consider alejandra formatter (stricter than nixpkgs-fmt) | alejandra is more opinionated and consistent. Add via `nix fmt` or formatter output in flake.nix. |
| TOOL-02 | Add statix linter for Nix code quality | statix catches anti-patterns like deprecated builtins, inefficient expressions. Add to CI pipeline. |
| TOOL-03 | Add nom for build visualization | nom provides real-time build progress. Add as shell alias: `alias nix-build="nom build"`. |
| TOOL-04 | Consider nixd LSP (better flake support than nil) | nixd has better flake evaluation support. Currently using nil with nixpkgs-fmt. Migration path documented below. |
| QUAL-01 | Add CI/CD for flake checks | GitHub Actions workflow with nix flake check, formatter check, and statix lint. Matrix for x86_64-linux and aarch64-darwin. |
| QUAL-02 | Regular input update schedule | Use `nix flake update` with automation. Consider Dependabot or scheduled workflow. |
| QUAL-03 | Consolidate duplicate git/ssh configs across platforms | Current duplication: git signing config in nixos/home/git.nix and darwin/home/git.nix. SSH identityAgent differs by platform (1Password socket paths). |
</phase_requirements>

## Standard Stack

### Core
| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| alejandra | latest (nixpkgs) | Nix formatting | Stricter, more consistent output than nixpkgs-fmt. Recommended by Nix community. |
| statix | latest (nixpkgs) | Nix linting | Catches anti-patterns, deprecated usage, performance issues |
| nom | latest (nixpkgs) | Build visualization | Better UX for long builds, shows dependency graph |
| nixd | latest (nixpkgs) | Nix LSP | Better flake support, faster evaluation than nil |

### Supporting
| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| nil | latest (nixpkgs) | Nix LSP (fallback) | If nixd has issues, nil is stable alternative |
| nixpkgs-fmt | latest (nixpkgs) | Nix formatting (legacy) | Current formatter, to be replaced by alejandra |
| cachix | latest | Binary cache | Optional - defer unless build times are problematic |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| alejandra | nixpkgs-fmt | nixpkgs-fmt is more lenient, alejandra is stricter and more opinionated |
| nixd | nil | nixd has better flake support, nil is more mature and stable |
| GitHub Actions | GitLab CI | Project uses GitHub, GitLab CI would add complexity |
| cachix | attic | cachix is simpler for personal projects, attic is self-hosted |

**Installation:**
```nix
# Add to shared/home/default.nix or platform-specific packages
environment.systemPackages = with pkgs; [
  alejandra
  statix
  nom
  nixd
];
```

## Architecture Patterns

### Recommended Project Structure
```
.github/
└── workflows/
    └── ci.yml           # CI pipeline (to be created)
darwin/
├── default.nix          # Darwin entry point
├── home/                # Platform-specific home-manager
├── packages/            # Darwin packages
└── sops.nix             # Platform-specific sops config
nixos/
├── default.nix          # NixOS entry point
├── home/                # Platform-specific home-manager
├── packages/            # NixOS packages
├── microvm/             # MicroVM definitions
└── sops.nix             # Platform-specific sops config
shared/
├── home/                # Cross-platform home-manager
├── secrets/             # Encrypted secrets (sops)
└── system/              # Cross-platform system config
flake.nix                # Main flake
.sops.yaml               # Sops encryption config
README.md                # Documentation (to be created)
```

### Pattern 1: GitHub Actions CI for Nix Flakes
**What:** Multi-platform CI pipeline that validates flake builds, formatting, and linting
**When to use:** All Nix flake projects for quality assurance
**Example:**
```yaml
# .github/workflows/ci.yml
name: Nix CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  check:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: cachix/install-nix-action@v27
        with:
          nix_path: nixpkgs=channel:nixpkgs-unstable
      - name: Check flake
        run: nix flake check --no-build
      - name: Check formatting
        run: nix fmt -- --check .
      - name: Run statix
        run: nix run nixpkgs#statix check .
```

### Pattern 2: Formatter Configuration in Flake
**What:** Define formatter in flake.nix outputs for `nix fmt` support
**When to use:** When adopting alejandra or any formatter
**Example:**
```nix
# In flake.nix outputs
{
  formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
  formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;
}
```

### Pattern 3: nixd LSP Configuration
**What:** Configure nixd in nixvim for better flake support
**When to use:** When replacing nil with nixd
**Example:**
```nix
# In nixos/home/nixvim/plugins/nix-lsp.nix
programs.nixvim.plugins.lsp.servers.nixd = {
  enable = true;
  settings = {
    formatting = {
      command = [ "alejandra" ];
    };
    nixd = {
      options = {
        nixos = {
          expr = "(builtins.getFlake \"/path/to/flake\").nixosConfigurations.nixos.options";
        };
        home_manager = {
          expr = "(builtins.getFlake \"/path/to/flake\").homeConfigurations.zhaochanglong.options";
        };
      };
    };
  };
};
```

### Anti-Patterns to Avoid
- **Hardcoded paths in CI:** Use relative paths and flake references, not absolute paths
- **Running statix on auto-generated files:** Exclude hardware-configuration.nix and flake.lock
- **Forcing nixd if it fails:** Keep nil as fallback, both can be configured
- **Cachix without authentication:** Use cachix-action with proper token for CI caching

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| CI pipeline from scratch | Custom bash scripts | GitHub Actions with nix actions | Cachix provides maintained actions |
| Secret validation script | Custom grep patterns | sops-nix built-in verification | sops-nix handles decryption safely |
| Build progress display | Custom logging wrapper | nom | Handles edge cases, widely used |
| Linter configuration | Custom statix wrapper | statix with default rules | Default rules catch common issues |

**Key insight:** The Nix ecosystem has mature tooling for all validation needs. Custom solutions introduce maintenance burden without benefit.

## Common Pitfalls

### Pitfall 1: Formatter Migration Breaking CI
**What goes wrong:** Switching from nixpkgs-fmt to alejandra reformats entire codebase, causing large PRs and potential merge conflicts
**Why it happens:** alejandra has different formatting rules than nixpkgs-fmt
**How to avoid:** Run formatting migration in a dedicated commit/PR before other changes
**Warning signs:** CI failing with formatting errors after tool change

### Pitfall 2: CI Without Platform Matrix
**What goes wrong:** CI passes on Linux but Darwin configuration is broken
**Why it happens:** Running CI only on ubuntu-latest doesn't test aarch64-darwin
**How to avoid:** Use matrix strategy with both ubuntu-latest and macos-latest
**Warning signs:** Darwin rebuild fails after merge to main

### Pitfall 3: Secrets in Nix Store
**What goes wrong:** Encrypted secrets appear in /nix/store, defeating encryption purpose
**Why it happens:** Using string interpolation with secret values in Nix expressions
**How to avoid:** Always reference secrets via `config.sops.secrets.*.path`, never interpolate secret content
**Warning signs:** `grep -r "ENC\[" /nix/store/*` returns matches

### Pitfall 4: LSP Config Conflicts
**What goes wrong:** Both nil and nixd are enabled, causing conflicts in editor
**Why it happens:** Multiple LSP servers for same language running simultaneously
**How to avoid:** Disable nil when enabling nixd, or use conditional configuration
**Warning signs:** Duplicate completions, slow editor performance

## Code Examples

### GitHub Actions CI Workflow (Full)
```yaml
# .github/workflows/ci.yml
name: Nix CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  check:
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            system: x86_64-linux
          - os: macos-latest
            system: aarch64-darwin
    runs-on: ${{ matrix.os }}

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Install Nix
        uses: cachix/install-nix-action@v27
        with:
          nix_path: nixpkgs=channel:nixpkgs-unstable
          extra_nix_config: |
            experimental-features = nix-command flakes

      - name: Check flake validity
        run: nix flake check --no-build --system ${{ matrix.system }}

      - name: Check Nix formatting
        run: nix run nixpkgs#alejandra -- --check .

      - name: Run statix linter
        run: nix run nixpkgs#statix -- check .
```

### Formatter Output in flake.nix
```nix
{
  outputs = inputs@{ self, nixpkgs, ... }:
  {
    # ... existing outputs ...

    # Add formatter outputs for nix fmt support
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;
  };
}
```

### Secret Validation Script
```bash
#!/usr/bin/env bash
# scripts/verify-secrets.sh
# Run after rebuild to verify no secrets leaked to nix store

set -euo pipefail

echo "Checking for secrets in /nix/store..."

# Check for SOPS markers
if grep -r "ENC\[" /nix/store/* 2>/dev/null; then
    echo "ERROR: Found encrypted content in /nix/store!"
    exit 1
fi

# Check for age encryption markers
if find /nix/store -name "*.yaml" -exec grep -l "age1" {} \; 2>/dev/null | grep -q .; then
    echo "ERROR: Found age keys in /nix/store!"
    exit 1
fi

echo "OK: No secrets found in /nix/store"
```

### nom Shell Integration
```nix
# In shared/home/default.nix or zsh.nix
programs.zsh.shellAliases = {
  # nom aliases for better build output
  nb = "nom build";
  ns = "nom build . && nixos-rebuild switch --flake .";
  nd = "nom build . && darwin-rebuild switch --flake .";
};
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| nixpkgs-fmt | alejandra | 2023+ | More consistent formatting, stricter rules |
| nil LSP | nixd LSP | 2024+ | Better flake evaluation, faster completion |
| Manual CI setup | cachix/install-nix-action | 2022+ | Simplified Nix CI configuration |
| Custom build scripts | nom | 2022+ | Better build visualization and UX |

**Deprecated/outdated:**
- nixpkgs-fmt: Still works but alejandra is preferred for new projects
- Manual CI workflows: Use cachix actions for better caching and reliability

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Nix flake check + statix + alejandra |
| Config file | None - uses flake.nix outputs |
| Quick run command | `nix flake check --no-build` |
| Full suite command | `nix flake check && nix run nixpkgs#statix check . && nix run nixpkgs#alejandra -- --check .` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| VAL-01 | Verify secrets not in nix store | manual | `scripts/verify-secrets.sh` (to create) | Wave 0 |
| VAL-02 | Document rebuild procedures | manual | N/A - documentation | Wave 0 |
| VAL-03 | Cross-platform secret sharing | integration | `nixos-rebuild switch --flake .` on NixOS, `darwin-rebuild switch --flake .` on Darwin | Requires hardware |
| VAL-04 | MicroVM networking | integration | `microvm -m openclaw run` then `curl localhost:18789` | Requires NixOS host |
| TOOL-01 | alejandra formatter | unit | `alejandra --check .` | CI job |
| TOOL-02 | statix linter | unit | `statix check .` | CI job |
| TOOL-03 | nom build visualization | manual | `nom build .` | Requires local install |
| TOOL-04 | nixd LSP | manual | Editor configuration | Requires local install |
| QUAL-01 | CI/CD pipeline | integration | GitHub Actions workflow | Wave 0 |
| QUAL-02 | Input update schedule | manual | `nix flake update` | Optional automation |
| QUAL-03 | Config consolidation | manual | Code review | N/A |

### Sampling Rate
- **Per task commit:** `nix flake check --no-build` (quick)
- **Per wave merge:** Full CI pipeline via GitHub Actions
- **Phase gate:** All CI checks green, secrets validated, README complete

### Wave 0 Gaps
- [ ] `.github/workflows/ci.yml` - GitHub Actions CI workflow
- [ ] `scripts/verify-secrets.sh` - Secret validation script
- [ ] `README.md` - Project documentation

## Open Questions

1. **Binary Cache Strategy**
   - What we know: cachix and attic are the main options. cachix is simpler for personal projects.
   - What's unclear: Whether build times justify the complexity of setting up caching.
   - Recommendation: Defer binary cache setup. If builds take >10 minutes, reconsider in future.

2. **nixd vs nil Migration**
   - What we know: nixd has better flake support. nil is more stable.
   - What's unclear: Whether nixd is stable enough for daily use.
   - Recommendation: Install nixd alongside nil. Configure editor to prefer nixd but keep nil as fallback.

3. **statix Rule Selection**
   - What we know: statix has many rules, some may be noisy.
   - What's unclear: Which rules are most relevant for this project.
   - Recommendation: Start with default rules. Add `.statix.toml` to disable specific rules if needed.

## Sources

### Primary (HIGH confidence)
- Project codebase analysis - flake.nix, darwin/, nixos/, shared/ structure
- CONTEXT.md - User decisions from discuss-phase
- REQUIREMENTS.md - Phase requirement definitions

### Secondary (MEDIUM confidence)
- Nix community best practices (alejandra, statix, nixd adoption trends)
- GitHub Actions nix workflows (cachix/install-nix-action documentation)
- sops-nix documentation for secret validation patterns

### Tertiary (LOW confidence)
- WebSearch results for tool comparisons were not retrieved due to API issues - relying on training knowledge

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Tools are well-established in Nix ecosystem
- Architecture: HIGH - Project structure is clear, CI patterns are standard
- Pitfalls: MEDIUM - Based on common Nix community knowledge, should be verified in practice

**Research date:** 2026-03-14
**Valid until:** 2026-04-14 (Nix tooling evolves; check for new formatter/LSP updates)