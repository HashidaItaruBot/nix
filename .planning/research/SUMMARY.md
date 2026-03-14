# Project Research Summary

**Project:** Nix Flake Configuration System (NixOS + Darwin)
**Domain:** Nix Flake System Configuration Management
**Researched:** 2026-03-14
**Confidence:** HIGH

## Executive Summary

This is a cross-platform Nix Flake configuration system designed to manage both NixOS (Linux) and Darwin (macOS) systems from a single declarative codebase. Expert practitioners build such systems using Nix Flakes with proper input pinning, home-manager for user-space management, and sops-nix for secrets encryption. The recommended approach follows a modular structure with platform-specific directories (darwin/, nixos/) importing from a shared/ directory for cross-platform code.

The key technical risk is the complexity of cross-platform configuration management. This is mitigated through strict module boundaries, proper secrets management via sops-nix (never hardcoding secrets), and consistent use of `nixpkgs.follows` to prevent version drift. The second major risk is the learning curve for Nix Flakes themselves; this is addressed by establishing clear patterns early (git tracking for all files, proper home-manager integration) and avoiding common pitfalls like mixing standalone and module-based home-manager.

## Key Findings

### Recommended Stack

The stack centers on Nix Flakes with Lix as the Nix implementation, nixpkgs-unstable for packages, home-manager for user configuration, nix-darwin for macOS system management, and sops-nix for secrets. All inputs should follow the same nixpkgs version to prevent closure bloat and version conflicts.

**Core technologies:**
- **Nix Flakes:** Declarative, reproducible configuration with locked dependencies
- **Lix:** Modern, performant Nix implementation (alternative to CppNix)
- **home-manager:** Declarative user-space management (module integration)
- **nix-darwin:** NixOS-like module system for macOS
- **sops-nix:** Age-encrypted secrets in git with atomic provisioning
- **alejandra:** Uncompromising Nix formatter (preferred over nixpkgs-fmt)

**Platform-specific:**
- **lanzaboote:** UEFI Secure Boot for NixOS (requires sops-nix for key storage)
- **plasma-manager:** Declarative KDE Plasma configuration
- **microvm:** Lightweight VMs for NixOS hosts
- **nix-flatpak:** Declarative Flatpak management

### Expected Features

Users expect a modular configuration structure with cross-platform support, declarative user management via home-manager, and secure secrets handling. Differentiators include secure boot support, MicroVM virtualization, and comprehensive desktop configuration.

**Must have (table stakes):**
- Modular structure (darwin/, nixos/, shared/) -- essential for maintainability
- Home-manager integration -- core value proposition
- Secrets management (sops-nix) -- required for any real configuration
- Cross-platform support (NixOS + Darwin) -- primary project goal
- Shell configuration (zsh + oh-my-zsh) -- daily driver functionality
- Git/SSH configuration -- developer workflow
- Direnv + nix-direnv -- development environments
- Nix LSP and formatting -- self-hosting development

**Should have (differentiators):**
- Secure Boot (lanzaboote) -- security hardening for NixOS
- MicroVM support -- service isolation and testing
- nixvim -- declarative Neovim configuration
- Plasma Manager -- declarative KDE Plasma setup
- Cross-platform secret sharing -- simplified secret management
- Homebrew integration (Darwin) -- macOS app coverage

**Defer (v2+):**
- Impermanence (tmpfs root) -- advanced security pattern, significant restructure
- Disko for declarative partitioning -- new system setup only
- NixOS anywhere / remote deployment -- multi-machine management
- Binary cache (Cachix/attic) -- performance optimization for teams

### Architecture Approach

The architecture follows a three-tier structure: flake.nix as the root entry point, platform directories (darwin/, nixos/) for OS-specific configuration, and a shared/ directory for cross-platform modules. Key patterns include using `specialArgs` to pass context to all modules, `inputs.follows` to ensure single nixpkgs version, and inline home-manager module integration with `useGlobalPkgs = true`.

**Major components:**
1. **flake.nix** -- Root entry point defining inputs, outputs, and system configurations
2. **Platform directories (darwin/, nixos/)** -- OS-specific modules, packages, and services
3. **shared/** -- Cross-platform home-manager modules and system configuration
4. **sops-nix layer** -- Encrypted secrets decrypted at activation time

**Critical patterns:**
- `inputs.xxx.follows = "nixpkgs"` ensures version consistency
- `specialArgs = { inherit inputs self; }` passes context to modules
- `home-manager.useGlobalPkgs = true` prevents package duplication
- Secrets referenced via `config.sops.secrets.*.path`, never hardcoded

### Critical Pitfalls

1. **Untracked files not visible to Nix Flakes** -- Always `git add` new files before rebuild; flakes only see git-tracked content
2. **Secrets leaked to Nix store** -- Use sops-nix exclusively; never use `builtins.readFile` on secrets or hardcode values
3. **Cross-platform configuration drift** -- Maintain strict shared/ directory; avoid `if stdenv.isDarwin` conditionals in shared code
4. **home-manager integration mistakes** -- Use module integration exclusively; set `useGlobalPkgs`, `useUserPackages`, and `extraSpecialArgs`
5. **Input version drift** -- Use `nixpkgs.follows` for all inputs; schedule regular update cycles

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Foundation
**Rationale:** Core infrastructure must be correct before adding features. Establishes git hygiene, proper input structure, and home-manager integration patterns that prevent future rework.
**Delivers:** Working cross-platform flake with modular structure, home-manager integration, basic shell/git/ssh config
**Addresses:** Modular structure, home-manager, cross-platform support, shell config, git/ssh config, direnv, dev tools
**Avoids:** Untracked files, input version drift, cross-platform drift, home-manager integration mistakes, state version mismatches

### Phase 2: Secrets Management
**Rationale:** Secrets infrastructure is required before any real services can be configured. Must be working before secure boot (Phase 3) which depends on encrypted key storage.
**Delivers:** sops-nix integration with age encryption, secrets for API keys and service configs
**Uses:** sops-nix, age/SSH key encryption
**Implements:** shared/secrets/ directory structure, secret injection pattern
**Avoids:** Secrets leaked to nix store

### Phase 3: NixOS-Specific Features
**Rationale:** Platform-specific features can be developed in parallel after foundation is stable. Secure boot requires secrets infrastructure from Phase 2.
**Delivers:** Secure boot (lanzaboote), MicroVM support, Plasma desktop configuration, nixvim
**Uses:** lanzaboote, microvm, plasma-manager, nixvim
**Avoids:** Lanzaboote misconfiguration (requires working sops-nix first)

### Phase 4: Darwin-Specific Features
**Rationale:** macOS-specific features can be developed in parallel with NixOS features after foundation.
**Delivers:** Homebrew integration, macOS system defaults, platform-specific packages
**Uses:** nix-darwin, homebrew

### Phase 5: Desktop Environment
**Rationale:** Full desktop setup depends on platform foundations and secrets. Complex integration requiring earlier phases complete.
**Delivers:** Complete Plasma 6 setup, audio (PipeWire), display manager (SDDM), power management
**Uses:** plasma-manager, nix-flatpak
**Implements:** Full GUI desktop experience

### Phase Ordering Rationale

- **Phase 1 before all others:** Foundation establishes correct patterns; fixing mistakes later is expensive (e.g., reworking home-manager integration)
- **Phase 2 before Phase 3:** Secure boot requires encrypted key storage via sops-nix
- **Phase 3 and 4 can proceed in parallel:** Platform-specific work is independent after foundation
- **Phase 5 last:** Desktop environment is complex and benefits from all prior infrastructure

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 3 (NixOS-Specific):** Lanzaboote integration is complex; key generation and enrollment process needs documentation
- **Phase 5 (Desktop Environment):** Plasma 6 configuration through plasma-manager has extensive options; may need research for specific features

Phases with standard patterns (skip research-phase):
- **Phase 1 (Foundation):** Well-documented patterns; home-manager, flake structure, and modular organization have extensive examples
- **Phase 2 (Secrets Management):** sops-nix is well-documented with clear setup patterns
- **Phase 4 (Darwin-Specific):** nix-darwin follows standard NixOS module patterns

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All recommendations from active, well-documented projects with 500+ stars |
| Features | MEDIUM | Based on project analysis and training knowledge; web searches returned limited results |
| Architecture | HIGH | Derived from project codebase analysis and established Nix patterns |
| Pitfalls | HIGH | Well-documented issues from official sources and community experience |

**Overall confidence:** HIGH

### Gaps to Address

- **Homebrew integration details:** nix-darwin homebrew module specifics may need research during Phase 4 implementation
- **MicroVM networking:** Virtual machine networking configuration may need specific research for the use case
- **Plasma 6 specific features:** Desktop environment configuration has many options; specific features (Wayland, gaming) may need targeted research

## Sources

### Primary (HIGH confidence)
- home-manager (9476+ stars) -- https://github.com/nix-community/home-manager
- nix-darwin -- https://github.com/nix-darwin/nix-darwin
- sops-nix (2686+ stars) -- https://github.com/Mic92/sops-nix
- lanzaboote (1565+ stars) -- https://github.com/nix-community/lanzaboote
- microvm (2365+ stars) -- https://github.com/microvm-nix/microvm.nix
- Project codebase analysis -- flake.nix, nixos/, darwin/, shared/ directories

### Secondary (MEDIUM confidence)
- nix-flatpak (803+ stars) -- Flatpak management
- plasma-manager (1093+ stars) -- KDE Plasma configuration
- Training knowledge of Nix ecosystem patterns

### Documentation References
- Nix Flakes: https://nix.dev/concepts/flakes
- NixOS manual: https://nixos.org/manual/nixos/stable/
- home-manager documentation: https://nix-community.github.io/home-manager/

---
*Research completed: 2026-03-14*
*Ready for roadmap: yes*