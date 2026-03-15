# Milestones

## v1.2 Workflow Enhancement (Shipped: 2026-03-15)

**Phases completed:** 1 phase (Phase 7), 4 plans

**Key accomplishments:**
- Added 'pr' branching strategy option to GSD config system
- Automatic branch creation when running GSD commands on main branch
- PR creation after phase completion with SUMMARY.md content extraction
- Branch cleanup before new phase start for clean workflow state

**See:** `.planning/milestones/v1.2-ROADMAP.md` for full phase details

---

## v1.1 CI Enhancements (Shipped: 2026-03-15)

**Phases completed:** 1 phase (Phase 6), 2 plans

**Key accomplishments:**
- Conditional sops configuration for CI environments using lib.mkIf
- CI time reduced from 60+ minutes to minutes with nix eval verification
- DeterminateSystems GitHub Actions for faster Nix installation and caching
- Eval verifies config correctness without actual builds

**See:** `.planning/milestones/v1.1-ROADMAP.md` for full phase details

---

## v1.0 MVP (Shipped: 2026-03-14)

**Phases completed:** 5 phases (Phases 1-4 validated, Phase 5 executed)

**Key accomplishments:**
- Established modular Nix Flake structure for cross-platform configuration (NixOS + Darwin)
- Integrated sops-nix with age encryption for secure secrets management
- Configured NixOS with secure boot (lanzaboote), MicroVM, and platform-specific features
- Set up development environment with nixvim, Kitty, VSCode, Zed, and AI tooling
- Added validation tooling: secret verification script, alejandra formatter, statix linter, nom visualizer
- Created multi-platform GitHub Actions CI pipeline with formatting and linting checks
- Documented rebuild procedures, update schedule, and validation procedures

**See:** `.planning/milestones/v1.0-ROADMAP.md` for full phase details

---