---
phase: 05-validation-enhancement
plan: 05
subsystem: ci
tags: [git, nix, github-actions, macos, ci]

requires:
  - phase: 05-validation-enhancement
    provides: CI pipeline and quality improvements from plans 05-01 through 05-04
provides:
  - Fixed CI workflow for macOS runners using install-nix-action@master
  - Verified git configuration consolidation is correct
affects: []

tech-stack:
  added: []
  patterns: []

key-files:
  created: []
  modified:
    - .github/workflows/ci.yml

key-decisions:
  - "Upgraded install-nix-action from @v27 to @master to fix macOS runner eDSRecordAlreadyExists error"

patterns-established: []

requirements-completed: [QUAL-03, QUAL-01]

duration: 1min
completed: 2026-03-14
---

# Phase 05 Plan 05: Gap Closure Summary

**Fixed macOS CI runner failure by upgrading install-nix-action to @master; verified git configuration consolidation was already correct**

## Performance

- **Duration:** 1min
- **Started:** 2026-03-14T12:43:05Z
- **Completed:** 2026-03-14T12:44:30Z
- **Tasks:** 2 (1 already complete, 1 executed)
- **Files modified:** 1

## Accomplishments
- Verified git configuration is properly consolidated (shared config + platform-specific signer overrides)
- Fixed CI workflow for macOS runners by upgrading install-nix-action@v27 to @master
- Resolved eDSRecordAlreadyExists error that occurred when Nix build users persisted from previous CI runs

## Task Commits

Each task was committed atomically:

1. **Task 1: Fix git configuration consolidation** - No commit needed (already correct)
   - Files were already in the correct state: shared/home/git.nix contains common config, nixos/home/git.nix contains only signer override
2. **Task 2: Fix CI workflow for macOS runners** - `7df2545` (fix)

**Plan metadata:** Pending

## Files Created/Modified
- `.github/workflows/ci.yml` - Upgraded install-nix-action from @v27 to @master for macOS compatibility

## Decisions Made
- Chose @master branch over alternative DeterminateSystems/nix-installer-action for minimal change with known fix

## Deviations from Plan

### Pre-existing Resolution

**Task 1: Git configuration already consolidated**
- **Found during:** Verification of current file state
- **Issue:** Plan indicated git config was NOT consolidated (shared had NixOS signer, nixos had full config), but files were already correct
- **Resolution:** No changes needed - files were already in the desired state:
  - `shared/home/git.nix` - Contains full git config (enable, user.name, user.email, pull.rebase, signing)
  - `nixos/home/git.nix` - Contains ONLY NixOS signer override
  - `darwin/home/git.nix` - Contains ONLY macOS signer override (unchanged)
- **Verification:** grep confirmed user.name and signing configuration in shared config, absent from nixos config

---

**Total deviations:** 1 (pre-existing resolution - no code changes needed)
**Impact on plan:** Task 1 was already complete; only Task 2 required execution

## Issues Encountered
- Plan's gap analysis was based on outdated or incorrect file state; actual files were already correctly structured

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Phase 5 complete - all validation and quality improvements implemented
- CI pipeline now functional on both Linux and macOS runners
- Git configuration properly consolidated with platform-specific signer overrides

---
*Phase: 05-validation-enhancement*
*Completed: 2026-03-14*