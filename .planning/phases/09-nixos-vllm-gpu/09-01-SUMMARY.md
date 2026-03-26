---
phase: 09-nixos-vllm-gpu
plan: 01
subsystem: infra
tags: [vllm, rocm, gpu, podman, container, nixos]

# Dependency graph
requires:
  - phase: 08-openhands
    provides: Podman container runtime on NixOS host
provides:
  - vLLM inference service with OpenAI-compatible API
  - GPU device passthrough configuration for AMD ROCm
  - systemd service for vLLM with auto-start
affects: [ai-inference, llm-api]

# Tech tracking
tech-stack:
  added: [vllm, rocm/vllm-dev:base container image]
  patterns: [Podman GPU passthrough, systemd container service]

key-files:
  created:
    - nixos/containers/vllm.nix
  modified:
    - nixos/default.nix
    - nixos/containers/default.nix

key-decisions:
  - "Use Podman + official ROCm image instead of nixos-container for vLLM"
  - "GPU 1 selected via HIP_VISIBLE_DEVICES=1 consistent with hardware-configuration.nix"
  - "HSA_OVERRIDE_GFX_VERSION=10.3.0 for consumer GPU compatibility"

patterns-established:
  - "Podman --device flag for GPU device passthrough"
  - "systemd service dependency on podman.service"

requirements-completed: [VLLM-01, VLLM-02, VLLM-05]

# Metrics
duration: 3min
completed: 2026-03-26
---

# Phase 09 Plan 01: vLLM Podman Container with GPU Passthrough Summary

**Configured vLLM inference service using Podman with AMD ROCm GPU passthrough, providing OpenAI-compatible API endpoint on port 8000**

## Performance

- **Duration:** 3 min
- **Started:** 2026-03-26T14:02:49Z
- **Completed:** 2026-03-26T14:05:13Z
- **Tasks:** 3
- **Files modified:** 3

## Accomplishments
- Added user `zhaochanglong` to `render` group for GPU device access
- Created vLLM systemd service with Podman container and GPU device passthrough
- Configured firewall for port 8000 and auto-start on boot

## Task Commits

Each task was committed atomically:

1. **Task 1: Add user to render group for GPU access** - `f5a1fae` (feat)
2. **Task 2: Create vLLM Podman container configuration** - `36ccff0` (feat)
3. **Task 3: Update containers module import** - `565ad1b` (feat)

## Files Created/Modified
- `nixos/default.nix` - Added 'render' group to user for GPU device access
- `nixos/containers/vllm.nix` - vLLM systemd service with Podman and GPU passthrough
- `nixos/containers/default.nix` - Module import for vllm.nix

## Decisions Made
- Used Podman + official `rocm/vllm-dev:base` image for simplicity and official support
- GPU selection uses GPU 1 (`HIP_VISIBLE_DEVICES=1`) consistent with hardware-configuration.nix
- `HSA_OVERRIDE_GFX_VERSION=10.3.0` set for consumer GPU (RDNA2/RDNA3) compatibility
- Model path at `/var/lib/vllm/models` - user must place model files here

## Deviations from Plan

None - plan executed exactly as written.

## User Setup Required

**External services require manual configuration.** See plan frontmatter `user_setup` for:
- Model files must be downloaded to `/var/lib/vllm/models/`
- Example: `huggingface-cli download Qwen/Qwen2.5-7B-Instruct --local-dir /var/lib/vllm/models/Qwen2.5-7B-Instruct`

## Verification Commands

After applying configuration with `sudo nixos-rebuild switch --flake .#nixos`:

1. Verify service is defined:
   ```bash
   systemctl cat vllm | grep -E "(Description|ExecStart|After)"
   ```

2. Verify GPU devices exist:
   ```bash
   ls -la /dev/kfd /dev/dri/
   ```

3. Verify user groups (after logout/login):
   ```bash
   groups zhaochanglong | grep render
   ```

## Next Phase Readiness
- vLLM container configuration complete
- Requires model files to be placed before service can start
- Service will auto-start on boot once model is available

## Self-Check: PASSED
- SUMMARY.md exists at .planning/phases/09-nixos-vllm-gpu/09-01-SUMMARY.md
- All task commits verified (f5a1fae, 36ccff0, 565ad1b)
- Final metadata commit verified (b2865e7)

---
*Phase: 09-nixos-vllm-gpu*
*Completed: 2026-03-26*