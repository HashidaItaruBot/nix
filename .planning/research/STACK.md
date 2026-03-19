# Technology Stack

**Project:** MicroVM for openclaw on NixOS
**Researched:** 2026-03-19

## Recommended Stack

### Core Virtualization

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| **microvm.nix** | github:microvm-nix/microvm.nix (rev: 25ebda3, 2025-12) | MicroVM management framework | Already in flake, provides NixOS modules, systemd integration, multiple hypervisor support |
| **cloud-hypervisor** | Latest (via microvm.nix) | Hypervisor for running MicroVMs | Best balance of performance, features, and NixOS integration; supports 9p/virtiofs shares, control socket for graceful shutdown |
| **virtiofsd** | Included in nixpkgs | Shared filesystem service | Required for virtiofs shares; better performance than 9p; managed by systemd via microvm.nix |

### NixOS Modules

| Module | Source | Purpose | Why |
|--------|--------|---------|-----|
| **microvm.nixosModules.host** | microvm.nix | Host system preparation | Creates `/var/lib/microvms`, systemd services for TAP interfaces, virtiofsd, and MicroVM lifecycle |
| **microvm.nixosModules.microvm** | microvm.nix | MicroVM configuration | Defines MicroVM-specific NixOS options (interfaces, volumes, shares, hypervisor selection) |
| **nix-openclaw.homeManagerModules** | github:openclaw/nix-openclaw | OpenClaw home-manager module | Already in flake; provides `programs.openclaw` for declarative OpenClaw Gateway configuration |

### Networking

| Component | Purpose | Why |
|-----------|---------|-----|
| **systemd-networkd** | Host network management | Recommended by microvm.nix docs; creates bridge (`br0`) for TAP interfaces |
| **TAP interfaces** | MicroVM networking | Type-2 hypervisor networking; places MicroVM directly on LAN; `vm-*` naming convention |
| **Port forwarding (qemu)** | Alternative to TAP | Only if using qemu with user networking; simpler but worse performance |

### Storage

| Component | Purpose | Why |
|-----------|---------|-----|
| **Host `/nix/store` share** | Read-only store for MicroVM | Drastically reduces image size; MicroVMs share host's Nix store via virtiofs |
| **Volume (ext4 image)** | Persistent writable storage | For OpenClaw data (sessions, config, documents); block device with exclusive access |
| **Writable overlay (optional)** | Writable `/nix/store` layer | For building packages inside MicroVM; requires volume (9p/virtiofs don't work for overlay) |

### OpenClaw Runtime

| Component | Version | Purpose | Why |
|-----------|---------|---------|-----|
| **Node.js** | >=22 ( LTS ) | OpenClaw runtime | Official requirement from openclaw/openclaw |
| **pnpm** | Latest | Package manager | Preferred by OpenClaw for builds; faster, disk-efficient |
| **nix-openclaw** | github:openclaw/nix-openclaw (rev: 8cdfd30, 2025-12) | Declarative OpenClaw packaging | Already in flake; provides gateway + tools; manages launchd/systemd service |

## NixOS Host Configuration Needed

Add to `nixos/default.nix` or create `nixos/microvm.nix`:

```nix
{ self, microvm, ... }: {
  imports = [
    microvm.nixosModules.host
  ];

  # Enable systemd-networkd for bridge networking
  networking.useNetworkd = true;
  systemd.network.enable = true;

  # Bridge configuration for TAP interfaces
  systemd.network.netdevs."br0" = {
    netdevConfig = {
      Name = "br0";
      Kind = "bridge";
    };
  };

  systemd.network.networks."10-lan" = {
    matchConfig.Name = ["eno1" "vm-*"];
    networkConfig.Bridge = "br0";
  };

  systemd.network.networks."10-lan-bridge" = {
    matchConfig.Name = "br0";
    networkConfig = {
      Address = ["192.168.1.2/24"];  # Adjust to your LAN
      Gateway = "192.168.1.1";
      DNS = ["192.168.1.1"];
      IPv6AcceptRA = true;
    };
    linkConfig.RequiredForOnline = "routable";
  };

  # Declarative MicroVMs to autostart
  microvm.autostart = ["openclaw"];

  # Define MicroVMs
  microvm.vms.openclaw = {
    # Option 1: Fully declarative (recommended)
    config = { pkgs, ... }: {
      microvm.hypervisor = "cloud-hypervisor";
      microvm.vcpu = 2;
      microvm.mem = 2048;

      # Share host's /nix/store
      microvm.shares = [{
        proto = "virtiofs";
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }];

      # Persistent volume for OpenClaw data
      microvm.volumes = [{
        image = "openclaw-data.img";
        mountPoint = "/var/lib/openclaw";
        size = 4096;  # 4GB
      }];

      # TAP network interface
      microvm.interfaces = [{
        type = "tap";
        id = "vm-openclaw";
        mac = "02:00:00:00:00:01";
      }];

      # MicroVM internal network config
      systemd.network.enable = true;
      systemd.network.networks."20-lan" = {
        matchConfig.Type = "ether";
        networkConfig = {
          Address = ["192.168.1.3/24"];  # Static IP for OpenClaw
          Gateway = "192.168.1.1";
          DNS = ["192.168.1.1"];
          DHCP = "no";
        };
      };

      # Enable OpenClaw via home-manager inside MicroVM
      # (requires home-manager module in MicroVM)
    };
  };
}
```

## OpenClaw Configuration (inside MicroVM)

Via home-manager module from nix-openclaw:

```nix
{ pkgs, lib, ... }: {
  home-manager.users.zhaochanglong = { pkgs, ... }: {
    programs.openclaw = {
      enable = true;
      config = {
        gateway = {
          mode = "local";
          host = "0.0.0.0";  # Expose externally
          port = 18789;
          auth.tokenFile = "/var/lib/openclaw/secrets/gateway-token";
        };

        channels.telegram = {
          tokenFile = "/var/lib/openclaw/secrets/telegram-bot-token";
          allowFrom = [ 12345678 ];  # Your Telegram user ID
        };

        # Persist data directory
        dataDir = "/var/lib/openclaw/data";
      };

      plugins = [
        { source = "github:openclaw/nix-steipete-tools?dir=tools/summarize"; }
      ];
    };
  };
}
```

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Hypervisor | cloud-hypervisor | qemu | QEMU heavier, more overhead; cloud-hypervisor optimized for MicroVMs |
| Hypervisor | cloud-hypervisor | firecracker | Firecracker doesn't support 9p/virtiofs shares |
| Hypervisor | cloud-hypervisor | vfkit | vfkit macOS-only; we're on NixOS |
| Network | TAP + bridge | user networking (qemu) | User networking has poor performance (~1.5 Gbps vs ~10 Gbps with vhost) |
| Share | virtiofs | 9p | virtiofs better performance; 9p simpler but slower |
| Storage | Volume for data | Share for data | Volumes are block devices; better for databases/file integrity |
| OpenClaw | nix-openclaw flake | Manual install | nix-openclaw is declarative, reproducible, already in flake |

## Installation

### On NixOS Host

```bash
# Ensure microvm.nix is in flake inputs (already present)
# Rebuild host with microvm host module
sudo nixos-rebuild switch --flake .#nixos

# Initialize MicroVM directory structure
sudo systemctl start install-microvm-openclaw.service

# Enable autostart (MicroVM starts on boot)
# Set microvm.autostart = ["openclaw"] in host config
```

### Inside MicroVM (via home-manager)

```bash
# After MicroVM is running, apply home-manager config
home-manager switch --flake .#zhaochanglong@openclaw

# Or include home-manager in MicroVM's NixOS config
```

## Integration Points

### What to Add (new for MicroVM milestone)

1. **nixos/microvm.nix** — New file for MicroVM host configuration
2. **microvm.autostart** — Add "openclaw" to autostart list
3. **systemd.network** — Bridge networking for TAP interfaces
4. **microvm.vms.openclaw** — MicroVM definition with cloud-hypervisor
5. **home-manager integration** — OpenClaw config inside MicroVM

### What Already Exists (do NOT change)

1. **microvm input** — Already in flake.nix (rev: 25ebda3)
2. **nix-openclaw input** — Already in flake.nix (rev: 8cdfd30)
3. **nixpkgs** — Already using nixpkgs-unstable
4. **home-manager** — Already configured for user management

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| cloud-hypervisor over qemu | Lighter weight, better MicroVM integration, supports virtiofs | Lower resource usage, faster boot |
| TAP + bridge over user networking | Better performance, MicroVM on LAN with static IP | Reachable from other devices |
| virtiofs over 9p | ~3x better filesystem performance | Faster OpenClaw startup/response |
| Volume for persistent data | Block device semantics, safe for concurrent access | Data integrity for sessions/config |
| nix-openclaw home-manager module | Declarative, already in flake, maintained by OpenClaw team | Reproducible, easy updates |
| Host shares `/nix/store` | MicroVM image stays small (~200MB vs ~5GB) | Faster builds, less disk usage |

## Sources

- [microvm.nix Handbook](https://microvm-nix.github.io/microvm.nix/) — Official documentation
- [microvm.nix GitHub](https://github.com/microvm-nix/microvm.nix) — Source and examples
- [openclaw/openclaw](https://github.com/openclaw/openclaw) — OpenClaw documentation
- [nix-openclaw](https://github.com/openclaw/nix-openclaw) — Declarative OpenClaw Nix module
