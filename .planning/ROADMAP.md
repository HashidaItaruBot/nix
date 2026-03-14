# Roadmap: Nix Configuration Project

## Overview

This roadmap captures the journey to a unified Nix Flake configuration system for managing NixOS and Darwin (macOS) systems. Phases 1-4 represent the foundational work already validated and complete. Phase 5 focuses on validation, tooling enhancement, and quality improvements to harden the existing implementation.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Foundation & Core Environment** - Modular flake structure, home-manager, user environment, package management
- [x] **Phase 2: Secrets Management** - sops-nix integration with age encryption
- [x] **Phase 3: Platform-Specific Configuration** - NixOS and Darwin platform features
- [x] **Phase 4: Development Tools** - Editors, AI tooling, development environment
- [ ] **Phase 5: Validation & Enhancement** - Verify implementation, improve tooling, add CI/CD

## Phase Details

### Phase 1: Foundation & Core Environment
**Goal**: Establish modular flake structure with cross-platform support, home-manager integration, and core user environment
**Depends on**: Nothing (first phase)
**Requirements**: FOUND-01, FOUND-02, FOUND-03, FOUND-04, FOUND-05, USER-01, USER-02, USER-03, USER-04, USER-05, USER-06, PKG-01, PKG-02, PKG-03, PKG-04
**Status**: Complete (validated)

**Success Criteria** (what must be TRUE):
  1. Flake builds successfully for both NixOS and Darwin platforms
  2. Home-manager integrates with useGlobalPkgs and useUserPackages
  3. Zsh with oh-my-zsh provides functional shell environment
  4. Git and SSH configurations are declaratively managed
  5. Direnv with nix-direnv automatically loads development environments

**Plans**: 4 plans (complete)
- [x] 01-01: Establish modular flake structure
- [x] 01-02: Configure home-manager integration
- [x] 01-03: Set up user environment (zsh, git, ssh, direnv)
- [x] 01-04: Configure package management

### Phase 2: Secrets Management
**Goal**: Secure secrets handling with sops-nix across platforms
**Depends on**: Phase 1
**Requirements**: SECRE-01, SECRE-02, SECRE-03, SECRE-04
**Status**: Complete (validated)

**Success Criteria** (what must be TRUE):
  1. Secrets are encrypted at rest with age encryption
  2. Secrets are decrypted automatically on system activation
  3. No secrets appear in the Nix store (verified)
  4. Cross-platform secret sharing works correctly

**Plans**: 2 plans (complete)
- [x] 02-01: Integrate sops-nix with age encryption
- [x] 02-02: Configure platform-specific sops paths

### Phase 3: Platform-Specific Configuration
**Goal**: Complete platform-specific configurations for NixOS and Darwin
**Depends on**: Phase 2
**Requirements**: NIXOS-01, NIXOS-02, NIXOS-03, NIXOS-04, NIXOS-05, NIXOS-06, DARWN-01, DARWN-02, DARWN-03
**Status**: Complete (validated)

**Success Criteria** (what must be TRUE):
  1. NixOS system boots with secure boot enabled via lanzaboote
  2. NixOS supports MicroVM virtualization
  3. Darwin system configuration is fully managed via nix-darwin
  4. Platform-specific packages are installed and functional

**Plans**: 2 plans (complete)
- [x] 03-01: Configure NixOS system (secure boot, MicroVM, SSH, Podman, Zerotier)
- [x] 03-02: Configure Darwin system (nix-darwin, home-manager, packages)

### Phase 4: Development Tools
**Goal**: Complete development environment with editors, AI tooling, and integrations
**Depends on**: Phase 3
**Requirements**: DEVEL-01, DEVEL-02, DEVEL-03, DEVEL-04, DEVEL-05, DEVEL-06, DEVEL-07
**Status**: Complete (validated)

**Success Criteria** (what must be TRUE):
  1. Neovim is fully configured via nixvim
  2. Kitty terminal is configured and functional
  3. VSCode and Zed editors are configured
  4. AI tooling (opencode, claude-code, MCP servers) works
  5. 1Password integration functions correctly

**Plans**: 2 plans (complete)
- [x] 04-01: Configure editors (nixvim, kitty, vscode, zed)
- [x] 04-02: Set up AI tooling and integrations

### Phase 5: Validation & Enhancement
**Goal**: Verify the implementation is correct, improve tooling, and establish quality processes
**Depends on**: Phase 4
**Requirements**: VAL-01, VAL-02, VAL-03, VAL-04, TOOL-01, TOOL-02, TOOL-03, TOOL-04, QUAL-01, QUAL-02, QUAL-03
**Status**: Ready to execute

**Success Criteria** (what must be TRUE):
  1. All secrets verified as properly encrypted (no secrets in nix store)
  2. Rebuild procedures documented for both platforms
  3. Improved Nix tooling (alejandra, statix, nom) is available
  4. CI/CD pipeline runs flake checks automatically
  5. Regular input update schedule is established

**Plans**: 4 plans in 2 waves

Plans:
- [x] 05-01-PLAN.md - Validation infrastructure (scripts, README)
- [x] 05-02-PLAN.md - Tooling enhancement (alejandra, statix, nom, nixd)
- [x] 05-03-PLAN.md - CI/CD pipeline (GitHub Actions)
- [ ] 05-04-PLAN.md - Quality improvements (update schedule, config consolidation)

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation & Core Environment | 4/4 | Complete | Validated |
| 2. Secrets Management | 2/2 | Complete | Validated |
| 3. Platform-Specific Configuration | 2/2 | Complete | Validated |
| 4. Development Tools | 2/2 | Complete | Validated |
| 5. Validation & Enhancement | 3/4 | In Progress | 2026-03-14 |

---
*Roadmap created: 2026-03-14*
*Last updated: 2026-03-14*