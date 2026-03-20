---
phase: 04-git-ssh
plan: 02
subsystem: darwin
tags: [podman, launchd, machine-init, auto-start]
dependency_graph:
  requires: [04-01]
  provides: [machine-init, auto-start-config]
  affects: [darwin/default.nix, scripts/init-podman-machine.sh]
tech_stack:
  added:
    - name: podman-machine
      purpose: VM management for Podman on macOS
  patterns:
    - launchd user agent for auto-start
    - idempotent shell script for initialization
key_files:
  created:
    - path: scripts/init-podman-machine.sh
      purpose: Idempotent machine initialization script
  modified:
    - path: darwin/default.nix
      purpose: Added launchd user agent configuration
decisions:
  - decision: Use init script instead of direct podman command in launchd
    rationale: Supports idempotent initialization, handles both first-run and subsequent boots
  - decision: KeepAlive=false
    rationale: Only start once at login, don't restart if machine stops
  - decision: 8GB RAM + 4 CPUs + 100GB disk
    rationale: Balanced resources for OpenHands workload while leaving headroom for macOS
metrics:
  duration: ~5 minutes
  completed: 2026-03-20
---

# Phase 04 Plan 02: Podman Machine Initialization Summary

**One-liner:** Configured Podman machine initialization script with 8GB RAM + 4 CPUs and launchd user agent for automatic startup at login.

## Tasks Completed

| # | Task | Type | Commit | Files |
|---|------|------|--------|-------|
| 1 | Create Podman machine initialization script | auto | f5cf1c3 (from 04-01) | scripts/init-podman-machine.sh |
| 2 | Configure launchd agent for auto-start | auto | fd69ca6 | darwin/default.nix |

## Task Details

### Task 1: Create Podman machine initialization script

**Status:** Completed (pre-existing from 04-01)

**Implementation:**
- Created `scripts/init-podman-machine.sh` with idempotent initialization logic
- Script checks if machine exists and is running before taking action
- First-run: `podman machine init --cpus 4 --memory 8192 --disk-size 100`
- Subsequent runs: `podman machine start` if stopped, exit if already running
- File has execute permission (chmod +x)

**Verification:**
```bash
test -x scripts/init-podman-machine.sh && \
grep -q "podman machine init --cpus 4 --memory 8192" scripts/init-podman-machine.sh
```

### Task 2: Configure launchd agent for auto-start

**Status:** Completed

**Implementation:**
```nix
launchd.user.agents.podman-start = {
  command = "${./scripts/init-podman-machine.sh}";
  serviceConfig = {
    KeepAlive = false;  # 只启动一次，不持续重启
    RunAtLoad = true;   # 登录时运行
    StandardOutPath = "/tmp/podman-start.log";
    StandardErrorPath = "/tmp/podman-start.err";
  };
};
```

**Verification:**
```bash
grep -q "launchd.user.agents.podman-start" darwin/default.nix && \
grep -q "init-podman-machine.sh" darwin/default.nix && \
grep -q "KeepAlive = false" darwin/default.nix && \
grep -q "RunAtLoad = true" darwin/default.nix
```

## Requirements Satisfied

- [x] **PODMAN-02:** `podman machine init` configured via init script
- [x] **PODMAN-03:** `podman machine start` configured via launchd agent
- [x] **PODMAN-04:** Machine resources set to 8GB RAM, 4 CPUs, 100GB disk

## Deviations from Plan

### Auto-fixed Issues

None - plan executed exactly as written.

## Key Decisions

1. **Init script approach:** Instead of running `podman machine start` directly in launchd, created a wrapper script that handles both initial setup and subsequent boots. This ensures idempotency.

2. **KeepAlive=false:** Chose not to keep the agent alive, as the Podman machine is a persistent VM that doesn't need restart supervision.

3. **Resource allocation:** Fixed 8GB RAM, 4 CPUs, 100GB disk as declarative constants. Users can modify via `podman machine set` if needed (Podman 5.0+).

## Next Steps

- Run `darwin-rebuild switch --flake .#darwin` to apply configuration
- On first login, launchd agent will initialize and start Podman machine
- Verify with `podman machine ls` (should show "Running" state)
- Verify resources with `podman machine inspect`

## Self-Check

Files created:
- [x] scripts/init-podman-machine.sh - EXISTS
- [x] darwin/default.nix - MODIFIED

Commits:
- [x] f5cf1c3 - scripts/init-podman-machine.sh (from 04-01)
- [x] fd69ca6 - darwin/default.nix launchd config

## Self-Check: PASSED
