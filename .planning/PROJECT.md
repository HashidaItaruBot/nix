# Nix Configuration Project

## What This Is

A unified Nix Flake project for managing NixOS and Darwin (macOS) system configurations with modular, cross-platform design. Provides declarative system configuration, user environment management via home-manager, and secure secrets handling with sops-nix.

## Core Value

Single source of truth for all system configurations across platforms — reproducible, version-controlled, and secure.

## Requirements

### Validated

- ✓ Modular flake structure (darwin/nixos/shared) — v1.0
- ✓ NixOS system configuration with secure boot (lanzaboote) — v1.0
- ✓ Darwin/macOS system configuration — v1.0
- ✓ User environment management via home-manager — v1.0
- ✓ Secrets management via sops-nix — v1.0
- ✓ Modular package organization per platform — v1.0
- ✓ Development tooling (nixvim, editors, AI tools) — v1.0
- ✓ Validation infrastructure (scripts, documentation) — v1.0
- ✓ Nix tooling (alejandra, statix, nom, nixd) — v1.0
- ✓ CI/CD pipeline (GitHub Actions) — v1.0
- ✓ Quality processes (update schedule, consolidation) — v1.0

### Active

(None — awaiting next milestone)

### Out of Scope

- Non-Nix systems (Windows, traditional Linux distros) — project is Nix-focused
- Real-time configuration sync — configurations are version-controlled and deployed manually
- Imperative package installation — breaks reproducibility
- Multiple Nix implementations — Lix is standardized

## Context

**Shipped v1.0 MVP** with:
- **3,166 LOC** Nix code
- **Tech stack:** Nix Flakes, home-manager, sops-nix, lanzaboote, nix-darwin, nixvim
- **Platforms:** NixOS (x86_64-linux) and Darwin (aarch64-darwin)
- **CI:** Multi-platform GitHub Actions with alejandra and statix checks

Key decisions validated during development:
- Modular structure enables clean platform-specific overrides
- Git signing with 1Password SSH agent works well
- MicroVM provides declarative VM management

## Constraints

- **Platform**: NixOS and Darwin (macOS) only
- **Security**: All secrets must use sops-nix encryption
- **Declarative**: All configuration must be declarative, no imperative state
- **Git-tracked**: Nix only sees git-tracked files; all changes must be staged

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Modular structure (darwin/nixos/shared) | Enables code reuse across platforms | ✓ Good |
| home-manager for user environments | Declarative user-space configuration | ✓ Good |
| sops-nix for secrets | Secure, encrypted secrets in git | ✓ Good |
| lanzaboote for secure boot | Modern UEFI secure boot on NixOS | ✓ Good |
| alejandra over nixpkgs-fmt | More opinionated, faster formatting | ✓ Good |
| nixd over nil | Better flake support, actively maintained | ✓ Good |
| install-nix-action@master | Fixes macOS CI runner issues | ✓ Good |
| Shared config pattern | Common settings in shared/, platform overrides separate | ✓ Good |

---
*Last updated: 2026-03-14 after v1.0 milestone*