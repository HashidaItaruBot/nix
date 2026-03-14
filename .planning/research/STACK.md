# Stack Research

**Domain:** Nix Flake System Configuration Management (NixOS + Darwin)
**Researched:** 2026-03-14
**Confidence:** HIGH

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| **Nix Flakes** | Built-in (experimental-features) | Declarative, reproducible configuration management | Standard for modern Nix configurations. Provides locked dependencies, hermetic builds, and easy sharing. All major tools now support flakes natively. |
| **nixpkgs** | nixpkgs-unstable or 25.11 | Package repository | Primary source of packages. Use unstable for latest software, 25.11 for stability. Pin to specific commits for reproducibility. |
| **Lix** | stable | Nix implementation (alternative to CppNix) | Modern, community-driven fork with better performance and UX. Recommended by nix-darwin. Set `nix.package = pkgs.lixPackageSets.stable.lix;` to use. |
| **home-manager** | master (9476+ stars) | User environment management | Declarative dotfiles and user packages. Integrates with NixOS and nix-darwin as module. Use `useGlobalPkgs = true` for package consistency. |
| **nix-darwin** | master | macOS system configuration | NixOS-like module system for macOS. Manages system defaults, services, and integrates with home-manager. Essential for cross-platform configs. |
| **sops-nix** | master (2686+ stars) | Secrets management | Age-encrypted secrets in git. Works on NixOS and Darwin. Uses SSH keys for decryption. Atomic secret provisioning during activation. |

### Platform-Specific Technologies

| Technology | Version | Purpose | When to Use |
|------------|---------|---------|-------------|
| **lanzaboote** | v1.0.0 (1565+ stars) | UEFI Secure Boot for NixOS | NixOS systems requiring verified boot. Requires keys generated via `sbctl`. Stores keys in sops-nix for security. |
| **plasma-manager** | master (1093+ stars) | KDE Plasma configuration | NixOS systems using Plasma desktop. Integrates with home-manager. Set `inputs.nixpkgs.follows = "nixpkgs"` and `inputs.home-manager.follows = "home-manager"`. |
| **nix-flatpak** | master (803+ stars) | Flatpak management | Systems requiring Flatpaks not in nixpkgs. Declarative Flatpak installation. Use for apps not easily packaged in Nix. |
| **microvm** | master (2365+ stars) | Lightweight VMs | NixOS hosts needing VMs. Uses cloud-hypervisor or QEMU. Excellent for testing and isolated services. |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| **alejandra** | Nix formatter (1309+ stars) | Uncompromising formatter. Use via `nix fmt` or pre-commit hooks. Alternative: nixpkgs-fmt (older, less strict). |
| **statix** | Nix linter (846+ stars) | Detects anti-patterns and suggests fixes. Run via `statix check .` or integrate with editor. |
| **deadnix** | Dead code scanner (732+ stars) | Finds unused bindings. Combine with statix for comprehensive linting. |
| **nixd** | Nix LSP | Modern language server with excellent flake support. Better completion than nil for flake-based configs. |
| **nil** | Nix LSP | Alternative language server. Use nixd or nil, not both. |
| **nh** | Nix Helper | `nh os switch` replacement for `nixos-rebuild`. Better UX, auto-detects flake. Use `nh darwin switch` for macOS. |
| **nom** (nix-output-monitor) | Build visualization (1426+ stars) | Pipe nix builds through `nom` for progress bars and timing. Use with `nix build |& nom`. |
| **comma** | Run without installing (1561+ stars) | `comma <package> <command>` runs any command from nixpkgs. Uses nix-index for lookups. |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| **flake-utils** | master (1563+ stars) | Flake utility functions | When you need `eachSystem` patterns. Alternative: use `nixpkgs.lib.systems.flakeExposed` directly to avoid extra input. |
| **nixvim** | master (2701+ stars) | Neovim configuration | Declarative Neovim setup. Extensive option coverage. Use instead of manual init.lua for Nix integration. |
| **disko** | master (2917+ stars) | Disk partitioning | New installations. Declarative disk layouts. Generates NixOS config and format scripts. |
| **impermanence** | master (1714+ stars) | Ephemeral root storage | Systems requiring `/tmp` style persistence. Combine with disko for Btrfs subvolume setups. |
| **nixos-anywhere** | master (2944+ stars) | Remote installation | Install NixOS on any machine via SSH. Uses kexec and disko. Essential for server provisioning. |
| **nix-index-database** | master (529+ stars) | Weekly package index | Faster `nix-locate` and comma lookups. Add as flake input for daily updates. |
| **treefmt-nix** | master (560+ stars) | Formatter aggregator | Run all formatters (alejandra, statix, prettier, etc.) with single `treefmt` command. |

## Installation

No npm-style installation. Add to `flake.nix` inputs:

```nix
{
  inputs = {
    # Core
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # System Management
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Secrets
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # NixOS-specific
    lanzaboote.url = "github:nix-community/lanzaboote/v1.0.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    # Desktop (optional)
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # Virtualization (optional)
    microvm.url = "github:microvm-nix/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| Lix | CppNix (default Nix) | Enterprise environments requiring official support. Lix is more community-driven. |
| alejandra | nixpkgs-fmt | If you need gentler formatting. alejandra is stricter and more opinionated. |
| nixd | nil | If nil works better with your specific editor setup. nixd has better flake support. |
| nh | nixos-rebuild / darwin-rebuild | If you prefer official tools. nh provides better UX and auto-detection. |
| disko | manual partitioning | Simple single-disk setups. disko adds complexity for basic cases. |
| sops-nix | agenix | If you prefer age-only encryption. sops-nix supports both age and GPG, more flexible. |
| sops-nix | git-crypt | If you want transparent encryption. sops-nix gives per-secret control. |
| home-manager module | standalone home-manager | Non-NixOS/non-Darwin systems. Module integration is preferred for Nix-managed systems. |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| **Channels** (nix-channel) | Impure, not version-controlled, breaks reproducibility | Flakes with locked inputs |
| **configuration.nix without flakes** | No dependency locking, harder to share | Flake-based configuration |
| **NIX_PATH overrides** | Impure, breaks reproducibility | Flake inputs with `follows` |
| **Impure package overrides** | Breaks caching, causes rebuilds | Overlays or package overlays in flake |
| **nixpkgs-fmt** | No longer actively maintained, less strict | alejandra |
| **Builtins for secrets** | Secrets in nix store (world-readable) | sops-nix with age encryption |
| **Environment variables for secrets** | Visible in process list, stored in history | sops-nix with runtime decryption |
| **Manual system.stateVersion bumps** | Unnecessary breakage | Keep stable, let modules handle migration |
| **Multiple nix implementations** | Conflicts, unexpected behavior | Pick one: Lix or CppNix |

## Stack Patterns by Variant

**For NixOS Desktop (Plasma/KDE):**
- Use: nixvim, plasma-manager, nix-flatpak, lanzaboote
- Because: Full declarative desktop with secure boot, Neovim config, and Flatpaks
- Pattern: home-manager module integration with `useGlobalPkgs = true`

**For NixOS Server:**
- Use: disko, impermanence, nixos-anywhere, sops-nix
- Because: Declarative disk layouts, ephemeral root for security, remote provisioning
- Pattern: Minimal packages, headless services, secrets via sops

**For Darwin/macOS:**
- Use: nix-darwin, home-manager, sops-nix
- Because: NixOS-like module system for macOS system settings
- Pattern: Darwin modules for system, home-manager for user space

**For Cross-Platform (NixOS + Darwin):**
- Use: Shared directory structure, platform-specific imports
- Because: Single source of truth with platform overrides
- Pattern: `shared/` for common config, `nixos/` and `darwin/` for platform-specific

## Version Compatibility

| Package | Compatible With | Notes |
|---------|-----------------|-------|
| home-manager | nixpkgs-unstable, 25.11 | Follow nixpkgs for package consistency |
| nix-darwin | nixpkgs-unstable, 25.11-darwin | Follow nixpkgs to avoid eval cache issues |
| lanzaboote | nixpkgs-unstable | Pin to v1.0.0 tag for stability |
| sops-nix | nixpkgs-unstable, 25.11 | Follow nixpkgs for age binary compatibility |
| plasma-manager | home-manager@master | Must follow home-manager input |
| microvm | nixpkgs-unstable | Follow nixpkgs for kernel compatibility |

## Architecture Pattern

```
flake.nix                  # Main entry point, defines inputs and outputs
  nixos/                   # NixOS-specific configuration
    default.nix           # Main NixOS module, imports shared/
    home/                  # NixOS home-manager modules
    packages/              # NixOS-specific packages
    hardware-configuration.nix
  darwin/                  # Darwin-specific configuration
    default.nix           # Main Darwin module, imports shared/
    home/                  # Darwin home-manager modules
    packages/              # Darwin-specific packages
  shared/                   # Cross-platform configuration
    home/                   # Shared home-manager modules
    system/                 # Shared system modules (sops, packages)
    secrets/                # Encrypted secrets (via sops)
```

**Key Pattern:**
- `inputs.xxx.follows = "nixpkgs"` ensures single nixpkgs version
- `specialArgs = { inherit inputs self; }` passes inputs to modules
- Home-manager module integration: `home-manager.useGlobalPkgs = true`
- Sops-nix: SSH key paths differ between NixOS (`/root/.ssh/id_ed25519`) and Darwin (`/var/root/.ssh/id_ed25519`)

## Sources

- **home-manager** - https://github.com/nix-community/home-manager (9476 stars, active) - HIGH confidence
- **nix-darwin** - https://github.com/nix-darwin/nix-darwin (active, official docs) - HIGH confidence
- **sops-nix** - https://github.com/Mic92/sops-nix (2686 stars, active) - HIGH confidence
- **lanzaboote** - https://github.com/nix-community/lanzaboote (1565 stars, active) - HIGH confidence
- **plasma-manager** - https://github.com/nix-community/plasma-manager (1093 stars, active) - HIGH confidence
- **nixvim** - https://github.com/nix-community/nixvim (2701 stars, active) - HIGH confidence
- **microvm** - https://github.com/microvm-nix/microvm.nix (2365 stars, active) - HIGH confidence
- **disko** - https://github.com/nix-community/disko (2917 stars, active) - HIGH confidence
- **impermanence** - https://github.com/nix-community/impermanence (1714 stars, active) - HIGH confidence
- **nixos-anywhere** - https://github.com/nix-community/nixos-anywhere (2944 stars, active) - HIGH confidence
- **alejandra** - https://github.com/kamadorueda/alejandra (1309 stars) - HIGH confidence
- **statix** - https://github.com/oppiliappan/statix (846 stars, active) - HIGH confidence
- **nix-output-monitor** - https://github.com/maralorn/nix-output-monitor (1426 stars, active) - HIGH confidence
- **comma** - https://github.com/nix-community/comma (1561 stars) - HIGH confidence
- **flake-utils** - https://github.com/numtide/flake-utils (1563 stars) - HIGH confidence
- **Lix** - https://github.com/lix-project/lix (542 stars, active) - HIGH confidence
- **nix-flatpak** - https://github.com/gmodena/nix-flatpak (803 stars) - MEDIUM confidence (smaller community)
- **treefmt-nix** - https://github.com/numtide/treefmt-nix (560 stars, active) - HIGH confidence

---
*Stack research for: Nix Flake System Configuration Management*
*Researched: 2026-03-14*