## ADDED Requirements

### Requirement: Kickstart plugin modules

The system SHALL provide one nixvim module file per kickstart plugin under `home/nixvim/plugins/kickstart/`, mirroring the layout of [kickstart.nixvim](https://github.com/JMartJonesy/kickstart.nixvim).

#### Scenario: Plugin file exists for each kickstart plugin

- **WHEN** inspecting `home/nixvim/plugins/kickstart/`
- **THEN** modules exist for: gitsigns, which-key, telescope, lsp, conform, blink-cmp, todo-comments, mini, treesitter, and the optional plugins debug, indent-blankline, lint, autopairs, neo-tree

### Requirement: Core plugins enabled by default

`plugins/default.nix` SHALL import and enable the following kickstart core plugins:

- gitsigns, which-key, telescope, lsp, conform, blink-cmp, todo-comments, mini, treesitter

#### Scenario: Core plugins active after rebuild

- **WHEN** the user runs `nvim` after `nixos-rebuild switch`
- **THEN** Telescope (`<leader>sf`), LSP diagnostics, blink-cmp completion, and Treesitter highlighting are functional

### Requirement: Optional plugins disabled by default

Optional kickstart plugins (debug, indent-blankline, lint, autopairs, neo-tree) SHALL be present as module files but commented out in `plugins/default.nix`.

#### Scenario: Enabling an optional plugin

- **WHEN** the user uncomments `./kickstart/debug.nix` in `plugins/default.nix` and rebuilds
- **THEN** the debug (nvim-dap) plugin is loaded without modifying other plugin modules

### Requirement: Global options parity with kickstart

`options.nix` SHALL configure kickstart-equivalent defaults:

- colorscheme: tokyonight (night style)
- leader keys: space
- clipboard sync via wl-copy (Wayland) and xsel (X11)
- diagnostic signs with Nerd Font icons when `have_nerd_font = true`
- yank highlight autocmd

#### Scenario: Base editor experience matches kickstart

- **WHEN** the user opens Neovim with a Nerd Font terminal
- **THEN** tokyonight theme loads, line numbers display, and yank operations trigger visual highlight

### Requirement: LSP and tooling integration

The LSP module SHALL enable `nil_ls` and `lua_ls` servers, fidget.nvim, and lazydev; the conform module SHALL provide formatter configuration; the treesitter module SHALL enable auto-install for common languages.

#### Scenario: Nix file editing works out of the box

- **WHEN** the user opens a `.nix` file in Neovim
- **THEN** nil_ls provides LSP features (diagnostics, hover) and Treesitter provides syntax highlighting
