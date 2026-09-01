## 1. Flake 与依赖

- [x] 1.1 在 `flake.nix` inputs 中添加 `nixvim.url = "github:nix-community/nixvim/nixos-26.05"`
- [x] 1.2 运行 `nix flake lock` 更新 `flake.lock` 中的 nixvim 条目
- [x] 1.3 确认 `specialArgs` 已将 `inputs` 传递给 home-manager 模块（现有 `inherit inputs` 即可）

## 2. 模块骨架

- [x] 2.1 创建 `home/nixvim/default.nix`：导入 `inputs.nixvim.homeModules.nixvim`，enable nixvim，imports 子模块
- [x] 2.2 创建 `home/nixvim/options.nix`：tokyonight 主题、globals、clipboard、opts、diagnostics、autocmds、web-devicons、guess-indent
- [x] 2.3 创建 `home/nixvim/keymaps.nix`：Esc 清搜索、终端退出、Ctrl+hjkl 窗口导航
- [x] 2.4 创建 `home/nixvim/plugins/default.nix`：聚合 kickstart 核心/可选插件与 custom 扩展点

## 3. Kickstart 核心插件

- [x] 3.1 创建 `plugins/kickstart/gitsigns.nix`
- [x] 3.2 创建 `plugins/kickstart/which-key.nix`
- [x] 3.3 创建 `plugins/kickstart/telescope.nix`（含 fzf-native、ui-select 扩展）
- [x] 3.4 创建 `plugins/kickstart/lsp.nix`（nil_ls、lua_ls、fidget、lazydev、onAttach）
- [x] 3.5 创建 `plugins/kickstart/conform.nix`
- [x] 3.6 创建 `plugins/kickstart/blink-cmp.nix`（含 luasnip）
- [x] 3.7 创建 `plugins/kickstart/todo-comments.nix`
- [x] 3.8 创建 `plugins/kickstart/mini.nix`（ai、surround、statusline）
- [x] 3.9 创建 `plugins/kickstart/treesitter.nix`

## 4. Kickstart 可选插件

- [x] 4.1 创建 `plugins/kickstart/debug.nix`（nvim-dap 全家桶）
- [x] 4.2 创建 `plugins/kickstart/indent-blankline.nix`
- [x] 4.3 创建 `plugins/kickstart/lint.nix`
- [x] 4.4 创建 `plugins/kickstart/autopairs.nix`
- [x] 4.5 创建 `plugins/kickstart/neo-tree.nix`
- [x] 4.6 在 `plugins/default.nix` 中以注释形式保留可选插件 import

## 5. 自定义插件扩展

- [x] 5.1 创建 `plugins/custom/README.md`，说明三种扩展模式（built-in / extraPlugins / extraConfigLua）及示例
- [x] 5.2 在 `plugins/default.nix` 中预留 custom 插件 import 注释区域

## 6. Home-manager 集成

- [x] 6.1 在 `home/zhaochanglong.nix` imports 中添加 `./nixvim`
- [x] 6.2 `git add` 所有 `home/nixvim/` 文件及 `flake.nix`、`flake.lock`

## 7. 构建与验证

- [x] 7.1 运行 `hostname` 确认目标机器（b850m / hades）
- [x] 7.2 运行 `nixos-rebuild build --flake .#<hostname>` 验证配置可构建
- [x] 7.3 运行 `sudo nixos-rebuild switch --flake .#<hostname>` 应用配置
- [x] 7.4 启动 `nvim`，运行 `:checkhealth` 确认插件正常
- [x] 7.5 测试核心功能：`<leader>sf` 文件搜索、打开 `.nix` 文件验证 LSP 与 Treesitter
