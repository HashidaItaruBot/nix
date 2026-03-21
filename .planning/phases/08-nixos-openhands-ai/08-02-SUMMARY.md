---
phase: 08-nixos-openhands-ai
plan: 02
subsystem: secrets
tags: [sops-nix, encryption, api-keys, nixos]

# Dependency graph
requires:
  - phase: 08-01
    provides: nixos-container configuration with bindMount for secrets
provides:
  - SOPS configuration for LLM API key encryption
  - Secret path /run/secrets/openhands/LLM_API_KEY
affects: [08-03]

# Tech tracking
tech-stack:
  added: []
  patterns: [sops-nix secret reuse, explicit path configuration]

key-files:
  created: []
  modified:
    - nixos/sops.nix

key-decisions:
  - "Reuse existing alibaba_api_key from shared/secrets/api_keys.yaml instead of creating new secret file"
  - "Explicit path configuration to match container bindMount and systemd EnvironmentFile"

patterns-established:
  - "SOPS secret reuse: Multiple services can reference the same encrypted secret with different output paths"
  - "Secret path alignment: SOPS path, bindMount directory, and EnvironmentFile must match exactly"

requirements-completed: [OH-03]

# Metrics
duration: 10min
completed: "2026-03-21"
---

# Phase 8 Plan 02: SOPS LLM API Key Configuration Summary

**SOPS configuration for OpenHands LLM API key with secret reuse from existing alibaba_api_key**

## Performance

- **Duration:** 10 min
- **Started:** 2026-03-21T12:30:00Z
- **Completed:** 2026-03-21T12:40:00Z
- **Tasks:** 3
- **Files modified:** 1

## Accomplishments

- Configured SOPS to decrypt and expose LLM API key at `/run/secrets/openhands/LLM_API_KEY`
- Reused existing `alibaba_api_key` from `shared/secrets/api_keys.yaml` to avoid duplicate secrets
- Aligned secret path with container bindMount and systemd EnvironmentFile configuration

## Task Commits

Each task was committed atomically:

1. **Task 1: Add SOPS configuration** - `aa08203` (feat)
2. **Task 2: Create secret template** - `efdda94` (feat)
3. **Task 3: Reuse existing secret** - `c7c0335` (fix)

## Files Created/Modified

- `nixos/sops.nix` - Added `openhands_llm_api_key` secret configuration with explicit path

## Decisions Made

- **Reuse existing secret:** Instead of creating a new `nixos/secrets/openhands.yaml` file, we reused the existing `alibaba_api_key` from `shared/secrets/api_keys.yaml`. This simplifies secret management and ensures consistency.
- **Explicit path configuration:** The `path = "/run/secrets/openhands/LLM_API_KEY"` configuration is critical for aligning with the container's bindMount and systemd EnvironmentFile.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Reused existing secret instead of creating new one**
- **Found during:** Task 2 (creating openhands.yaml template)
- **Issue:** Plan specified creating a new `nixos/secrets/openhands.yaml` file, but `shared/secrets/api_keys.yaml` already contains `alibaba_api_key` which serves the same purpose
- **Fix:** Updated `sopsFile` to reference `${self}/shared/secrets/api_keys.yaml` and `key` to `alibaba_api_key`
- **Files modified:** nixos/sops.nix
- **Verification:** `nix eval .#nixos` succeeds, secret path correctly configured
- **Committed in:** c7c0335

---

**Total deviations:** 1 auto-fixed (missing critical - secret reuse)
**Impact on plan:** Improved maintainability by reusing existing secret, avoided duplicate secret management

## User Setup Required

**External services require manual configuration.** User has confirmed:
- Alibaba Bailian API key is already configured in `shared/secrets/api_keys.yaml`
- SOPS encryption is working correctly

## Next Phase Readiness

- SOPS secret configuration complete
- Secret path `/run/secrets/openhands/LLM_API_KEY` ready for container consumption
- Ready for Phase 8 Plan 03: Apply configuration and verify service

## Self-Check: PASSED

- [x] nixos/sops.nix contains `openhands_llm_api_key` configuration
- [x] sopsFile points to `${self}/shared/secrets/api_keys.yaml`
- [x] key is set to `alibaba_api_key`
- [x] path is set to `/run/secrets/openhands/LLM_API_KEY`
- [x] OH-03 requirement satisfied

---
*Phase: 08-nixos-openhands-ai*
*Completed: 2026-03-21*