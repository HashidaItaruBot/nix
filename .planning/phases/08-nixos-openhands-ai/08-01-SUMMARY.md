---
phase: 08-nixos-openhands-ai
plan: 01
subsystem: infra
tags: [nixos-container, docker, openhands, llm, sops]

# Dependency graph
requires:
  - phase: N/A
    provides: Initial setup
provides:
  - NixOS container configuration for OpenHands AI
  - Docker runtime inside container
  - Port forwarding (host:3000 -> container:3000)
  - Data persistence bind mount
  - SOPS secret injection via EnvironmentFile
affects: [plan-02-sops-secrets, plan-03-deployment]

# Tech tracking
tech-stack:
  added: [nixos-container, docker, docker-compose]
  patterns: [declarative-container, systemd-service, sops-secret-injection]

key-files:
  created:
    - nixos/containers/openhands.nix
    - nixos/containers/docker-compose.yml
    - nixos/containers/default.nix
  modified:
    - nixos/default.nix

key-decisions:
  - "Use nixos-container with Docker inside for OpenHands isolation"
  - "Use EnvironmentFile for LLM_API_KEY injection from SOPS secrets"
  - "Use ExecStartPre to copy docker-compose.yml from Nix store to /var/lib/openhands"

patterns-established:
  - "Container module pattern: default.nix imports individual container configs"
  - "Secret injection pattern: SOPS secret -> bind mount -> EnvironmentFile"

requirements-completed: [OH-01, OH-02, OH-04, OH-05]

# Metrics
duration: 3min
completed: 2026-03-21
---

# Phase 08 Plan 01: OpenHands Container Configuration Summary

**NixOS declarative container with Docker runtime for OpenHands AI, featuring NAT port forwarding, data persistence, and SOPS secret injection**

## Performance

- **Duration:** 3 min
- **Started:** 2026-03-21T12:50:42Z
- **Completed:** 2026-03-21T12:53:13Z
- **Tasks:** 4 (including auto-fix)
- **Files modified:** 4

## Accomplishments

- Created complete NixOS container configuration for OpenHands AI
- Configured Docker runtime inside the container for OpenHands compatibility
- Set up NAT port forwarding (host:3000 -> container:3000) for web UI access
- Implemented data persistence via bind mount to /var/lib/openhands
- Configured SOPS secret injection for LLM_API_KEY via EnvironmentFile

## Task Commits

Each task was committed atomically:

1. **Task 1: Create openhands.nix container configuration** - `999a472` (feat)
2. **Task 2: Import containers module in default.nix** - `adc26ca` (feat)
3. **Task 3: Add docker-compose.yml configuration** - `6f18db1` (feat)
4. **Auto-fix: Add containers/default.nix** - `b61d655` (fix)

**Plan metadata:** `ea3fbe9` (docs: complete plan)

## Files Created/Modified

- `nixos/containers/openhands.nix` - Main container configuration with Docker runtime, port forwarding, bind mounts
- `nixos/containers/docker-compose.yml` - Docker Compose for OpenHands with Alibaba DashScope LLM
- `nixos/containers/default.nix` - Module import for containers directory
- `nixos/default.nix` - Added ./containers to imports list

## Decisions Made

- **nixos-container + Docker architecture**: Uses NixOS declarative container as outer isolation layer with Docker inside for OpenHands compatibility
- **EnvironmentFile for secrets**: LLM_API_KEY injected via systemd EnvironmentFile pointing to SOPS secret file
- **ExecStartPre for compose file**: docker-compose.yml copied from Nix store to /var/lib/openhands at service start

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Added containers/default.nix module import**
- **Found during:** Nix configuration verification
- **Issue:** The `./containers` import requires a `default.nix` file in the directory for Nix module system to find it
- **Fix:** Created `nixos/containers/default.nix` that imports `openhands.nix`
- **Files modified:** nixos/containers/default.nix
- **Verification:** `nix eval .#nixosConfigurations.nixos.config.networking.hostName` returns "nixos"
- **Committed in:** b61d655

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Essential fix for module system to work correctly. No scope creep.

## Issues Encountered

None - configuration validated successfully after adding the module import file.

## User Setup Required

None - no external service configuration required for this plan.

## Next Phase Readiness

- Container configuration complete, ready for SOPS secrets setup (Plan 02)
- docker-compose.yml configured but requires LLM_API_KEY to be provisioned
- Data directories will be created automatically by systemd.tmpfiles

---
*Phase: 08-nixos-openhands-ai*
*Completed: 2026-03-21*

## Self-Check: PASSED

All files and commits verified:
- nixos/containers/openhands.nix - FOUND
- nixos/containers/docker-compose.yml - FOUND
- nixos/containers/default.nix - FOUND
- Task 1 commit 999a472 - FOUND
- Task 2 commit adc26ca - FOUND
- Task 3 commit 6f18db1 - FOUND
- Auto-fix commit b61d655 - FOUND
- Final commit ea3fbe9 - FOUND