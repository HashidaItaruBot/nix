# Neovim 配置

基于 [nixvim](https://github.com/nix-community/nixvim) 的声明式 Neovim 配置，通过 home-manager 管理，与 NixOS flake 集成。

## 概览

| 项目 | 说明 |
|------|------|
| 管理框架 | nixvim（`nixos-26.05` 分支） |
| 入口 | `home/nixvim/default.nix` |
| 激活方式 | home-manager（`home/zhaochanglong.nix` 导入） |
| Leader 键 | `<Space>` |
| 配色 | Catppuccin Mocha |
| 补全 | blink.cmp + LuaSnip + friendly-snippets |

配置按功能拆分为独立 Nix 模块，修改单个插件或选项时只需编辑对应文件。

## 目录结构

```
home/nixvim/
├── default.nix              # nixvim 入口，启用 programs.nixvim
└── config/
    ├── default.nix          # 聚合所有子模块
    ├── options.nix          # 全局选项（行号、缩进、signcolumn）
    ├── colorscheme.nix      # Catppuccin 配色与插件集成
    ├── which-key.nix        # 快捷键提示分组
    ├── keymaps.nix          # 全局键位（窗口导航）
    ├── bufferline.nix       # 标签栏 + devicons
    ├── treesitter.nix       # 语法高亮 / 缩进
    ├── neo-tree.nix         # 文件树
    ├── gitsigns.nix         # Git 变更标记与 hunk 操作
    ├── telescope.nix        # 模糊搜索（fzf-native + ripgrep）
    ├── lsp.nix              # LSP 服务器与诊断键位
    ├── completion.nix       # blink.cmp 自动补全
    └── guess-indent.nix     # 自动检测缩进 / 尊重 .editorconfig
```

## 插件

| 模块 | 插件 | 用途 |
|------|------|------|
| `colorscheme.nix` | catppuccin | 主题，已集成 gitsigns / treesitter / telescope / LSP / neo-tree / bufferline / which-key / blink.cmp |
| `bufferline.nix` | bufferline.nvim, nvim-web-devicons | 顶部 buffer 标签栏 |
| `treesitter.nix` | nvim-treesitter | 语法高亮、缩进（见下方语言列表） |
| `neo-tree.nix` | neo-tree.nvim | 侧边文件树，跟随当前文件 |
| `gitsigns.nix` | gitsigns.nvim | 行内 Git 标记、hunk 暂存/重置/预览 |
| `telescope.nix` | telescope.nvim + fzf-native | 文件 / 内容 / buffer 搜索 |
| `lsp.nix` | nvim-lspconfig | 语言服务器（见下方列表） |
| `completion.nix` | blink.cmp, LuaSnip, friendly-snippets | LSP + 路径 + snippet + buffer 补全 |
| `which-key.nix` | which-key.nvim | 快捷键分组提示 |
| `guess-indent.nix` | guess-indent.nvim | 按文件内容推断 tab/space 宽度 |

### Treesitter 语法

已启用：`bash`, `c`, `cpp`, `css`, `html`, `javascript`, `json`, `lua`, `markdown`, `nix`, `python`, `regex`, `rust`, `scala`, `toml`, `tsx`, `typescript`, `vim`, `yaml`。

## LSP 服务器

| 语言 | 服务器 | 备注 |
|------|--------|------|
| Nix | nixd | 格式化使用 `alejandra` |
| Rust | rust-analyzer | 不通过 nix 安装 cargo/rustc，使用项目 toolchain（direnv / rustup） |
| Python | basedpyright, ruff | 类型检查 + lint |
| C / C++ | clangd | |
| TypeScript / JavaScript | ts_ls | |
| Lua | lua_ls | |
| Shell | bashls | |
| JSON | jsonls | |
| YAML | yamlls | |
| TOML | taplo | |
| Markdown | marksman | |
| HTML / CSS | html, cssls | |

LSP 已开启 inlay hints。诊断与 Git 标记共用行号列（`signcolumn = "yes"`），不单独占用 gutter。

## 快捷键

`<leader>` = `<Space>`。按 `<leader>` 后 which-key 会显示分组提示。

### 窗口导航

| 键位 | 作用 |
|------|------|
| `<C-h>` | 聚焦左侧窗口 |
| `<C-j>` | 聚焦下方窗口 |
| `<C-k>` | 聚焦上方窗口 |
| `<C-l>` | 聚焦右侧窗口 |

### 文件树（neo-tree）

| 键位 | 作用 |
|------|------|
| `<leader>e` | 切换文件树（reveal 当前文件） |

### 搜索（telescope）

| 键位 | 作用 |
|------|------|
| `<leader>ff` | 查找文件 |
| `<leader>fg` | 项目内 live grep |
| `<leader>fb` | 查找已打开 buffer |

Telescope 默认忽略 `.git/`、`node_modules/`、`.cache/`、`dist/`、`target/`。搜索框位于顶部，使用 fzf-native 加速排序。

### LSP

| 键位 | 作用 |
|------|------|
| `K` | hover 文档 |
| `gd` | 跳转到定义 |
| `gD` | 跳转到声明 |
| `gi` | 跳转到实现 |
| `gt` | 跳转到类型定义 |
| `gr` | 查找引用 |
| `<leader>lr` | 重命名 |
| `<leader>la` | code action |
| `<leader>lf` | 格式化 |
| `[d` / `]d` | 上一条 / 下一条诊断 |
| `<leader>ld` | 诊断浮窗 |
| `<leader>lq` | 诊断写入 location list |

### Git（gitsigns）

| 键位 | 作用 |
|------|------|
| `[h` / `]h` | 上一个 / 下一个 hunk |
| `<leader>gs` | 暂存 hunk（可视模式支持选区） |
| `<leader>gr` | 重置 hunk |
| `<leader>gS` | 暂存整个 buffer |
| `<leader>gR` | 重置整个 buffer |
| `<leader>gu` | 撤销暂存 hunk |
| `<leader>gp` | 预览 hunk |
| `<leader>gi` | 行内预览 hunk |
| `<leader>gb` | 整行 blame |
| `<leader>gd` | diff 当前文件 |
| `<leader>gt` | 切换当前行 blame |
| `ih`（operator / visual） | 选择 hunk 文本对象 |

## 编辑器选项

- 绝对行号 + 相对行号
- 默认 2 空格缩进（`expandtab`）；`guess-indent` 会按文件内容覆盖，并尊重 `.editorconfig`
- `breakindent` 开启，换行缩进与当前行对齐
- Neo-tree 中 `<Space>` 已禁用，避免与 leader 冲突

## 修改与应用

1. 编辑 `home/nixvim/config/` 下对应模块，或新增 `.nix` 后在 `config/default.nix` 的 `imports` 中引用
2. 暂存更改（Nix flake 只追踪 git 中的文件）：

```bash
git add home/nixvim/
```

3. 确认主机名并重建系统（home-manager 随 NixOS 一并切换）：

```bash
hostname
# b850m → .#b850m
# hades → .#hades

sudo nixos-rebuild switch --flake .#<hostname>
```

仅做构建检查、不切换：

```bash
nixos-rebuild build --flake .#<hostname>
```

## 添加新插件或 LSP

**新插件**：在 `config/` 下新建模块（参考现有文件），在 `config/default.nix` 加入 `imports`。

**新 LSP 服务器**：编辑 `config/lsp.nix` 的 `plugins.lsp.servers`，nixvim 会处理安装与 on_attach。若需项目级 toolchain（如 Rust），可设置 `installCargo = false` 等选项。

**新 Treesitter 语法**：在 `config/treesitter.nix` 的 `grammarPackages` 中追加 grammar 名称。

更多选项见 [nixvim 文档](https://nix-community.github.io/nixvim/) 与各插件的 options 定义。

## 相关依赖

- flake input：`github:nix-community/nixvim/nixos-26.05`（`flake.nix`）
- 系统侧：`alejandra`（nixd 格式化）、`ripgrep`（telescope grep）
- Rust 项目：依赖 direnv / rustup 提供 `rust-analyzer` 所需的 toolchain
