---
phase: 5
slug: validation-enhancement
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-14
---

# Phase 5 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | nix flake check + alejandra + statix |
| **Config file** | flake.nix (built-in), .github/workflows/ci.yml (Wave 0) |
| **Quick run command** | `nix flake check` |
| **Full suite command** | `nix flake check && alejandra --check . && statix check .` |
| **Estimated runtime** | ~60-120 seconds (flake eval) + ~5 seconds (formatters) |

---

## Sampling Rate

- **After every task commit:** Run `nix flake check`
- **After every plan wave:** Run `nix flake check && alejandra --check . && statix check .`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 05-01-01 | 01 | 1 | VAL-01 | script | `./scripts/verify-secrets.sh` | ❌ W0 | ⬜ pending |
| 05-01-02 | 01 | 1 | VAL-02 | manual | Verify README.md exists | ❌ W0 | ⬜ pending |
| 05-01-03 | 01 | 1 | VAL-03 | manual | Test rebuild on both platforms | N/A | ⬜ pending |
| 05-01-04 | 01 | 1 | VAL-04 | script | Check sops-nix decrypt log | N/A | ⬜ pending |
| 05-02-01 | 02 | 1 | TOOL-01 | automated | `alejandra --check .` | ❌ W0 | ⬜ pending |
| 05-02-02 | 02 | 1 | TOOL-02 | automated | `statix check .` | ❌ W0 | ⬜ pending |
| 05-02-03 | 02 | 1 | TOOL-03 | manual | `nom build .#nixosConfigurations.nixos` | N/A | ⬜ pending |
| 05-02-04 | 02 | 1 | TOOL-04 | manual | Verify nixd LSP works in editor | N/A | ⬜ pending |
| 05-03-01 | 03 | 2 | QUAL-01 | ci | `nix flake check` in GitHub Actions | ❌ W0 | ⬜ pending |
| 05-03-02 | 03 | 2 | QUAL-02 | manual | Document update schedule in README | N/A | ⬜ pending |
| 05-03-03 | 03 | 2 | QUAL-03 | automated | No duplicate code (statix) | N/A | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `.github/workflows/ci.yml` — GitHub Actions CI pipeline
- [ ] `scripts/verify-secrets.sh` — Script to verify no secrets in nix store
- [ ] `README.md` — Project documentation

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Rebuild NixOS | VAL-03 | Requires NixOS hardware/VM | Run `sudo nixos-rebuild switch --flake .#nixos` |
| Rebuild Darwin | VAL-03 | Requires macOS hardware | Run `darwin-rebuild switch --flake .#zhaochanglongdeMacBook-Air` |
| nom build visualization | TOOL-03 | Interactive UI | Run `nom build .#nixosConfigurations.nixos` |
| nixd LSP integration | TOOL-04 | Editor-specific | Open flake.nix in editor, verify completions |
| Regular update schedule | QUAL-02 | Process/procedure | Review README for schedule section |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending