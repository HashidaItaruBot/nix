# Nix Configuration

A unified Nix Flake configuration for managing NixOS and Darwin (macOS) systems with modular, cross-platform design.

## Overview

This repository provides declarative system configuration for:

- **NixOS**: Desktop/server configuration with secure boot (lanzaboote), virtualization (MicroVM), and container support (Podman)
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

```bash
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

1. Secrets are stored encrypted in `shared/secrets/`
2. The `.sops.yaml` config specifies which age key can decrypt
3. On system activation, sops-nix decrypts secrets to `/run/secrets/`
4. Services read secrets from the ephemeral `/run/secrets/` path

### Verifying No Secrets in Nix Store

Run the verification script to ensure no plaintext secrets are in the nix store:

```bash
./scripts/verify-secrets.sh
```

## Development

### Making Changes

1. Edit configuration files in the appropriate directory:
   - `nixos/` for NixOS-specific config
   - `darwin/` for Darwin-specific config
   - `shared/` for cross-platform config

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
```

## Structure

```
.
├── flake.nix           # Main flake configuration
├── flake.lock          # Pinned input versions
├── .sops.yaml          # SOPS encryption configuration
├── darwin/             # macOS-specific configuration
│   ├── default.nix     # Darwin system config
│   ├── home.nix        # Darwin home-manager config
│   └── packages.nix    # Darwin-specific packages
├── nixos/              # NixOS-specific configuration
│   ├── default.nix     # NixOS system config
│   ├── home.nix        # NixOS home-manager config
│   ├── packages.nix    # NixOS-specific packages
│   └── hardware/       # Hardware-specific configs
└── shared/             # Cross-platform configuration
    ├── home.nix        # Shared home-manager config
    ├── secrets/        # Encrypted secrets
    └── system.nix      # Shared system config
```

## Updating Inputs

Run `nix flake update` periodically to update all flake inputs to their latest versions.

For individual input updates:

```bash
nix flake lock --update-input nixpkgs
```

Recommended: Update inputs weekly or before major changes.

## Validation

### Secrets Verification

Run `./scripts/verify-secrets.sh` after rebuild to verify no secrets leaked to nix store.

### Cross-Platform Secret Sharing

After rebuilding on both platforms, verify secrets are accessible:

- **NixOS**: Check `ls /run/secrets/` contains expected secrets
- **Darwin**: Check `ls /run/user/$(id -u)/secrets/` contains expected secrets

### MicroVM Networking (NixOS only)

Test MicroVM networking:

```bash
sudo microvm -m openclaw run
curl http://localhost:18789  # Should return OpenClaw UI
```

## Inputs

Key flake inputs:

- **nixpkgs**: Package repository
- **nix-darwin**: macOS system management
- **home-manager**: User environment management
- **sops-nix**: Secrets management
- **lanzaboote**: Secure boot for NixOS
- **nixvim**: Neovim configuration
- **microvm**: Virtualization support