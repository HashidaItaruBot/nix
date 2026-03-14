# Pitfalls Research

**Domain:** Nix Flake Configuration for NixOS and Darwin (macOS) Systems
**Researched:** 2026-03-14
**Confidence:** HIGH

## Critical Pitfalls

### Pitfall 1: Untracked Files Not Visible to Nix Flakes

**What goes wrong:**
Nix Flakes only see files tracked by Git. New files, unstaged changes, or files in `.gitignore` are invisible to the flake evaluation. This causes mysterious "file not found" errors or configurations that work locally but fail in CI or on other machines.

**Why it happens:**
Flakes are designed for reproducibility and use Git as the source of truth. The flake evaluates based on the Git index, not the filesystem. Developers accustomed to traditional Nix (which reads from the filesystem) expect changes to be immediately visible.

**How to avoid:**
- Always `git add` new configuration files before testing
- Run `git status` before `nixos-rebuild` or `darwin-rebuild` to verify tracked status
- Use `nix flake check` to validate flake evaluates correctly
- Consider using `direnv` with `use flake` for automatic environment loading

**Warning signs:**
- "file not found" errors for files that exist on disk
- Configuration changes not taking effect despite edits
- CI failures for code that works locally

**Phase to address:**
Phase 1 (Foundation) - Establish git hygiene habits early

---

### Pitfall 2: Input Version Drift and Lock File Neglect

**What goes wrong:**
Flake inputs become outdated, leading to security vulnerabilities, missing features, or incompatibilities. Conversely, running `nix flake update` without pinning critical inputs can break working configurations when upstream changes introduce breaking changes.

**Why it happens:**
- `nixpkgs-unstable` is a rolling target that changes daily
- Developers forget to update lock files regularly
- No automated process to check for updates or security patches
- Fear of breaking changes leads to never updating

**How to avoid:**
- Pin specific versions for critical inputs when stability is required
- Use `nix flake update <input>` to update specific inputs rather than all
- Schedule regular update cycles (weekly/monthly)
- Use `nix flake check` after updates to catch breaking changes early
- Consider using tagged releases for critical infrastructure (e.g., `lanzaboote/v1.0.0`)

**Warning signs:**
- Packages no longer in nixpkgs or renamed
- Security advisories for packages in closure
- Builds start failing on previously working configurations
- Large gaps between flake.lock updates

**Phase to address:**
Phase 1 (Foundation) - Establish update cadence and pinning strategy

---

### Pitfall 3: Secrets Leaked to Nix Store

**What goes wrong:**
Secrets (API keys, tokens, passwords) are accidentally included in the world-readable Nix store (`/nix/store/*`). This happens when secrets are referenced directly in Nix expressions instead of using proper secrets management.

**Why it happens:**
- Using `builtins.readFile` on secret files during evaluation
- Hardcoding secrets in Nix files
- Misunderstanding that Nix store is world-readable (mode 444)
- Forgetting that `nix eval` runs at evaluation time, not runtime

**How to avoid:**
- Always use sops-nix or similar tools for secrets management
- Reference secret paths via `config.sops.secrets.<name>.path`, not direct file paths
- Never read secrets during Nix evaluation time
- Verify with `nix-store -q --roots /nix/store/*-secret*` that secrets aren't in store
- Use `sopsFile` pointing to encrypted files only

**Warning signs:**
- Secret values visible in `/nix/store`
- `nix show-derivation` reveals secret content
- `environment.etc` or `systemd.services` contain literal secret values
- Git repository contains decrypted secret files

**Phase to address:**
Phase 2 (Secrets Management) - Critical security pitfall

---

### Pitfall 4: Cross-Platform Configuration Drift

**What goes wrong:**
Darwin (macOS) and NixOS configurations diverge over time, creating inconsistent user experiences across platforms. Shared configurations become platform-specific through platform-specific conditionals scattered throughout.

**Why it happens:**
- Platform-specific code mixed with shared code
- Copy-paste between configurations without abstraction
- Lack of clear module boundaries
- `pkgs.stdenv.isLinux`/`isDarwin` checks proliferating everywhere

**How to avoid:**
- Maintain strict `shared/` directory for common configurations
- Platform-specific code lives in `darwin/` or `nixos/` directories only
- Use module system for conditional inclusion, not inline conditionals
- Define shared home-manager modules imported by both platforms
- Regular cross-platform testing (if changes affect one, verify the other)

**Warning signs:**
- `if pkgs.stdenv.isDarwin then ... else ...` scattered in shared files
- Same feature configured differently on each platform
- Changes to one platform break or don't affect the other
- Inconsistent package versions or configurations

**Phase to address:**
Phase 1 (Foundation) - Establish clear module boundaries from the start

---

### Pitfall 5: home-manager Module Integration Mistakes

**What goes wrong:**
home-manager is incorrectly integrated, leading to package conflicts, configuration not applying, or `home-manager` command not working. Common issues include:
- Using standalone home-manager alongside system home-manager
- Incorrect `useGlobalPkgs` and `useUserPackages` settings
- Missing `extraSpecialArgs` causing inputs to be unavailable in home configs

**Why it happens:**
- Confusion between standalone and NixOS/Darwin module approaches
- Documentation shows both methods without clear guidance
- `home-manager` CLI works differently than module integration
- Module options are subtle and often misunderstood

**How to avoid:**
- Use module integration (`home-manager.nixosModules.home-manager`) consistently
- Set `home-manager.useGlobalPkgs = true` to avoid package duplication
- Set `home-manager.useUserPackages = true` to install packages to user profile
- Always pass `extraSpecialArgs = { inherit inputs self; }` for access to flake inputs
- Never install standalone home-manager when using module integration

**Warning signs:**
- Packages appear in both system and user profiles
- `home-manager switch` doesn't work or conflicts
- Flake inputs inaccessible in home-manager configs
- Configuration options not found in home-manager

**Phase to address:**
Phase 1 (Foundation) - Core architecture decision

---

### Pitfall 6: Lanzaboote/Secure Boot Misconfiguration

**What goes wrong:**
Secure boot setup fails, leaving system unbootable or with insecure configuration. Keys are missing, improperly formatted, or not properly linked to sops-nix for encryption.

**Why it happens:**
- Secure boot requires specific key/certificate formats
- Keys must exist before first boot with lanzaboote
- Forgetting to enroll keys in UEFI firmware
- Mixing up PK (Platform Key), KEK (Key Exchange Key), and db keys
- Keys stored unencrypted in git repository

**How to avoid:**
- Generate keys using `sbctl create-keys` or lanzaboote tools
- Store private keys encrypted via sops-nix
- Public keys/certificates can be stored in git (non-sensitive)
- Test secure boot status with `sbctl verify` after rebuild
- Have recovery plan (USB boot, disable secure boot in firmware)
- Document key generation and enrollment process

**Warning signs:**
- System fails to boot after lanzaboote enable
- `bootctl status` shows secure boot disabled
- Keys not found in `/etc/secureboot`
- sops-nix can't decrypt keys at boot time

**Phase to address:**
Phase 3 (NixOS Security) - Requires sops-nix working first

---

### Pitfall 7: State Version Mismatches

**What goes wrong:**
`system.stateVersion` or `home.stateVersion` are incorrect, causing:
- Migration scripts to not run (version too high)
- Unexpected configuration changes on upgrade (version too low)
- Incompatibilities when restoring from backup

**Why it happens:**
- State versions are confusing - they're not NixOS version but migration target
- Copy-pasting from examples without understanding
- Forgetting to set for new users/systems

**How to avoid:**
- Set `system.stateVersion` to the NixOS version at installation time
- Set `home.stateVersion` to the home-manager version at first use
- Never change stateVersion on existing systems without understanding migrations
- Document what version means in comments

**Warning signs:**
- Services behaving unexpectedly after upgrade
- Database migration errors
- Configuration options having different defaults than expected
- Warnings about deprecated options still applying

**Phase to address:**
Phase 1 (Foundation) - Set correctly at initialization

---

## Technical Debt Patterns

Shortcuts that seem reasonable but create long-term problems.

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Hardcoding package versions | Quick fix for breakage | Security vulnerabilities, missing updates | Never - use overlays or pinned inputs |
| Skipping sops-nix for "simple" secrets | Faster initial setup | Secrets leak to nix store, rotation pain | Never |
| Inline `if stdenv.isDarwin` in shared modules | Quick platform fix | Configuration drift, unmaintainable conditionals | Never - use proper module structure |
| Not using `git add` for new files | Faster iteration | Broken CI, "works on my machine" | Never - always track files |
| Ignoring `nix flake check` warnings | Faster builds | Hidden errors, broken configurations | Never |
| Using `nixpkgs-unstable` for everything | Latest packages | Frequent breakages, no reproducibility | Development only - pin for production |
| Mixing standalone and module home-manager | Flexibility | Conflicts, double packages | Never - choose one approach |

## Integration Gotchas

Common mistakes when connecting to external services.

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| sops-nix on Darwin | Using `/root/.ssh` path instead of `/var/root/.ssh` | Use `/var/root/.ssh/id_ed25519` for Darwin root SSH keys |
| sops-nix on NixOS | Expecting secrets available before sops-nix runs | Ensure SSH key exists before first sops-nix activation |
| home-manager overlays | Creating overlays in home-manager config | Use `nixpkgs.overlays` at system level or `home.packages` |
| plasma-manager | Not importing plasma-manager homeModules | Import `inputs.plasma-manager.homeModules.plasma-manager` |
| nixvim | Missing nixpkgs.follows for nixvim input | Always set `nixvim.inputs.nixpkgs.follows = "nixpkgs"` |
| lanzaboote | Storing keys in plaintext | Use sops-nix to encrypt private keys at rest |
| microvm | Not adding microvm.nixosModules to imports | Import the module: `inputs.microvm.nixosModules.microvm` |

## Performance Traps

Patterns that work at small scale but fail as usage grows.

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Large flake closure | Slow evaluations (minutes), memory issues | Minimize inputs, use flake-compat sparingly | 50+ inputs or large nixpkgs evaluations |
| Unpinned nixpkgs | Inconsistent builds across machines/CI | Use `nixpkgs.follows` consistently | Multiple developers, CI pipelines |
| Missing binary cache | Building from source for everything | Use `cachix` or configure substituters | Any significant package set |
| Huge home.packages | Switch takes forever, conflicts | Split into modules, use conditionals | 100+ packages in single list |
| Rebuilding entire system for minor changes | Every change takes 5+ minutes | Use `nixos-rebuild switch` (not boot) for testing | Multiple daily rebuilds |

## Security Mistakes

Domain-specific security issues beyond general web security.

| Mistake | Risk | Prevention |
|---------|------|------------|
| Secrets in git history (even deleted) | Credential exposure | Use sops-nix from start, `git filter-branch` to clean history |
| Unencrypted secret files | Credential exposure | All secrets must go through sops-nix encryption |
| Missing `.sops.yaml` or wrong keys | Can't decrypt secrets on new machine | Backup age keys, document key rotation |
| `/nix/store` permissions | World-readable by default | Never put secrets in nix expressions |
| SSH key in wrong location for sops | Boot fails, can't decrypt | Darwin: `/var/root/.ssh`, NixOS: `/root/.ssh` |
| Not rotating age/SSH keys | Compromised keys leak all secrets | Document rotation procedure, test periodically |
| Lanzaboote keys in git | Private keys exposed | Encrypt via sops-nix, only commit public keys |

## UX Pitfalls

Common user experience mistakes in this domain.

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Long rebuild times | Users avoid making changes | Use `nixos-rebuild switch` for testing, profile rebuilds |
| Cryptic error messages | Users can't self-diagnose | Document common errors and solutions |
| Missing documentation on rebuild process | Users don't know how to apply changes | Clear README with rebuild commands for each platform |
| Not handling failed rebuilds gracefully | System in broken state | Always test with `nixos-rebuild build` first |
| Secrets not available before login | Services fail at boot | Ensure sops-nix runs early, test boot process |
| No rollback procedure documented | Users panic when things break | Document `nixos-rebuild --rollback` and firmware reset |

## "Looks Done But Isn't" Checklist

Things that appear complete but are missing critical pieces.

- [ ] **Secrets Management:** sops-nix imported but no actual secrets encrypted yet - verify secrets in `.sops.yaml` patterns
- [ ] **Cross-Platform:** darwin/ and nixos/ exist but shared/ is empty or not imported - verify both platforms import shared modules
- [ ] **Flake Inputs:** Inputs defined but not all have `follows` for nixpkgs - verify consistent nixpkgs following
- [ ] **home-manager:** Module imported but `extraSpecialArgs` missing - verify inputs accessible in home configs
- [ ] **Secure Boot:** lanzaboote enabled but keys not generated/enrolled - verify `/etc/secureboot` populated
- [ ] **State Versions:** Config works but stateVersion not set - verify both system and home state versions
- [ ] **Git Tracking:** Files exist but not in git - run `git status` before rebuild
- [ ] **Hardware Config:** `hardware-configuration.nix` exists but outdated - regenerate if hardware changed

## Recovery Strategies

When pitfalls occur despite prevention, how to recover.

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Secret leaked to nix store | HIGH | Rotate all affected credentials, rebuild store without secret |
| Untracked files not in flake | LOW | `git add` files, rebuild |
| Flaky input broke system | MEDIUM | `git checkout flake.lock`, rebuild, pin working version |
| Secure boot unbootable | HIGH | Disable secure boot in firmware, boot from USB, fix keys |
| home-manager conflicts | MEDIUM | Remove standalone home-manager, use module integration consistently |
| State version wrong | MEDIUM | Research migrations, set correct version, test thoroughly |
| Configuration drift | HIGH | Audit both platforms, extract shared modules, refactor |

## Pitfall-to-Phase Mapping

How roadmap phases should address these pitfalls.

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Untracked files | Phase 1 (Foundation) | `git status` clean before any rebuild |
| Input version drift | Phase 1 (Foundation) | Regular `nix flake update` in commit history |
| Secrets in nix store | Phase 2 (Secrets) | Verify no secrets in `/nix/store` |
| Cross-platform drift | Phase 1 (Foundation) | Both platforms build from same commit |
| home-manager integration | Phase 1 (Foundation) | `home-manager` command not needed, use rebuild |
| Lanzaboote misconfiguration | Phase 3 (NixOS Security) | `sbctl verify` shows secure boot enabled |
| State version mismatches | Phase 1 (Foundation) | Versions set at initialization, documented |

## Sources

- Nix Flakes documentation: https://nix.dev/concepts/flakes
- home-manager manual: https://nix-community.github.io/home-manager/
- sops-nix documentation: https://github.com/Mic92/sops-nix
- lanzaboote documentation: https://github.com/nix-community/lanzaboote
- NixOS manual on state versions: https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
- Personal experience with Nix Flake configurations
- Analysis of existing project structure and common patterns

---
*Pitfalls research for: Nix Flake Configuration for NixOS and Darwin Systems*
*Researched: 2026-03-14*