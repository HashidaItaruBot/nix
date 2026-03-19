# Project Research Summary

**Project:** NixOS MicroVM for openclaw
**Domain:** MicroVM-based service isolation on NixOS
**Researched:** 2026-03-19
**Confidence:** HIGH

## Executive Summary

This project creates a declarative MicroVM on NixOS to host the openclaw service with strong isolation from the host system. The recommended approach uses microvm.nix with cloud-hypervisor, TAP+bridge networking for LAN presence, virtiofs shares for read-only Nix store access, and block device volumes for persistent data storage.

The research strongly favors keeping the MicroVM fully declarative within the host's flake configuration, enabling systemd autostart, and avoiding SSH key sharing or agent forwarding to maintain isolation boundaries. The openclaw Gateway service runs inside the MicroVM on port 18789, with data persisted to a dedicated volume that survives reboots.

Key risks center on storage configuration: writable overlays for `/nix/store` do not work on 9p/virtiofs shares and require block device volumes; the Nix database will forget packages built inside the VM after reboot; and ZFS datasets need specific xattr/ACL options for virtiofs compatibility. These are mitigated by following the documented patterns: use volumes for writable storage, build packages on the host, and configure ZFS properly before sharing.

## Key Findings

### Recommended Stack

**Core technologies:**
- **microvm.nix** (github:microvm-nix/microvm.nix, rev: 25ebda3): MicroVM management framework providing NixOS modules and systemd integration
- **cloud-hypervisor**: Lightweight hypervisor with virtiofs support, better performance than QEMU for MicroVM workloads
- **virtiofsd**: High-performance filesystem sharing for read-only `/nix/store` access from host
- **systemd-networkd**: Host network management for TAP bridge interfaces
- **nix-openclaw** (github:openclaw/nix-openclaw): Declarative home-manager module for openclaw Gateway configuration

**Version requirements:**
- Node.js >= 22 (LTS) inside MicroVM for openclaw runtime
- pnpm as package manager (preferred by OpenClaw)

### Expected Features

**Must have (table stakes):**
- MicroVM isolation via microvm.nix — core requirement for sandboxing openclaw from host
- Network access (bridge/TAP) — openclaw must expose port 18789 and connect to external APIs
- Persistent storage — sessions and config must survive reboots via dedicated volume
- Systemd auto-start — MicroVM should start automatically on host boot
- Dependency isolation from host — no SSH key sharing, explicit volume mounts only

**Should have (competitive):**
- Declarative MicroVM definition — entire config in Nix flake for reproducibility
- Resource limits (CPU/RAM) — prevent openclaw from consuming all host resources
- Separate network namespace — clean isolation with independent IP address
- NixOS guest image — matches project philosophy, though heavier than Alpine

**Defer (v2+):**
- Resource limits can be added after basic functionality works
- macOS support is out of scope (microvm.nix is NixOS-specific)
- Docker-in-MicroVM is unnecessary complexity

### Architecture Approach

The architecture follows a host-guest separation where the NixOS host provides infrastructure (TAP interfaces, virtiofsd shares, systemd lifecycle) and the MicroVM runs a full NixOS guest with the openclaw service. Boot sequence is managed by systemd: `microvms.target` triggers TAP interface creation, then virtiofsd, then the VM itself. The MicroVM mounts the host's `/nix/store` read-only via virtiofs and uses a block device volume for writable persistent data.

**Major components:**
1. **Host: microvm.nixosModules.host** — Provides systemd services, `/var/lib/microvms`, TAP and virtiofsd management
2. **Host: flake.nix** — Declares MicroVM in `microvm.vms`, configures autostart and bridge networking
3. **MicroVM: nixosConfiguration** — Full NixOS config with microvm.nixosModules.microvm, systemd, and openclaw service
4. **MicroVM: virtiofs share** — Read-only `/nix/.ro-store` from host for Nix packages
5. **MicroVM: volume (ext4)** — Persistent writable storage for openclaw data
6. **MicroVM: TAP interface** — Bridged network connectivity with static IP on LAN

### Critical Pitfalls

1. **Writable overlay on 9p/virtiofs fails** — Linux overlayfs rejects these filesystems; use a block device volume instead for `writableStoreOverlay`

2. **Nix database forgets packages after reboot** — The VM's Nix DB only tracks packages from VM creation; build packages on the host instead of inside the VM

3. **TAP interface permission denied at boot** — systemd service ordering matters; use `microvm.nixosModules.host` which handles dependencies, and add `multi_queue` flag for multi-core VMs

4. **virtiofs on ZFS without xattr/ACL options** — ZFS defaults disable required features; run `zfs set xattr=sa,acltype=posixacl <dataset>` before sharing

5. **Insufficient memory allocation** — Default 512MB causes OOM for services; set `microvm.mem = 2048` for openclaw with Nix operations

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Basic MicroVM Infrastructure
**Rationale:** Foundation for everything else; microvm.nix must be integrated before any other features work
**Delivers:** Working MicroVM that boots and can be started/stopped
**Uses:** microvm.nix host module, cloud-hypervisor, basic NixOS guest configuration
**Addresses:** Pitfall 5 (memory), Pitfall 7 (hypervisor selection), Pitfall 10 (declarative build time)
**Research flag:** Standard pattern — microvm.nix documentation is comprehensive

### Phase 2: Storage & Persistence
**Rationale:** MicroVM must have persistent data storage before openclaw can be useful; storage configuration has the most critical pitfalls
**Delivers:** Read-only Nix store share + writable volume for openclaw data
**Uses:** virtiofs for `/nix/.ro-store`, ext4 volume for `/var/lib/openclaw`
**Addresses:** Pitfall 1 (overlay on wrong filesystem), Pitfall 2 (Nix DB), Pitfall 4 (ZFS virtiofs)
**Research flag:** Standard pattern — well-documented in microvm.nix handbook

### Phase 3: Networking
**Rationale:** openclaw Gateway must be reachable; networking depends on MicroVM existing (Phase 1)
**Delivers:** TAP bridge interface, static IP on LAN, port 18789 reachable
**Uses:** systemd-networkd for bridge, TAP interfaces with vhost acceleration
**Addresses:** Pitfall 3 (TAP permissions), Pitfall 6 (NAT forwarding)
**Research flag:** Standard pattern — microvm.nix provides working examples

### Phase 4: openclaw Integration
**Rationale:** Application layer goes on top of stable infrastructure; depends on networking (Phase 3) for external API access
**Delivers:** Running openclaw Gateway with home-manager configuration, secrets management
**Uses:** nix-openclaw home-manager module, Node.js 22+ runtime
**Addresses:** All table-stakes features from FEATURES.md
**Research flag:** May need research — nix-openclaw integration details and secrets handling

### Phase 5: Operational Hardening
**Rationale:** Polish and production readiness after core functionality works
**Delivers:** Autostart on boot, resource limits, monitoring hooks
**Uses:** `microvm.autostart`, memory ballooning, machineId configuration
**Addresses:** Pitfall 8 (logging), optional optimizations
**Research flag:** Skip research — standard systemd and microvm.nix patterns

### Phase Ordering Rationale

- Phases 1-3 follow infrastructure layering: compute → storage → network (standard virtualization stack)
- openclaw (Phase 4) cannot function without network and storage, so it comes last
- Hardening (Phase 5) is deferred because it optimizes a working system, not a broken one
- Storage pitfalls are the most severe, so Phase 2 gets careful attention before application integration

### Research Flags

**Phases likely needing deeper research during planning:**
- **Phase 4:** nix-openclaw home-manager module integration inside MicroVM; secrets file placement and permission handling

**Phases with standard patterns (skip research-phase):**
- **Phase 1:** microvm.nix host setup is well-documented
- **Phase 2:** virtiofs shares and volume configuration have cookbook examples
- **Phase 3:** TAP bridge networking follows microvm.nix handbook patterns
- **Phase 5:** systemd autostart and resource limits are straightforward

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Based on official microvm.nix handbook and nix-openclaw documentation; versions are current |
| Features | HIGH | openclaw requirements are explicit (Node.js 22+, port 18789); microvm.nix capabilities well-documented |
| Architecture | HIGH | microvm.nix handbook provides detailed component diagrams and systemd flow |
| Pitfalls | HIGH | Sourced directly from microvm.nix official FAQ and troubleshooting sections |

**Overall confidence:** HIGH

### Gaps to Address

- **nix-openclaw inside MicroVM:** How home-manager targets the MicroVM system needs verification; may require a separate `nixosConfiguration.openclaw` entry with home-manager as a module
- **Secrets management:** Gateway token and channel tokens need secure placement in the persistent volume; sops-nix integration with virtiofs has known caveats (Pitfall 9)
- **Static IP assignment:** MicroVM network configuration must match host's LAN subnet; requires user to adjust example configs to their network

## Sources

### Primary (HIGH confidence)
- [microvm.nix Handbook](https://microvm-nix.github.io/microvm.nix/) — Official documentation for all MicroVM patterns, pitfalls, and systemd integration
- [openclaw/openclaw](https://github.com/openclaw/openclaw) — Official openclaw requirements and runtime specs
- [nix-openclaw](https://github.com/openclaw/nix-openclaw) — Declarative OpenClaw Nix module

### Secondary (MEDIUM confidence)
- [microvm.nix GitHub](https://github.com/microvm-nix/microvm.nix) — Source code and example configurations
- [NixOS Wiki - Virtualization](https://nixos.wiki/wiki/Virtualization) — General virtualization context

---
*Research completed: 2026-03-19*
*Ready for roadmap: yes*
