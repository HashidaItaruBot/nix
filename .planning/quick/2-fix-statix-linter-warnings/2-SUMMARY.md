---
phase: quick-2
plan: 01
subsystem: linting
tags:
  - statix
  - linter
  - code-quality
  - nix
dependency_graph:
  requires: []
  provides:
    - "Zero statix warnings"
  affects:
    - "CI statix check workflow"
tech_stack:
  added: []
  patterns:
    - "Nested attribute sets for repeated keys"
    - "Underscore pattern for unused function arguments"
key_files:
  created: []
  modified:
    - darwin/default.nix
    - darwin/home/default.nix
    - flake.nix
    - nixos/default.nix
    - nixos/hardware-configuration.nix
    - nixos/home/default.nix
    - nixos/home/kitty.nix
    - nixos/home/nixvim/plugins/nix-lsp.nix
    - nixos/home/nixvim/plugins/treesitter.nix
    - nixos/home/ssh.nix
    - nixos/packages/flatpak.nix
    - nixos/sshd.nix
    - shared/home/default.nix
    - shared/home/opencode.nix
    - shared/home/ssh.nix
decisions:
  - "Merged duplicate keys into nested attribute sets per statix W20 recommendation"
  - "Replaced empty patterns {...}: with _: per statix W10 recommendation"
metrics:
  duration: "5 minutes"
  completed_date: "2026-03-14"
  warnings_fixed: 22
---

# Phase Quick-2 Plan 01: Fix Statix Linter Warnings Summary

## One-liner

Fixed all 22 statix linter warnings by merging duplicate keys into nested attribute sets (16 W20) and replacing empty patterns with underscore (6 W10).

## Changes Made

### Task 1: W20 Duplicate Key Warnings (16 instances)

Merged duplicate keys into nested attribute sets across 10 files:

| File | Keys Merged |
|------|-------------|
| darwin/default.nix | system.primaryUser, system.defaults, system.stateVersion |
| darwin/home/default.nix | home-manager.* (5 keys) |
| flake.nix | plasma-manager.* (3 keys) |
| nixos/default.nix | networking.* (3 keys), services.* (9 keys) |
| nixos/hardware-configuration.nix | boot.* (12 keys), fileSystems.* (5 keys), hardware.* (4 keys) |
| nixos/home/default.nix | home-manager.* (5 keys) |
| nixos/home/nixvim/plugins/nix-lsp.nix | plugins.* (12 keys) |
| nixos/home/nixvim/plugins/treesitter.nix | plugins.* (3 keys) |
| nixos/packages/flatpak.nix | services.flatpak.* (4 keys) |
| shared/home/default.nix | home.* (3 keys) |

### Task 2: W10 Empty Pattern Warnings (6 instances)

Replaced `{...}:` with `_:` in 5 files:

| File | Pattern Changed |
|------|-----------------|
| shared/home/ssh.nix | Line 1 |
| nixos/home/ssh.nix | Line 1 |
| shared/home/opencode.nix | Line 1 |
| nixos/sshd.nix | Line 1 |
| nixos/home/kitty.nix | Line 1 |

## Verification

```bash
statix check .
```

Output: No warnings (clean)

## Commits

| Commit | Description |
|--------|-------------|
| 4f1b247 | fix(quick-2): merge duplicate keys into nested attribute sets (W20) |
| f4a4b9e | fix(quick-2): replace empty patterns with underscore (W10) |

## Deviations from Plan

None - plan executed exactly as written.

## Self-Check: PASSED

- [x] statix check reports 0 warnings
- [x] All 16 W20 duplicate keys merged into nested attribute sets
- [x] All 6 W10 empty patterns replaced with underscore
- [x] All commits created with proper format