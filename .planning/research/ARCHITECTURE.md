# Architecture Research

**Domain:** Nix Flake Configuration for NixOS and Darwin (macOS) Systems
**Researched:** 2026-03-14
**Confidence:** HIGH (based on project codebase analysis and established Nix patterns)

## Standard Architecture

### System Overview

```
+-----------------------------------------------------------------------------+
|                              flake.nix (Root)                               |
|  +-----------+  +-------------+  +---------------+  +--------------------+  |
|  |  Inputs   |  |  Outputs    |  | specialArgs   |  | System Configs      |  |
|  | (deps)    |  | (targets)   |  | (shared ctx)  |  | darwinConfigurations|  |
|  +-----------+  +-------------+  +---------------+  | nixosConfigurations |  |
|                                                     +--------------------+  |
+-----------------------------------------------------------------------------+
                                     |
              +----------------------+----------------------+
              |                      |                      |
              v                      v                      v
+-------------------------+  +-------------------------+  +-------------------------+
|   Platform Layer        |  |   Platform Layer        |  |   Shared Layer          |
|   darwin/               |  |   nixos/                |  |   shared/               |
|  +-------------------+   |  |  +-------------------+   |  |  +-------------------+   |
|  | default.nix       |   |  |  | default.nix      |   |  |  | home/             |   |
|  | home/             |   |  |  | home/            |   |  |  | system/           |   |
|  | packages/         |   |  |  | packages/        |   |  |  | secrets/          |   |
|  | sops.nix          |   |  |  | sops.nix        |   |  |  +-------------------+   |
|  +-------------------+   |  |  | hardware-*       |   |  |                         |
+-------------------------+  |  | microvm/         |   |  +-------------------------+
                             |  +-------------------+   |
                             +-------------------------+
                                     |
              +----------------------+----------------------+
              |                      |                      |
              v                      v                      v
+-------------------------+  +-------------------------+  +-------------------------+
|   Home-Manager Layer    |  |   Secrets Layer         |  |   Module Layer          |
|   User-space config     |  |   sops-nix integration  |  |   Feature modules       |
|  +-------------------+   |  |  +-------------------+   |  |  +-------------------+   |
|  | zsh.nix           |   |  |  | .sops.yaml        |   |  |  | git.nix           |   |
|  | tmux/            |   |  |  | secrets/*.yaml   |   |  |  | ssh.nix           |   |
|  | nixvim/          |   |  |  | sops.secrets     |   |  |  | kitty.nix         |   |
|  | direnv.nix       |   |  |  +-------------------+   |  |  | vscode.nix        |   |
|  +-------------------+   |  +-------------------------+  |  +-------------------+   |
+-------------------------+                               +-------------------------+
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| flake.nix | Dependency declaration, output definitions, system configuration entry points | Nix flake schema with inputs/outputs |
| inputs | External flake dependencies (nixpkgs, home-manager, sops-nix, etc.) | Flake URL references with version pinning |
| specialArgs | Shared context passed to all modules (inputs, self reference) | Attribute set passed to nixosSystem/darwinSystem |
| darwin/ | macOS-specific system configuration | nix-darwin modules, homebrew integration, macOS defaults |
| nixos/ | NixOS-specific system configuration | NixOS modules, hardware config, services |
| shared/ | Cross-platform configuration shared between systems | Common home-manager modules, system packages, secrets |
| shared/home/ | User-space configuration (shell, editors, tools) | home-manager modules imported by both platforms |
| shared/system/ | Shared system packages and base configuration | nixpkgs config, common system packages |
| shared/secrets/ | Encrypted secrets (sops) | YAML files encrypted with age/GPG |
| home/ | User-specific home-manager configuration | Platform-specific user dotfiles |
| packages/ | System-level packages | Platform-specific package lists |
| sops.nix | Secrets decryption and environment setup | sops-nix module configuration |

## Recommended Project Structure

```
nix-config/
+-- flake.nix                    # Root flake: inputs, outputs, system configs
+-- .sops.yaml                   # Sops encryption config (age/GPG keys)
|
+-- shared/                      # Cross-platform (shared between NixOS/Darwin)
|   +-- home/                    # Shared home-manager modules
|   |   +-- default.nix          # Aggregates all shared home modules
|   |   +-- zsh.nix              # Shell configuration
|   |   +-- git.nix              # Git configuration
|   |   +-- ssh.nix              # SSH configuration
|   |   +-- tmux/                # Tmux (complex config as directory)
|   |   +-- direnv.nix           # Direnv for project environments
|   |   +-- opencode.nix         # AI assistant tools
|   |   +-- claude-code.nix      # Claude Code CLI
|   |   +-- mcp.nix              # MCP server configs
|   |
|   +-- system/                  # Shared system configuration
|   |   +-- default.nix          # Common packages, nix settings
|   |   +-- sops.nix             # Shared secrets definitions
|   |
|   +-- secrets/                 # Encrypted secrets (sops)
|       +-- api_keys.yaml        # API keys
|       +-- mihomo_config.yaml   # Service configs
|       +-- secureboot.yaml      # Secure boot keys
|
+-- darwin/                      # macOS-specific
|   +-- default.nix              # Darwin system entry point
|   +-- home/                    # macOS home-manager
|   |   +-- default.nix          # Imports home-manager, configures user
|   |   +-- zhaochanglong.nix    # User-specific imports shared + local
|   |   +-- git.nix              # macOS-specific git config
|   |   +-- ssh.nix              # macOS-specific SSH config
|   |
|   +-- packages/                # macOS system packages
|   |   +-- default.nix          # Homebrew + nix packages
|   |
|   +-- sops.nix                 # Darwin sops configuration
|
+-- nixos/                       # NixOS-specific
|   +-- default.nix              # NixOS system entry point
|   +-- hardware-configuration.nix # Hardware scan (generated)
|   |
|   +-- home/                    # NixOS home-manager
|   |   +-- default.nix          # Imports home-manager, configures user
|   |   +-- zhaochanglong.nix    # User-specific imports shared + local
|   |   +-- git.nix              # NixOS-specific git config
|   |   +-- ssh.nix              # NixOS-specific SSH config
|   |   +-- kitty.nix            # Terminal emulator
|   |   +-- vscode.nix           # Editor config
|   |   +-- zed.nix              # Editor config
|   |   +-- ollama.nix           # AI service
|   |   +-- nixvim/              # Neovim config (complex as directory)
|   |       +-- default.nix      # Aggregates nixvim modules
|   |       +-- base.nix        # Base neovim settings
|   |       +-- colorscheme.nix
|   |       +-- options.nix
|   |       +-- keymaps/
|   |       +-- plugins/
|   |
|   +-- packages/                # NixOS system packages
|   |   +-- default.nix          # System packages
|   |   +-- flatpak.nix         # Flatpak apps
|   |
|   +-- sops.nix                 # NixOS sops + secureboot secrets
|   +-- podman.nix               # Container runtime
|   +-- zerotier.nix             # VPN
|   +-- sshd.nix                 # SSH daemon
|   +-- microvm/                 # VM configurations
|       +-- default.nix
|       +-- openclaw.nix
|
+-- secureboot/                  # Secure boot keys (NixOS)
    +-- keys/
    +-- GUID
```

### Structure Rationale

- **flake.nix as root:** Single entry point for all configurations, pinning dependency versions
- **Platform directories (darwin/, nixos/):** Clear separation of OS-specific configuration
- **shared/ directory:** DRY principle - common code lives here, imported by both platforms
- **Module pattern:** Each feature as its own .nix file enables easy enable/disable and testing
- **Directory for complex configs:** nixvim/, tmux/ use directories when config grows large
- **User-specific files:** zhaochanglong.nix pattern allows multi-user support in future

## Architectural Patterns

### Pattern 1: Flake Input with Follows

**What:** Declare inputs once, have other inputs follow the same nixpkgs
**When:** Always - prevents version mismatches and reduces closure size
**Trade-offs:** Slightly more complex input declaration, but essential for reproducibility

**Example:**
```nix
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  nix-darwin.url = "github:nix-darwin/nix-darwin";
  nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

  home-manager.url = "github:nix-community/home-manager";
  home-manager.inputs.nixpkgs.follows = "nixpkgs";

  sops-nix.url = "github:Mic92/sops-nix";
  sops-nix.inputs.nixpkgs.follows = "nixpkgs";
};
```

### Pattern 2: SpecialArgs for Context Sharing

**What:** Pass `inputs` and `self` to all modules via specialArgs
**When:** Always - allows modules to access other flakes and self-reference
**Trade-offs:** Adds parameters to all modules, but essential for modular imports

**Example:**
```nix
outputs = inputs@{ self, nixpkgs, ... }:
let
  specialArgs = { inherit inputs self; };
in {
  nixosConfigurations."hostname" = nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    modules = [ ./nixos ];
  };
};
```

### Pattern 3: Module Imports with Self-Reference

**What:** Use `${self}/shared/...` to import shared modules from platform configs
**When:** When sharing code between platforms
**Trade-offs:** Requires self in specialArgs, but enables clean cross-platform imports

**Example:**
```nix
# In nixos/default.nix or darwin/default.nix
imports = [
  "${self}/shared/system"    # Shared system packages
];

# In user home config
imports = [
  "${self}/shared/home"      # Shared home-manager modules
];
```

### Pattern 4: Inline Home-Manager Module

**What:** Configure home-manager inline with its module import
**When:** For simple configuration that doesn't need separate files
**Trade-offs:** Slightly less discoverable, but reduces file count for simple cases

**Example:**
```nix
imports = [
  inputs.home-manager.nixosModules.home-manager {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.myuser = import ./myuser.nix;
    home-manager.extraSpecialArgs = { inherit inputs self; };
    home-manager.backupFileExtension = "bak";
  }
];
```

### Pattern 5: Secrets via Sops-Nix

**What:** Encrypt secrets with sops, decrypt at activation time
**When:** Any sensitive data (API keys, passwords, certificates)
**Trade-offs:** Requires initial setup, but keeps secrets in git safely

**Example:**
```nix
# In sops.nix
sops.secrets.api_key = {
  sopsFile = "${self}/shared/secrets/api_keys.yaml";
  owner = "root";
  mode = "0400";
};

# Usage in config
environment.extraInit = ''
  export MY_API_KEY="$(cat ${config.sops.secrets.api_key.path})"
'';
```

## Data Flow

### Configuration Build Flow

```
flake.nix (Inputs Resolved)
    |
    v
+---------------------------+
| specialArgs = {           |
|   inherit inputs self;    |
| }                         |
+---------------------------+
    |
    v
nixpkgs.lib.nixosSystem     nix-darwin.lib.darwinSystem
    |                              |
    v                              v
+---------------------------+  +---------------------------+
| ./nixos/default.nix       |  | ./darwin/default.nix      |
| imports: [                |  | imports: [                |
|   ./hardware-config       |  |   ./home                   |
|   ./packages              |  |   ./packages               |
|   "${self}/shared/system" |  |   "${self}/shared/system"  |
|   ./home                  |  |   ./sops.nix               |
|   ./sops.nix              |  | ]                          |
|   ./podman.nix            |  +---------------------------+
|   ...                     |              |
| ]                         |              v
+---------------------------+  +---------------------------+
    |                              |                 |
    v                              v                 v
+---------------------------+  +-----------+  +-----------+
| Home-Manager Module       |  | Homebrew  |  | sops-nix  |
| (user-space config)       |  | packages  |  | (decrypt) |
+---------------------------+  +-----------+  +-----------+
    |
    v
+---------------------------+
| ./nixos/home/user.nix     |
| imports: [                |
|   "${self}/shared/home"   | <--- Shared cross-platform
|   ./git.nix               | <--- Platform-specific
|   ./nixvim                |
|   ...                     |
| ]                         |
+---------------------------+
    |
    v
+---------------------------+
| ./shared/home/*.nix       |
| (zsh, tmux, git, ssh...)  |
+---------------------------+
```

### Secrets Flow

```
.sops.yaml (Encryption Config)
    |
    | defines who can decrypt
    v
shared/secrets/*.yaml (Encrypted)
    |
    | sops-nix module decrypts at activation
    v
+---------------------------+
| config.sops.secrets.*     |
| .path -> /run/secrets/... |
+---------------------------+
    |
    | referenced in services/environment
    v
Application receives secret path
```

### Key Data Flows

1. **Input Resolution:** Flake inputs are locked in flake.lock, then passed via `specialArgs` to all modules
2. **Module Aggregation:** Platform default.nix aggregates all relevant modules via imports
3. **Shared Code Access:** Platform configs import from `${self}/shared/` for cross-platform code
4. **Home-Manager Integration:** User configs import shared home modules, then add platform-specific modules
5. **Secrets Injection:** Sops-nix decrypts secrets at activation, paths injected via `config.sops.secrets.*.path`

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| Single user, 1-2 machines | Current structure is optimal |
| Single user, 3-10 machines | Add hosts/ directory with per-host hardware configs, use let bindings for common config |
| Multi-user, many machines | Add users/ directory, create user profiles, parameterize by hostname/user |
| Fleet management | Consider colmena or nixos-anywhere for deployment, add deploy.nix |

### Scaling Priorities

1. **First bottleneck:** Repetition across similar machines
   - Fix: Extract common profiles into profiles/ directory (desktop, server, laptop)

2. **Second bottleneck:** Hardware-specific config scattered
   - Fix: Add hosts/ directory with per-host hardware-configuration.nix and overrides

3. **Third bottleneck:** Secrets management complexity
   - Fix: Use sops-nix groups, consider vault integration for larger fleets

## Anti-Patterns

### Anti-Pattern 1: Inline Everything in flake.nix

**What people do:** Put all configuration directly in flake.nix outputs
**Why it's wrong:** Becomes unmaintainable quickly, no modularity, hard to test
**Do this instead:** Use imports to separate concerns, keep flake.nix minimal

```nix
# BAD: Everything inline
nixosConfigurations."hostname" = nixpkgs.lib.nixosSystem {
  modules = [{
    # 500 lines of config here
  }];
};

# GOOD: Import from file
nixosConfigurations."hostname" = nixpkgs.lib.nixosSystem {
  modules = [ ./nixos ];
};
```

### Anti-Pattern 2: Duplicating Shared Configuration

**What people do:** Copy-paste configs between darwin/ and nixos/
**Why it's wrong:** Drift between platforms, double maintenance burden
**Do this instead:** Create shared/ directory, import from both platforms

```nix
# BAD: Duplicated in both darwin/home and nixos/home
programs.git = { ... };

# GOOD: In shared/home/git.nix, imported by both
imports = [ "${self}/shared/home" ];
```

### Anti-Pattern 3: Hardcoding Secrets

**What people do:** Put API keys, passwords directly in nix files
**Why it's wrong:** Secrets in git, exposed in nix store (world-readable)
**Do this instead:** Use sops-nix or agenix to encrypt secrets

```nix
# BAD: Secret in plain text
services.myService.apiKey = "sk-12345...";

# GOOD: Secret via sops
sops.secrets.my_api_key = {
  sopsFile = "${self}/shared/secrets/api_keys.yaml";
};
services.myService.apiKeyFile = config.sops.secrets.my_api_key.path;
```

### Anti-Pattern 4: Not Following nixpkgs

**What people do:** Each input uses its own nixpkgs version
**Why it's wrong:** Different versions of same packages, larger closure, potential conflicts
**Do this instead:** All inputs follow the same nixpkgs

```nix
# BAD: Multiple nixpkgs versions
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  home-manager.url = "github:nix-community/home-manager";
  # home-manager uses its own nixpkgs!
};

# GOOD: Single nixpkgs version
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  home-manager.url = "github:nix-community/home-manager";
  home-manager.inputs.nixpkgs.follows = "nixpkgs";
};
```

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| nixpkgs | Input flake | Core package source, pin to channel/commit |
| nix-darwin | Input flake | macOS system management |
| home-manager | Input flake + nixosModule/darwinModule | User-space declarative config |
| sops-nix | Input flake + module | Secrets encryption/decryption |
| lanzaboote | Input flake + module | Secure boot for NixOS |
| nixvim | Input flake | Neovim configuration |
| plasma-manager | Input flake + homeModule | KDE Plasma configuration |
| microvm | Input flake | MicroVM virtualization |
| nix-flatpak | Input flake | Flatpak management |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| flake.nix -> platforms | specialArgs | Passes inputs, self to all modules |
| platform -> shared | imports with `${self}/shared` | Cross-platform code sharing |
| platform -> home-manager | home-manager module import | User-space configuration |
| home-manager -> shared/home | imports with `${self}/shared/home` | Shared user configs |
| platform -> sops-nix | sops.secrets definitions | Secrets decryption |
| sops-nix -> applications | config.sops.secrets.*.path | Runtime secret paths |

## Build Order Implications

When implementing or extending this configuration, follow this dependency order:

1. **flake.nix** - Must be correct first (inputs, outputs structure)
2. **shared/system/** - Base system config used by all platforms
3. **shared/secrets/** - Encrypted secrets (can be added incrementally)
4. **shared/home/** - Cross-platform user config
5. **Platform entry points** (darwin/default.nix, nixos/default.nix)
6. **Platform-specific modules** (packages, services)
7. **User home configs** (import shared + add platform-specific)

**Critical path:** flake.nix -> shared/ -> platform entry -> home-manager -> user modules

## Sources

- Project codebase analysis (HIGH confidence)
- Nix Flakes official documentation: https://nix.dev/concepts/flakes
- home-manager documentation: https://nix-community.github.io/home-manager/
- sops-nix documentation: https://github.com/Mic92/sops-nix
- nix-darwin documentation: https://github.com/nix-darwin/nix-darwin
- NixOS manual: https://nixos.org/manual/nixos/stable/

---
*Architecture research for: Nix Flake Configuration Systems*
*Researched: 2026-03-14*