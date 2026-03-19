# Architecture Patterns

**Domain:** NixOS MicroVM for openclaw service isolation
**Researched:** 2026-03-19

## Recommended Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        NixOS Host                               │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              microvm.nixosModules.host                   │    │
│  │  ┌─────────────────┐  ┌─────────────────────────────┐   │    │
│  │  │ /var/lib/microvms│  │ systemd services:          │   │    │
│  │  │ ┌─────────────┐ │  │ - microvm-tap-interfaces@   │   │    │
│  │  │ │ openclaw/   │ │  │ - microvm-virtiofsd@        │   │    │
│  │  │ │  - config   │ │  │ - microvm@                  │   │    │
│  │  │ │  - volumes  │ │  │ - install-microvm-*         │   │    │
│  │  │ └─────────────┘ │  │ - microvms.target           │   │    │
│  │  └─────────────────┘  └─────────────────────────────┘   │    │
│  │                              │                            │    │
│  │         ┌────────────────────┼────────────────────┐      │    │
│  │         │                    │                    │      │    │
│  │    ┌────▼────┐         ┌─────▼─────┐     ┌───────▼────┐ │    │
│  │    │  TAP    │         │ virtiofsd │     │  MicroVM   │ │    │
│  │    │  iface  │         │  shares   │     │  @openclaw │ │    │
│  │    └─────────┘         └───────────┘     └────────────┘ │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              MicroVM: openclaw (isolated)                │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │   │
│  │  │ /nix/.ro-   │  │  persistent │  │   openclaw      │  │   │
│  │  │ store (9p/  │  │  volume     │  │   service       │  │   │
│  │  │ virtiofs)   │  │  (ext4)     │  │   (systemd)     │  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────────┘  │   │
│  │  ┌─────────────┐  ┌─────────────┐                       │   │
│  │  │ TAP network │  │  read-only  │                       │   │
│  │  │ interface   │  │  rootfs     │                       │   │
│  │  └─────────────┘  └─────────────┘                       │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Component Boundaries

| Component | Responsibility | Communicates With |
|-----------|---------------|-------------------|
| **Host: microvm host module** | Provides systemd infrastructure, TAP setup, virtiofsd | systemd, kernel (TUN/TAP), MicroVM |
| **Host: flake.nix** | Declares MicroVM in `microvm.vms`, autostart configuration | microvm.nixosModules.host |
| **MicroVM: nixosConfigurations** | Full NixOS config for openclaw VM | microvm.nixosModules.microvm |
| **MicroVM: virtiofs/9p share** | Read-only `/nix/.ro-store` from host | Host `/nix/store` |
| **MicroVM: volume** | Persistent writable storage (ext4 block device) | MicroVM filesystem |
| **MicroVM: TAP interface** | Network connectivity (bridged to host) | Host network, external clients |
| **MicroVM: openclaw service** | The actual application service | Network clients, persistent volume |

## Data Flow

### Boot Sequence (Auto-start)

```
1. NixOS host boots
2. systemd starts microvms.target
3. microvm-tap-interfaces@openclaw.service creates TAP device
4. microvm-virtiofsd@openclaw.service starts virtiofsd for /nix/store share
5. install-microvm-openclaw.service prepares /var/lib/microvms/openclaw/
6. microvm@openclaw.service launches the VM
7. MicroVM boots, mounts /nix/.ro-store (virtiofs) + persistent volume
8. openclaw systemd service starts inside MicroVM
9. openclaw binds to network port via TAP interface
```

### Runtime Data Flow

```
External Client
      │
      ▼
Host Network (bridge/TAP)
      │
      ▼
MicroVM TAP Interface (virtio-net)
      │
      ▼
openclaw service (inside MicroVM)
      │
      ├──▶ Read: /nix/.ro-store (virtiofs → host /nix/store)
      │
      └──▶ Read/Write: persistent volume (ext4 block device)
```

### Build/Deploy Flow

```
nixos-rebuild switch
      │
      ├──▶ Rebuild host configuration
      │      │
      │      └──▶ microvm.vms.openclaw evaluated
      │
      └──▶ Build MicroVM closure
             │
             ├──▶ Read-only rootfs (squashfs/erofs)
             │
             └──▶ /nix/.ro-store share configured
```

## Patterns to Follow

### Pattern 1: Declarative MicroVM with Host

**What:** Define MicroVMs directly in host configuration using `microvm.vms`

**When:** You want MicroVMs to be managed declaratively alongside host

**Example:**
```nix
# In nixos/default.nix or a dedicated microvm.nix
{
  microvm.vms.openclaw = {
    config = {
      microvm.shares = [{
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        tag = "ro-store";
        proto = "virtiofs";
      }];

      microvm.volumes = [{
        image = "openclaw-data.img";
        mountPoint = "/var/lib/openclaw";
        size = 4096;  # MB
      }];

      microvm.interfaces = [{
        type = "tap";
        id = "openclaw-tap";
        mac = "02:00:00:00:00:01";
      }];

      # openclaw service configuration
      systemd.services.openclaw = {
        enable = true;
        wantedBy = [ "multi-user.target" ];
        # ...
      };
    };
  };
}
```

### Pattern 2: TAP Networking with vhost Acceleration

**What:** Use TAP interfaces with kernel vhost-net acceleration

**When:** High-throughput network workloads (many connections or high bandwidth)

**Example:**
```nix
microvm.interfaces = [{
  type = "tap";
  id = "openclaw-tap";
  mac = "02:00:00:00:00:01";
  tap.vhost = true;  # ~10 Gbps vs ~1.5 Gbps without
}];
```

### Pattern 3: Writable Overlay for /nix/store

**What:** Add writable layer on top of read-only /nix/store

**When:** MicroVM needs to install packages at runtime (not recommended for isolation)

**Example:**
```nix
{
  microvm.writableStoreOverlay = "/nix/.rw-store";

  microvm.volumes = [{
    image = "nix-overlay.img";
    mountPoint = config.microvm.writableStoreOverlay;
    size = 2048;
  }];
}
```

### Pattern 4: Isolated MicroVM (No SSH Key Sharing)

**What:** MicroVM runs without access to host SSH agent or keys

**When:** Security isolation is required (this project's requirement)

**Implementation:**
- Do NOT configure `IdentityAgent` in MicroVM SSH config
- Do NOT forward SSH agent to MicroVM
- MicroVM has its own (or no) SSH configuration
- Network isolation via TAP (not user networking which has less control)

## Anti-Patterns to Avoid

### Anti-Pattern 1: Running MicroVM as Root

**What:** Starting MicroVM processes as root user

**Why bad:** Defeats isolation purpose, security risk if VM escapes

**Instead:** Use microvm.nix host module which runs MicroVMs as unprivileged user

### Anti-Pattern 2: Using User Networking for Services

**What:** Relying on QEMU user-mode networking (`type = "user"`)

**Why bad:** No control over which ports are exposed, NAT complications

**Instead:** Use TAP networking with explicit port exposure via firewall rules

### Anti-Pattern 3: Sharing Host SSH Keys with MicroVM

**What:** Mounting host ~/.ssh or forwarding SSH agent to MicroVM

**Why bad:** Breaks isolation goal, MicroVM compromise = host keys compromised

**Instead:** MicroVM should have no SSH keys, or generate its own independent keys

### Anti-Pattern 4: Storing State in Rootfs

**What:** Writing persistent data to the MicroVM root filesystem

**Why bad:** Rootfs is read-only squashfs/erofs; data lost on rebuild

**Instead:** Use `microvm.volumes` for persistent block device storage

### Anti-Pattern 5: ZFS Shares Without Proper Options

**What:** Sharing ZFS datasets via virtiofs without xattr/acl configuration

**Why bad:** virtiofs requires extended attributes and POSIX ACLs

**Instead:** Set ZFS dataset options: `zfs set xattr=sa,acltype=posixacl <dataset>`

## Scalability Considerations

| Concern | At 1 MicroVM | At 5 MicroVMs | At 20+ MicroVMs |
|---------|--------------|---------------|-----------------|
| **Memory** | 512MB-2GB per VM | Plan host RAM carefully | Consider memory overcommit with ballooning |
| **Storage** | Single volume file | Organize under /var/lib/microvms/<name>/ | Consider LVM/ZFS for volume management |
| **Network** | Single TAP interface | Multiple TAPs, consider bridge | VLAN segmentation, dedicated NIC |
| **CPU** | 1-2 vCPUs | Pin vCPUs to physical cores | NUMA awareness, CPU isolation |
| **Management** | Manual config | Use `microvm` CLI tool | Consider orchestration layer |

## Integration with Existing Project Structure

### Current Architecture (Pre-MicroVM)

```
flake.nix
├── nixosConfigurations.nixos
│   └── modules = [
│       ./nixos                    # NixOS system config
│       ./shared/system            # Shared system config
│       ./nixos/home               # home-manager for user
│       ./nixos/sshd.nix           # SSH server (agent forwarding)
│       └── ...
│   ]
```

### New Architecture (With MicroVM)

```
flake.nix
├── inputs
│   └── microvm.url = "github:microvm-nix/microvm.nix"
│
├── nixosConfigurations.nixos (HOST)
│   └── modules = [
│       inputs.microvm.nixosModules.host    # NEW: host module
│       ./nixos
│       ./shared/system
│       ...
│       # NEW: MicroVM declaration
│       {
│         microvm.autostart = [ "openclaw" ];
│         microvm.vms.openclaw = { ... };
│       }
│   ]
│
└── nixosConfigurations.openclaw (MICROVM - NEW)
    └── modules = [
        inputs.microvm.nixosModules.microvm  # NEW: microvm module
        {
          networking.hostName = "openclaw";
          microvm.hypervisor = "qemu";
          # ... openclaw service config
        }
    ]
```

### Files to Create

| File | Purpose |
|------|---------|
| `nixos/microvm.nix` | Host-side MicroVM configuration (autostart, vms declaration) |
| `nixos/microvms/openclaw.nix` | openclaw MicroVM NixOS configuration |
| `nixos/microvms/default.nix` | Re-export for microvms directory |

### Files to Modify

| File | Change |
|------|--------|
| `flake.nix` | Add microvm input, add openclaw nixosConfiguration |
| `nixos/default.nix` | Import microvm.nix module |

## Sources

- [microvm.nix Handbook - Preparing Host](https://github.com/microvm-nix/microvm.nix/blob/master/doc/src/host.md)
- [microvm.nix Handbook - Declaring MicroVMs](https://github.com/microvm-nix/microvm.nix/blob/master/doc/src/declaring.md)
- [microvm.nix Handbook - Shares](https://github.com/microvm-nix/microvm.nix/blob/master/doc/src/shares.md)
- [microvm.nix Handbook - Network Interfaces](https://github.com/microvm-nix/microvm.nix/blob/master/doc/src/interfaces.md)
- [microvm.nix Handbook - systemd Services](https://github.com/microvm-nix/microvm.nix/blob/master/doc/src/host-systemd.md)
- [microvm.nix Handbook - Declarative MicroVMs](https://github.com/microvm-nix/microvm.nix/blob/master/doc/src/declarative.md)
- [microvm.nix README](https://github.com/microvm-nix/microvm.nix/blob/master/README.md)
