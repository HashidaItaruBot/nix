## ADDED Requirements

### Requirement: Nixvim flake input

The flake SHALL declare a `nixvim` input pinned to the `nixos-26.05` branch, aligned with the existing `nixpkgs` and `home-manager` release versions.

#### Scenario: Flake evaluates successfully

- **WHEN** `nix flake check` or `nixos-rebuild build` is run
- **THEN** the `nixvim` input resolves without version conflicts against `nixpkgs` or `home-manager`

### Requirement: Home-manager module entry

The system SHALL provide a `home/nixvim/default.nix` module that imports `inputs.nixvim.homeModules.nixvim` and enables `programs.nixvim`.

#### Scenario: Module is wired into user config

- **WHEN** `home/zhaochanglong.nix` imports `./nixvim`
- **THEN** home-manager activates nixvim for user `zhaochanglong`

### Requirement: Modular configuration layout

The nixvim configuration SHALL be split into separate importable modules:

- `options.nix` — global Neovim options (colorscheme, opts, diagnostics, autocmds)
- `keymaps.nix` — base keymaps not tied to a specific plugin
- `plugins/default.nix` — plugin aggregation entry

#### Scenario: Configuration composes from modules

- **WHEN** `programs.nixvim.imports` in `default.nix` lists `options.nix`, `keymaps.nix`, and `plugins`
- **THEN** each module contributes its settings to the final Neovim build without circular imports

### Requirement: Build verification

The nixvim configuration SHALL pass `nixos-rebuild build --flake .#<hostname>` after files are git-tracked.

#### Scenario: Dry-run build succeeds

- **WHEN** all `home/nixvim/` files are staged with `git add` and build is run for the current hostname
- **THEN** the Neovim derivation builds without evaluation or compilation errors
