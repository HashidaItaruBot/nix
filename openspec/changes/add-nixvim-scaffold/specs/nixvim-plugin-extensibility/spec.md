## ADDED Requirements

### Requirement: Custom plugin directory

The system SHALL provide `home/nixvim/plugins/custom/` as the designated location for user-defined plugin modules.

#### Scenario: Custom directory is documented

- **WHEN** the user reads `home/nixvim/plugins/custom/README.md`
- **THEN** instructions explain how to create a `.nix` module and import it from `plugins/default.nix`

### Requirement: Three extension patterns

The scaffold SHALL support three plugin integration patterns, documented in the custom plugin README:

1. **Nixvim built-in plugins** — `plugins.<name>.enable = true` in a module file
2. **extraPlugins** — vim plugins from `pkgs.vimPlugins` not yet wrapped by nixvim
3. **extraConfigLua / extraConfigLuaPost** — raw Lua configuration for advanced customization

#### Scenario: Adding a nixvim built-in plugin

- **WHEN** the user creates `plugins/custom/noice.nix` with `plugins.noice.enable = true` and adds `./custom/noice.nix` to `plugins/default.nix`
- **THEN** noice.nvim loads on next rebuild without editing kickstart modules

#### Scenario: Adding an unwrapped vim plugin

- **WHEN** the user creates a module using `extraPlugins = with pkgs.vimPlugins; [ some-plugin ]` and corresponding `extraConfigLua`
- **THEN** the plugin is available in Neovim after rebuild

### Requirement: Kickstart/custom separation

Kickstart plugin modules under `plugins/kickstart/` SHALL remain unmodified when adding custom plugins; all user extensions go through `plugins/custom/` and `plugins/default.nix` imports.

#### Scenario: Upstream kickstart sync

- **WHEN** the user updates a kickstart plugin module from upstream kickstart.nixvim
- **THEN** custom plugins in `plugins/custom/` are unaffected

### Requirement: Plugin aggregation entry

`plugins/default.nix` SHALL serve as the single import point for all plugins, with clearly separated sections for kickstart core, kickstart optional, and custom plugins.

#### Scenario: Plugin import order is explicit

- **WHEN** inspecting `plugins/default.nix`
- **THEN** kickstart imports appear first, optional plugins are commented, and a dedicated comment block marks the custom plugin import area
