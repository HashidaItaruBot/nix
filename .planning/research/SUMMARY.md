# Research Summary: v1.3 Podman + OpenHands on macOS

**Domain:** Container-based AI development environment
**Researched:** 2026-03-20
**Overall confidence:** HIGH

## Executive Summary

This research investigated the technology stack required to run OpenHands (an AI-driven development agent) with Podman on macOS, integrated into the existing Nix configuration project.

**Key findings:**
1. **Podman** is the recommended container runtime for macOS - officially supported via Homebrew, Docker API compatible, and daemonless architecture
2. **OpenHands** is distributed as a container image (`ghcr.io/openhands/openhands:latest`) that runs on port 3000 with WebSocket on 3001
3. **litellm** (available in nixpkgs v1.80.0) provides LLM abstraction for multi-provider support including Aliyun Bailian (Qwen, Kimi)
4. The existing Darwin Nix structure (`darwin/packages/`) can accommodate Podman installation alongside Homebrew

**Critical integration point:** Podman on macOS requires a VM (`podman machine init` + `podman machine start`). This VM setup is a one-time initialization that must happen outside of Nix's declarative management.

## Key Findings

**Stack:** Podman (Homebrew) + OpenHands container + litellm (optional proxy)
**Architecture:** Containerized AI agent with host volume mounts for persistence
**Critical pitfall:** Podman machine VM must be initialized manually; Nix can only install the binary, not manage the VM lifecycle

## Implications for Roadmap

Based on research, suggested phase structure:

1. **Phase 1: Podman Installation** - Install and initialize Podman
   - Addresses: Container runtime setup
   - Avoids: VM initialization issues by doing it first

2. **Phase 2: OpenHands Container Definition** - Define container run configuration
   - Addresses: Basic container execution, port mapping
   - Avoids: Network/volume configuration confusion

3. **Phase 3: LLM Backend Configuration** - Configure Aliyun Bailian via litellm
   - Addresses: Qwen/Kimi model access
   - Avoids: API key management complexity

4. **Phase 4: Workspace + Persistence** - Volume mounts and git integration
   - Addresses: Working directory persistence, conversation history
   - Avoids: Data loss between container restarts

**Phase ordering rationale:**
- Podman must be installed and running before any container work
- Basic container execution validates the runtime before adding complexity
- LLM configuration is the primary value driver - test early
- Workspace/persistence is operational concern - can iterate

**Research flags for phases:**
- Phase 1: Standard patterns (podman machine), unlikely to need research
- Phase 2: Standard container run, unlikely to need research
- Phase 3: May need deeper litellm + Aliyun API research
- Phase 4: Standard volume mounts, unlikely to need research

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Verified with official docs, nixpkgs, GitHub sources |
| Features | HIGH | OpenHands configuration from official repository |
| Architecture | HIGH | Standard container patterns, well documented |
| Pitfalls | MEDIUM | Based on Podman documentation; real-world issues may vary |

## Gaps to Address

- OpenHands V1 (new SDK-based architecture) vs V0 (legacy) differences - current research based on V1 codebase but some configuration files still reference legacy V0
- Aliyun Bailian specific litellm configuration - needs validation with actual API keys
- Podman machine VM resource allocation (CPU/RAM) defaults may need tuning
