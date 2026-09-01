## Why

当前 NixOS 配置已通过 home-manager 管理 Helix、Zed 等编辑器，但缺少一套声明式、可扩展的 Neovim 配置。用户希望基于 [kickstart.nixvim](https://github.com/JMartJonesy/kickstart.nixvim) 搭建 nixvim 脚手架，获得开箱即用的现代 Neovim 体验（LSP、补全、Telescope、Treesitter 等），同时保留清晰的模块化结构，便于后期按需启用/禁用插件或添加自定义配置。

## What Changes

- 在 `flake.nix` 中添加 `nixvim` flake input（`nixos-26.05` 分支，与 nixpkgs/home-manager 版本对齐）
- 新建 `home/nixvim/` 模块目录，通过 home-manager `programs.nixvim` 集成
- 采用 kickstart.nixvim 的分层结构：
  - `default.nix` — 入口，导入 nixvim homeModule
  - `options.nix` — 全局选项（colorscheme、opts、diagnostics、autocmds）
  - `keymaps.nix` — 基础键位映射
  - `plugins/default.nix` — 插件聚合入口
  - `plugins/kickstart/` — kickstart 上游插件模块（每插件一文件）
  - `plugins/custom/` — 用户自定义插件扩展点
- 默认启用 kickstart 核心插件：gitsigns、which-key、telescope、lsp、conform、blink-cmp、todo-comments、mini、treesitter
- 可选插件以注释形式保留（debug、indent-blankline、lint、autopairs、neo-tree），取消注释即可启用
- 在 `home/zhaochanglong.nix` 中导入 `./nixvim` 模块
- 提供 `plugins/custom/README.md` 说明如何添加自定义插件

## Capabilities

### New Capabilities

- `nixvim-integration`: nixvim flake input 与 home-manager 模块集成，提供可构建的 Neovim 配置入口
- `nixvim-kickstart-plugins`: 基于 kickstart.nixvim 的模块化插件集合，含核心与可选插件
- `nixvim-plugin-extensibility`: 自定义插件扩展机制，支持 nixvim 内置插件、extraPlugins 及 extraConfigLua

### Modified Capabilities

（无 — 本项目尚无既有 openspec specs）

## Impact

- **flake.nix / flake.lock**: 新增 `nixvim` input 及 lock 条目
- **home/zhaochanglong.nix**: 新增 `./nixvim` import
- **home/nixvim/**: 新建完整模块树（约 15+ 文件）
- **构建**: 需 `git add` 后 `nixos-rebuild build --flake .#<hostname>` 验证
- **运行时**: 用户登录后可通过 `nvim` 使用配置；与现有 Helix 配置并存，无冲突
