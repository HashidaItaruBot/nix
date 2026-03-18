# 目录结构

## 根目录布局

```
.
├── flake.nix              # Flake 入口定义
├── flake.lock             # 锁定依赖版本
├── CLAUDE.md              # Claude Code 指令
├── README.md              # 项目说明
├── .sops.yaml             # SOPS 加密配置
├── .gitignore
├── .rules                 # 项目规则
│
├── nixos/                 # NixOS 配置
├── darwin/                # macOS Darwin 配置
├── shared/                # 跨平台共享配置
│
├── scripts/               # 辅助脚本
├── .github/               # GitHub 配置
├── .opencode/             # OpenCode 配置
└── .claude/               # Claude Code 配置
```

## NixOS 配置 (`nixos/`)

```
nixos/
├── default.nix              # 系统配置入口
├── hardware-configuration.nix # 硬件配置 (自动生成)
├── sops.nix                 # 密钥配置
├── podman.nix               # Podman 容器配置
├── zerotier.nix             # ZeroTier VPN
├── sshd.nix                 # SSH 服务
│
├── packages/                # 系统级包配置
│   ├── default.nix          # 核心开发工具
│   └── flatpak.nix          # Flatpak 配置
│
├── home/                    # 用户配置 (home-manager)
│   ├── default.nix          # home-manager 入口
│   ├── zhaochanglong.nix    # 主用户配置
│   ├── git.nix
│   ├── ssh.nix
│   ├── vscode.nix
│   ├── zed.nix
│   ├── kitty.nix
│   ├── ollama.nix
│   ├── 1password.nix
│   └── appimage.nix
│
├── nixvim/                  # Neovim 配置模块
│   ├── default.nix
│   ├── base.nix
│   ├── colorscheme.nix
│   ├── options.nix
│   ├── clipboard.nix
│   ├── extra-plugins.nix
│   ├── plugins/             # Neovim 插件配置
│   │   ├── default.nix
│   │   ├── telescope.nix
│   │   ├── treesitter.nix
│   │   ├── lualine.nix
│   │   ├── neo-tree.nix
│   │   ├── gitsigns.nix
│   │   ├── conform.nix
│   │   ├── avante.nix       # AI 编程助手
│   │   └── ... (更多插件)
│   └── keymaps/             # 键盘映射
│       ├── default.nix
│       ├── general.nix
│       ├── lsp.nix
│       ├── telescope.nix
│       └── neo-tree.nix
│
└── microvm/                 # MicroVM 虚拟机
    ├── default.nix
    └── openclaw.nix         # OpenClaw AI 虚拟机
```

## Darwin 配置 (`darwin/`)

```
darwin/
├── default.nix              # macOS 系统配置入口
├── sops.nix                 # 密钥配置
│
├── packages/                # 系统级包 (Homebrew)
│   └── default.nix          # Homebrew casks 和公式
│
└── home/                    # 用户配置
    ├── default.nix          # home-manager 入口
    ├── zhaochanglong.nix    # 主用户配置
    ├── git.nix
    └── ssh.nix
```

## 共享配置 (`shared/`)

```
shared/
├── home/                    # 跨平台用户配置
│   ├── default.nix          # 共享入口
│   ├── git.nix              # Git 配置
│   ├── zsh.nix              # Zsh 配置
│   ├── tmux/                # Tmux 配置
│   │   └── default.nix
│   ├── ssh.nix              # SSH 配置
│   ├── direnv.nix           # Direnv 配置
│   ├── mcp.nix              # MCP 配置
│   ├── claude-code.nix      # Claude Code 配置
│   └── opencode.nix         # OpenCode 配置
│
├── system/                  # 跨平台系统配置
│   ├── default.nix          # 系统入口
│   └── sops.nix             # 密钥管理配置
│
└── secrets/                 # 加密密钥存储
    ├── mihomo_config.yaml
    ├── api_keys.yaml
    └── telegram_bot_token.yaml
```

## 关键文件路径速查

| 用途 | 路径 |
|------|------|
| Flake 入口 | `flake.nix` |
| NixOS 系统配置 | `nixos/default.nix` |
| macOS 系统配置 | `darwin/default.nix` |
| 共享用户配置 | `shared/home/default.nix` |
| 密钥管理 | `shared/system/sops.nix` |
| NixVim 入口 | `nixos/home/nixvim/default.nix` |
| Homebrew 配置 | `darwin/packages/default.nix` |
| 系统包配置 | `nixos/packages/default.nix` |

## 命名约定

### 文件命名

- `default.nix` - 模块入口
- `*.nix` - Nix 配置文件
- `hardware-configuration.nix` - 硬件配置（自动生成）

### 目录命名

- `packages/` - 软件包配置
- `home/` - 用户级配置
- `plugins/` - 插件配置
- `keymaps/` - 键盘映射
- `secrets/` - 加密数据

### 用户命名

- 用户名: `zhaochanglong`
- 主机名 (NixOS): `nixos`
- 主机名 (macOS): `zhaochanglongdeMacBook-Air`