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
| AI | avante.nvim（Cursor CLI via ACP） |
| 格式化 | conform.nvim（保存时格式化，LSP fallback） |
| 自动保存 | auto-save.nvim（debounce 1s） |

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
    ├── tmux-navigator.nix   # Neovim ↔ tmux 窗格导航
    ├── bufferline.nix       # 标签栏 + devicons
    ├── buffer.nix           # Buffer 切换快捷键
    ├── treesitter.nix       # 语法高亮（indent 关闭，用 autoindent）
    ├── neo-tree.nix         # 文件树
    ├── gitsigns.nix         # Git 变更标记与 hunk 操作
    ├── telescope.nix        # 模糊搜索（fzf-native + ripgrep）
    ├── lsp.nix              # LSP 服务器与诊断键位
    ├── metals.nix           # Scala / Java LSP（nvim-metals）
    ├── completion.nix       # blink.cmp 自动补全
    ├── conform.nix          # 保存时格式化
    ├── guess-indent.nix     # 自动检测缩进 / 尊重 .editorconfig
    ├── autosave.nix         # 自动保存
    └── avante.nix           # Avante + Cursor CLI（ACP）
```

## 插件

| 模块 | 插件 | 用途 |
|------|------|------|
| `colorscheme.nix` | catppuccin | 主题，已集成 gitsigns / treesitter / telescope / LSP / neo-tree / bufferline / which-key / blink.cmp |
| `bufferline.nix` | bufferline.nvim, nvim-web-devicons | 顶部 buffer 标签栏 |
| `treesitter.nix` | nvim-treesitter | 语法高亮（indent 已关，避免覆盖 autoindent） |
| `neo-tree.nix` | neo-tree.nvim | 侧边文件树，跟随当前文件 |
| `gitsigns.nix` | gitsigns.nvim | 行内 Git 标记、hunk 暂存/重置/预览 |
| `telescope.nix` | telescope.nvim + fzf-native | 文件 / 内容 / buffer 搜索 |
| `lsp.nix` | nvim-lspconfig | 语言服务器（见下方列表） |
| `metals.nix` | nvim-metals | Scala / Java / sbt 语言服务器（Metals） |
| `completion.nix` | blink.cmp, LuaSnip, friendly-snippets | LSP + 路径 + snippet + buffer 补全 |
| `avante.nix` | avante.nvim, render-markdown.nvim | Cursor CLI ACP 侧栏聊天 / 改码 |
| `conform.nix` | conform.nvim | 保存时格式化（见下方格式化规则） |
| `which-key.nix` | which-key.nvim | 快捷键分组提示 |
| `tmux-navigator.nix` | vim-tmux-navigator | Neovim 分屏与 tmux pane 无缝切换（`<C-hjkl>`） |
| `guess-indent.nix` | guess-indent.nvim | 按文件内容推断 tab/space 宽度 |
| `autosave.nix` | auto-save.nvim | 编辑后自动保存（debounce 1s） |

### Treesitter 语法

已启用：`bash`, `c`, `cpp`, `css`, `html`, `javascript`, `json`, `lua`, `markdown`, `markdown_inline`, `nix`, `python`, `regex`, `rust`, `scala`, `toml`, `tsx`, `typescript`, `vim`, `vimdoc`, `yaml`。

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
| Scala / Java / sbt | Metals（nvim-metals） | 见 `metals.nix`；`lsp.nix` 中 `metals` 已禁用，避免与 nvim-metals 冲突 |

LSP 已开启 inlay hints。诊断与 Git 标记共用行号列（`signcolumn = "yes"`），不单独占用 gutter。

Metals 使用 Nix 管理的 `metals` 二进制（不通过 coursier 下载），并与 blink.cmp 共享 LSP capabilities。进度反馈走 LSP 通知（`statusBarProvider = "off"`）。

## 格式化（conform.nvim）

保存时自动格式化（`format_on_save`，超时 500ms）。未配置专用 formatter 的文件类型回退到 LSP 格式化。

| 文件类型 | Formatter | 备注 |
|----------|-----------|------|
| Nix | alejandra | |
| Python | ruff_format | |
| C / C++ | clang_format | |
| Lua | stylua | |
| Shell / Bash | shfmt | |
| TOML | taplo | |
| Rust | LSP fallback | rust-analyzer，依赖项目 toolchain |
| TypeScript / JavaScript | LSP fallback | ts_ls |
| JSON / YAML / Markdown / HTML / CSS | LSP fallback | 对应 LSP server |

conform 已开启 `autoInstall`，缺失的 formatter 会自动安装。

## 快捷键

`<leader>` = `<Space>`。按 `<leader>` 后 which-key 会显示分组提示。

### 窗口 / tmux 导航

与 `home/tmux/tmux.conf.local` 中的绑定配合，在 Neovim 分屏和 tmux pane 之间无缝切换。

| 键位 | 作用 |
|------|------|
| `<C-h>` | 左侧分屏 / pane |
| `<C-j>` | 下方分屏 / pane |
| `<C-k>` | 上方分屏 / pane |
| `<C-l>` | 右侧分屏 / pane |
| `<C-\>` | 上一个分屏 / pane |

### Buffer 切换

| 键位 | 作用 |
|------|------|
| `]b` / `<S-l>` | 下一个 buffer |
| `[b` / `<S-h>` | 上一个 buffer |
| `<leader>bb` | 切回上一个 buffer（类似 Alt+Tab） |
| `<leader>bn` / `<leader>bp` | 下一个 / 上一个 buffer |
| `<leader>1` … `<leader>9` | 跳到 bufferline 中第 1–9 个 buffer |
| `<leader>fb` | Telescope 模糊选择 buffer |

顶部 bufferline 会显示序号（1、2、3…），与 `<leader>1`–`<leader>9` 对应。

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

Metals buffer 复用上述 LSP 键位，并额外提供 Metals 专用快捷键（见下节）。

### Metals（Scala / Java / sbt）

| 键位 | 作用 |
|------|------|
| `<leader>lw` | 显示 Metals worksheet |
| `<leader>mi` | 导入构建（import build） |
| `<leader>mc` | Telescope 打开 Metals 命令列表 |

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

### Avante（Cursor CLI / ACP）

需先在终端执行 `agent login`。默认 provider 为 Cursor CLI（`~/.local/bin/agent acp`）。

| 键位 | 作用 |
|------|------|
| `<leader>aa` | 打开 / 提问（ask） |
| `<leader>an` | 新对话 |
| `<leader>ae` | 编辑选区 |
| `<leader>at` | 切换侧栏 |
| `<leader>af` | 聚焦 Avante 窗口 |
| `<leader>ar` | 刷新 |
| `<leader>az` | Zen 模式 |
| `<leader>aS` | 停止生成 |
| `<leader>ac` | 将当前 buffer 加入上下文 |
| `<leader>ah` | 选择历史 |
| `<leader>a?` | 选择模型 |

## 编辑器选项

- 绝对行号 + 相对行号
- 默认 2 空格缩进（`expandtab`）；`guess-indent` 会按文件内容覆盖，并尊重 `.editorconfig`
- `breakindent` 开启，换行缩进与当前行对齐
- Neo-tree 中 `<Space>` 已禁用，避免与 leader 冲突
- 编辑后 1 秒 debounce 自动保存（auto-save.nvim）

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

**新 LSP 服务器**：编辑 `config/lsp.nix` 的 `plugins.lsp.servers`，nixvim 会处理安装与 on_attach。若需项目级 toolchain（如 Rust），可设置 `installCargo = false` 等选项。Scala / Java 走 `metals.nix`，不要在 `lsp.nix` 中重复启用 `metals`。

**新 Treesitter 语法**：在 `config/treesitter.nix` 的 `grammarPackages` 中追加 grammar 名称。

**新 Formatter**：在 `config/conform.nix` 的 `formatters_by_ft` 中追加映射；conform 的 `autoInstall` 会自动拉取对应 formatter。

更多选项见 [nixvim 文档](https://nix-community.github.io/nixvim/) 与各插件的 options 定义。

## 相关依赖

- flake input：`github:nix-community/nixvim/nixos-26.05`（`flake.nix`）
- 系统侧：`alejandra`（nixd / conform 格式化）、`ripgrep`（telescope grep）、`metals`（Scala LSP）
- Rust 项目：依赖 direnv / rustup 提供 `rust-analyzer` 所需的 toolchain
- Scala 项目：Metals 通过 Nix 提供二进制；构建导入使用 `<leader>mi`
