# Feature Landscape

**Domain:** NixOS MicroVM running openclaw
**Researched:** 2026-03-19

## Table Stakes

Features users expect. Missing = product feels incomplete.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| **MicroVM isolation via microvm.nix** | Core requirement for sandboxing openclaw from host | Medium | microvm.nix provides KVM-based virtualization with configurable isolation levels |
| **Network access (bridge/tap)** | openclaw must expose service on port 18789 (Gateway) and connect to external messaging APIs | Medium | Requires host networking setup (bridge/tap/macvtap); MicroVM needs static IP or DHCP |
| **Persistent storage** | openclaw stores sessions, channels config, user data that must survive reboots | Medium | Options: virtiofs (9P), host-mounted directories, or block devices |
| **Systemd auto-start** | MicroVM should start automatically on host boot | Low | microvm.nix integrates with systemd; just enable `microvm.vms.<name>.autoStart` |
| **Node.js 22+ runtime** | openclaw requires Node.js >= 22 | Low | Must be available inside MicroVM image |
| **Dependency isolation from host** | SSH keys and sensitive data must NOT be shared with host | Low | Explicit volume mounts only; no IdentityAgent forwarding |

## Differentiators

Features that set product apart. Not expected, but valued.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **Declarative MicroVM definition** | Entire MicroVM config in Nix flake; reproducible, version-controlled | Medium | Use microvm.nix flake to define VM image and host configuration together |
| **Resource limits (CPU/RAM)** | Prevent openclaw from consuming all host resources | Low | microvm.nix supports `microvm.vms.<name>.memory` and CPU pinning |
| **Separate network namespace** | Clean network isolation; MicroVM has its own IP | Medium | Bridge networking gives VM independent network presence |
| **NixOS guest image** | Running NixOS inside MicroVM for declarative guest config too | High | Heavier than Alpine/scratch but matches project philosophy |

## Anti-Features

Features to explicitly NOT build.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| **SSH Agent Forwarding to MicroVM** | Violates isolation principle; host keys would be accessible | MicroVM has its own identity; no SSH key sharing |
| **Host root filesystem mount** | Breaks isolation; MicroVM could access host secrets | Use explicit virtiofs mounts for only needed directories |
| **macOS support** | Project scope is NixOS-only; microvm.nix is NixOS-specific | Keep Darwin configuration separate (already done in project) |
| **Docker-in-MicroVM** | Unnecessary complexity; openclaw can run directly in NixOS guest | Use Nix packages directly in MicroVM image |

## Feature Dependencies

```
MicroVM isolation → Network access (VM needs network to serve)
MicroVM isolation → Persistent storage (VM needs storage location)
Network access → openclaw Gateway (port 18789 must be reachable)
Persistent storage → openclaw sessions/data (data must survive reboot)
Systemd auto-start → MicroVM definition (must exist before auto-starting)
Node.js runtime → openclaw application (runtime dependency)
```

## MVP Recommendation

Prioritize:
1. **MicroVM isolation via microvm.nix** - Foundation for everything else
2. **Systemd auto-start** - Basic operational requirement
3. **Network access (bridge)** - openclaw must be reachable

Defer: **Resource limits** - Can be added after basic functionality works

## Complexity Notes by Category

### Infrastructure (Medium Complexity)
- microvm.nix setup requires understanding of NixOS modules and flake integration
- Network bridge configuration on host needs careful planning
- virtiofs/9P storage setup has subtle configuration options

### openclaw Application (Low-Medium Complexity)
- Standard Node.js application with well-documented requirements
- Gateway port (18789) is the main network requirement
- Configuration stored in `~/.config/openclaw/` or XDG equivalent

### Security/Isolation (Low Complexity)
- microvm.nix provides good defaults for isolation
- Main risk is over-mounting host filesystems
- SSH key isolation is explicit (don't mount, don't forward)

## openclaw Specific Requirements

| Requirement | Details |
|-------------|---------|
| **Runtime** | Node.js >= 22 |
| **Gateway Port** | TCP 18789 (WebSocket control plane) |
| **Storage** | ~100MB-1GB depending on session history |
| **Config Location** | `~/.config/openclaw/` (XDG compliant) |
| **External Connections** | Messaging APIs (WhatsApp, Telegram, Slack, etc.) - outbound HTTPS |
| **Optional** | Tailscale, SSH tunnels for remote access |

## Sources

- [openclaw documentation](https://docs.openclaw.ai/)
- [openclaw GitHub](https://github.com/openclaw/openclaw)
- [microvm.nix search results](https://github.com/stikonas/microvm.nix)
- [NixOS Wiki - Virtualization](https://nixos.wiki/wiki/Virtualization)
