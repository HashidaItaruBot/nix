# Nix Configuration Project

## What This Is

A unified Nix Flake project for managing NixOS and Darwin (macOS) system configurations with modular, cross-platform design. Provides declarative system configuration, user environment management via home-manager, and secure secrets handling with sops-nix.

## Core Value

Single source of truth for all system configurations across platforms — reproducible, version-controlled, and secure.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Cross-platform configuration sharing (shared/ directory)
- [ ] NixOS system configuration with secure boot (lanzaboote)
- [ ] Darwin/macOS system configuration
- [ ] User environment management via home-manager
- [ ] Secrets management via sops-nix
- [ ] Modular package organization per platform

### Out of Scope

- Non-Nix systems (Windows, traditional Linux distros) — project is Nix-focused
- Real-time configuration sync — configurations are version-controlled and deployed manually

## Context

This is a brownfield project with established structure:
- **darwin/**: macOS-specific configurations (home, packages)
- **nixos/**: NixOS-specific configurations (home, packages, secureboot, hardware)
- **shared/**: Cross-platform configurations (home, secrets, system)
- **flake.nix**: Main flake configuration with inputs/outputs
- **.sops.yaml**: Sops encryption configuration for secrets

Key technologies: Nix Flakes, home-manager, sops-nix, lanzaboote (secure boot)

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
| lanzaboote for secure boot | Modern UEFI secure boot on NixOS | — Pending |

---
*Last updated: 2026-03-14 after initialization*