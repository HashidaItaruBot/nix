# Nix Configuration

A unified Nix Flake configuration for managing NixOS and Darwin (macOS) systems with modular, cross-platform design.

## Overview

This repository provides declarative system configuration for:

- **NixOS**: Desktop/server configuration with secure boot (lanzaboote), and container support (Podman)
- **Darwin/macOS**: System configuration via nix-darwin with home-manager integration

Key features:

- Single source of truth for all configurations
- Secrets management via sops-nix with age encryption
- Modular structure for cross-platform code sharing
- Reproducible, version-controlled system state

## Prerequisites

- Nix with flakes enabled
- age or SSH key for sops-nix secrets

Enable flakes if not already:

```nix
# Add to ~/.config/nix/nix.conf or /etc/nix/nix.conf
experimental-features = nix-command flakes
```

## Rebuilding

### NixOS

Rebuild and switch to the new configuration:

```bash
sudo nixos-rebuild switch --flake .#nixos
```

### Darwin/macOS

Rebuild and switch to the new configuration:

```bash
darwin-rebuild switch --flake .#zhaochanglongdeMacBook-Air
```

## Secrets Management

Secrets are encrypted using sops-nix with age encryption.

### Adding/Editing Secrets

```bash
# Edit or create a new secret
sops shared/secrets/<secret-name>.yaml

# Secrets are automatically encrypted when saved
# They decrypt at system activation time
```

### How It Works

1. Secrets are stored encrypted in [`shared/secrets/`](shared/secrets/)
2. The [`.sops.yaml`](.sops.yaml) config specifies which age key can decrypt
3. On system activation, sops-nix decrypts secrets to `/run/secrets/`
4. Services read secrets from the ephemeral `/run/secrets/` path

## Development

### Making Changes

1. Edit configuration files in the appropriate directory:
   - [`nixos/`](nixos/) for NixOS-specific config
   - [`darwin/`](darwin/) for Darwin-specific config
   - [`shared/`](shared/) for cross-platform config

2. Stage changes (nix only sees git-tracked files):

   ```bash
   git add .
   ```

3. Test the build:

   ```bash
   # NixOS
   nixos-rebuild build --flake .#nixos

   # Darwin
   darwin-rebuild build --flake .#zhaochanglongdeMacBook-Air
   ```

4. Apply changes:

   ```bash
   # NixOS
   sudo nixos-rebuild switch --flake .#nixos

   # Darwin
   darwin-rebuild switch --flake .#zhaochanglongdeMacBook-Air
   ```

### Updating Dependencies

Periodically update flake inputs to get the latest packages:

```bash
# Update all inputs
nix flake update

# Update specific input
nix flake update nixpkgs

# Or lock a specific input to latest
nix flake lock --update-input nixpkgs
```

**Recommended:** Update inputs weekly or before major changes.

## Structure

```text
.
├── flake.nix           # Main flake configuration
├── flake.lock          # Pinned input versions
├── .sops.yaml          # SOPS encryption configuration
├── darwin/             # macOS-specific configuration
│   ├── default.nix     # Darwin system config
│   ├── home/           # Darwin home-manager config
│   ├── packages/       # Darwin-specific packages
│   └── sops.nix        # Darwin sops configuration
├── nixos/              # NixOS-specific configuration
│   ├── default.nix     # NixOS system config
│   ├── home/           # NixOS home-manager config
│   ├── packages/       # NixOS-specific packages
│   ├── hardware-configuration.nix
│   ├── secureboot/     # Secure boot keys
│   └── sops.nix        # NixOS sops configuration
└── shared/             # Cross-platform configuration
    ├── home/           # Shared home-manager config
    ├── secrets/        # Encrypted secrets
    └── system/         # Shared system config
```

## Validation

### Cross-Platform Secret Sharing

After rebuilding on both platforms, verify secrets are accessible:

- **NixOS**: Check `ls /run/secrets/` contains expected secrets
- **Darwin**: Check `ls /run/user/$(id -u)/secrets/` contains expected secrets

## Inputs

Key flake inputs:

- **nixpkgs**: Package repository
- **nix-darwin**: macOS system management
- **home-manager**: User environment management
- **sops-nix**: Secrets management
- **lanzaboote**: Secure boot for NixOS
- **nixvim**: Neovim configuration
