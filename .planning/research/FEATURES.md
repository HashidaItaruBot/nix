# Feature Research

**Domain:** Nix Flake Configuration for NixOS and Darwin (macOS)
**Researched:** 2026-03-14
**Confidence:** MEDIUM (based on project analysis and training knowledge; web searches returned limited results)

## Feature Landscape

### Table Stakes (Users Expect These)

Features users assume exist. Missing these = product feels incomplete.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Modular structure | Nix Flake projects are inherently modular; users expect organized code | LOW | Standard practice: separate by platform (nixos/, darwin/, shared/) |
| Home-manager integration | Declarative user-space is the primary value of Nix configs | MEDIUM | UseGlobalPkgs, UseUserPackages, backupFileExtension |
| Secrets management | All configs need secrets (API keys, tokens, passwords) | MEDIUM | sops-nix with age/SSH key encryption |
| Cross-platform support | Users with multiple OSes want unified config | MEDIUM | Shared modules + platform-specific modules |
| Shell configuration | Zsh is the default; autosuggestions, syntax highlighting expected | LOW | oh-my-zsh integration common |
| Git configuration | Version control setup is fundamental | LOW | userName, userEmail, aliases |
| SSH configuration | Remote access is standard | LOW | Key management, known hosts |
| Direnv integration | Development environments are essential for Nix users | LOW | nix-direnv for caching |
| Basic dev tools | vim, git, tree, wget, htop, fd, fzf, ripgrep expected | LOW | Standard Nixpkgs packages |
| Nix LSP and formatting | nixd/nil + nixpkgs-fmt for development | LOW | Essential for editing Nix files |
| Flakes with proper inputs | Modern Nix uses flakes; proper follows chains expected | MEDIUM | nixpkgs.follows prevents version drift |

### Differentiators (Competitive Advantage)

Features that set the product apart. Not required, but valuable.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Secure Boot (lanzaboote) | UEFI secure boot on NixOS; tamper-proof boot chain | HIGH | Requires sops-nix for key management, PKI setup |
| MicroVM support | Lightweight VMs for services, testing, isolation | HIGH | microvm.nix integration, declarative VM definitions |
| nixvim (declarative Neovim) | Full Neovim config in Nix; reproducible editor | MEDIUM | Plugin management, LSP, keymaps all declarative |
| Plasma Manager | Declarative KDE Plasma configuration | MEDIUM | hotkeys, themes, settings all version-controlled |
| nix-flatpak integration | Declarative Flatpak apps alongside Nix packages | LOW | Extends app availability beyond nixpkgs |
| Cross-platform secret sharing | Single secret repository for all platforms | MEDIUM | Shared secrets/ directory with platform-agnostic access |
| Homebrew integration (Darwin) | Mac App Store + GUI apps not in nixpkgs | LOW | mas CLI for App Store, homebrew casks for GUI apps |
| Desktop environment config | Full DE setup (Plasma 6, SDDM, PipeWire) | HIGH | Audio, display manager, power management |
| AI tooling integration | opencode, claude-code, MCP servers in config | MEDIUM | Developer productivity tools |
| Virtualization stack | Waydroid (Android), QEMU, Podman | HIGH | Gaming, containers, VMs all declarative |
| Gaming setup | Steam + Proton-GE + MangoHud + Sunshine | MEDIUM | Game streaming, performance overlays |

### Anti-Features (Commonly Requested, Often Problematic)

Features that seem good but create problems.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Imperative package installation | Users want `nix-env -i` for quick installs | Breaks reproducibility, creates untracked state | Use `environment.systemPackages` or `home.packages` |
| Hardcoded secrets in config | Easier to just paste API keys | Security risk, can't commit to public repos, breaks sharing | sops-nix with encrypted YAML files |
| Multiple Nix implementations | Some want Lix, some want CppNix | Compatibility issues, flake inputs may conflict | Choose one (Lix recommended for performance) and standardize |
| Manual system state changes | Users want to tweak settings manually | Drift from declarative config, breaks rebuild | All changes through config files, use `nixos-rebuild switch` |
| Non-flake Nix paths | Fallback to channels or nixpkgs paths | Confuses flake inputs, breaks purity | All dependencies through flake inputs |
| Global unfree toggle without config | Easy: `allowUnfree = true` globally | Installs unfree without awareness | Per-package unfree or explicit list |
| Real-time config sync | Like iCloud for dotfiles | Complexity, merge conflicts, network dependency | Git-based deployment, manual rebuild |

## Feature Dependencies

```
[Secrets Management (sops-nix)]
    └──requires──> [Age/SSH key generation]
                       └──requires──> [Initial secrets encryption]

[Home-manager]
    └──requires──> [User account definition]
                       └──requires──> [Platform-specific module import]

[Secure Boot (lanzaboote)]
    └──requires──> [sops-nix] (for key management)
                       └──requires──> [PKI key generation]
                              └──requires──> [Secure Boot hardware support]

[MicroVM]
    └──requires──> [microvm.nix input]
    └──requires──> [Host kernel with KVM support]

[nixvim]
    └──requires──> [nixvim input]
    └──requires──> [Home-manager integration]

[Plasma Manager]
    └──requires──> [plasma-manager input]
    └──requires──> [Home-manager integration]
    └──requires──> [Plasma 6 desktop]

[Cross-platform config]
    └──requires──> [Shared modules directory]
    └──requires──> [Platform detection in imports]

[Homebrew (Darwin)]
    └──requires──> [nix-darwin]
    └──conflicts──> [Pure Nix package management] (impure by design)

[Virtualization (Waydroid)]
    └──requires──> [Linux kernel with Waydroid support]
    └──conflicts──> [Darwin platform]
```

### Dependency Notes

- **sops-nix requires initial key setup:** SSH or age key must exist before first decrypt; one-time setup per machine
- **Home-manager requires user account:** User must be defined in system config before home-manager can manage their home
- **Secure Boot requires hardware support:** UEFI with Secure Boot capability, not all hardware supports it
- **Plasma Manager enhances desktop config:** Works alongside NixOS desktop modules for complete Plasma setup
- **MicroVM conflicts with Darwin:** Linux-only feature, requires KVM
- **Homebrew conflicts with pure Nix:** Homebrew is imperative outside Nix, but nix-darwin provides declarative wrapper

## MVP Definition

### Launch With (v1)

Minimum viable product - what is needed to validate the concept.

- [x] Modular structure (darwin/, nixos/, shared/) - Essential for maintainability
- [x] Home-manager integration - Core value proposition
- [x] Secrets management (sops-nix) - Required for any real config
- [x] Cross-platform support (NixOS + Darwin) - Primary project goal
- [x] Shell configuration (zsh + oh-my-zsh) - Daily driver functionality
- [x] Git configuration - Developer workflow
- [x] SSH configuration - Remote access
- [x] Direnv + nix-direnv - Development environments
- [x] Basic dev tools - Functional system
- [x] Nix LSP and formatting - Self-hosting development

### Add After Validation (v1.x)

Features to add once core is working.

- [x] Secure Boot (lanzaboote) - Security hardening
- [x] MicroVM support - Service isolation
- [x] nixvim - Editor configuration
- [x] Plasma Manager - Desktop customization
- [x] nix-flatpak - Extended app availability
- [x] Cross-platform secret sharing - Simplified secret management
- [x] Homebrew integration (Darwin) - macOS app coverage
- [x] Desktop environment config - Full GUI setup
- [x] AI tooling integration - Developer productivity

### Future Consideration (v2+)

Features to defer until product-market fit is established.

- [ ] Impermanence (tmpfs root with persistent state) - Advanced security pattern, requires significant restructure
- [ ] Disko for declarative disk partitioning - New system setup, not maintenance
- [ ] NixOS anywhere / remote deployment - Multi-machine management
- [ ] Binary cache (Cachix or attic) - Performance optimization for teams
- [ ] Flake parts or flake-utils-plus - Advanced flake structure
- [ ] Multiple machine support (nixosConfigurations for multiple hosts) - Scaling pattern

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Modular structure | HIGH | LOW | P1 |
| Home-manager | HIGH | MEDIUM | P1 |
| Secrets management | HIGH | MEDIUM | P1 |
| Cross-platform support | HIGH | MEDIUM | P1 |
| Shell configuration | HIGH | LOW | P1 |
| Git configuration | HIGH | LOW | P1 |
| SSH configuration | MEDIUM | LOW | P1 |
| Direnv integration | HIGH | LOW | P1 |
| Basic dev tools | HIGH | LOW | P1 |
| Nix LSP/formatting | HIGH | LOW | P1 |
| Secure Boot | MEDIUM | HIGH | P2 |
| MicroVM | MEDIUM | HIGH | P2 |
| nixvim | MEDIUM | MEDIUM | P2 |
| Plasma Manager | MEDIUM | MEDIUM | P2 |
| nix-flatpak | LOW | LOW | P3 |
| Homebrew (Darwin) | MEDIUM | LOW | P2 |
| Desktop environment | MEDIUM | HIGH | P2 |
| AI tooling | LOW | MEDIUM | P3 |
| Virtualization stack | LOW | HIGH | P3 |
| Gaming setup | LOW | MEDIUM | P3 |

**Priority key:**
- P1: Must have for launch
- P2: Should have, add when possible
- P3: Nice to have, future consideration

## Competitor Feature Analysis

| Feature | Popular Dotfiles (e.g., hlissner) | Nix Starter Configs | This Project |
|---------|-----------------------------------|---------------------|--------------|
| Modular structure | YES (advanced) | YES (basic) | YES (platform-based) |
| Home-manager | YES | YES | YES |
| Secrets management | sops-nix | Optional | sops-nix (required) |
| Cross-platform | Rarely | Rarely | YES (primary goal) |
| Secure Boot | Sometimes | No | YES |
| MicroVM | Rarely | No | YES |
| Desktop environment | Often | Basic | Full Plasma 6 |
| nixvim | Sometimes | No | YES |
| Gaming setup | Sometimes | No | YES |

## Sources

- Project file analysis: flake.nix, nixos/, darwin/, shared/ directories
- Training knowledge of Nix ecosystem (MEDIUM confidence - verified through project structure)
- nix-community/home-manager documentation (training knowledge)
- Mic92/sops-nix documentation (training knowledge)
- nix-darwin documentation (training knowledge)

---
*Feature research for: Nix Flake Configuration (NixOS + Darwin)*
*Researched: 2026-03-14*