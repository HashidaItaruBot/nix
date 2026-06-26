# Nix Configuration Project - Claude 指令

## 核心原则

本项目采用 **完全声明式** 的 Nix 配置管理。所有系统配置和软件包管理必须通过修改 Nix 配置文件完成。

## 强制约束

### 禁止的命令

**绝对禁止** 使用以下命令：

```bash
# 禁止 - 命令式安装软件
nix profile install
nix profile remove
nix-env -i
nix-env -e
nix-env -f

# 禁止 - 直接修改系统状态
nix-collect-garbage -d  # 除非明确要求清理

# 禁止 - 非声明式的系统修改
# 任何绕过 Nix 配置文件直接修改系统状态的操作
```

### 允许的操作

**必须** 通过以下声明式方式：

1. **安装软件** → 修改对应的 `packages/default.nix`
2. **系统配置** → 修改对应的 `default.nix` 或模块文件
3. **用户环境** → 修改 `home/` 目录下的 home-manager 配置
4. **添加服务** → 修改 systemd 相关 Nix 模块

### 应用更改

修改配置后，使用以下命令应用更改：

```bash
# NixOS (x86_64-linux)
sudo nixos-rebuild switch --flake .#nixos

# Darwin/macOS (aarch64-darwin)
darwin-rebuild switch --flake .#zhaochanglongdeMacBook-Air

# 仅检查构建 (不切换)
nixos-rebuild build --flake .#nixos
darwin-rebuild build --flake .#zhaochanglongdeMacBook-Air
```

## 项目结构

```
.
├── flake.nix                    # Flake 入口，定义系统配置和输入源
├── flake.lock                   # 锁定输入版本
├── .sops.yaml                   # SOPS 加密配置
├── nixos/                       # NixOS 配置 (x86_64-linux)
│   ├── default.nix              # 系统配置入口 (KDE Plasma 6 + SDDM)
│   ├── hardware-configuration.nix
│   ├── sops.nix                 # 密钥管理
│   ├── sshd.nix                 # SSH 服务
│   ├── zerotier.nix             # ZeroTier 网络
│   ├── zram.nix                 # ZRAM 内存压缩
│   ├── packages/                # 系统级软件包
│   │   ├── default.nix          # 桌面应用 + Steam + Sunshine
│   │   ├── flatpak.nix
│   │   ├── podman.nix
│   │   ├── hyprland.nix
│   │   └── incus/               # Incus 容器
│   └── home/                    # home-manager 配置
│       ├── default.nix          # 入口
│       ├── zhaochanglong.nix    # 用户入口（导入各模块）
│       ├── kitty.nix
│       ├── vscode.nix
│       ├── zed.nix
│       ├── config/              # 桌面环境配置
│       │   ├── hypr/            # Hyprland 窗口管理器
│       │   ├── rofi/            # Rofi 启动器
│       │   └── waybar/          # Waybar 状态栏
│       └── nixvim/              # Neovim 完整配置 (nixvim)
├── darwin/                      # macOS Darwin 配置 (aarch64-darwin)
│   ├── default.nix              # 系统配置入口
│   ├── sops.nix                 # 密钥管理
│   ├── packages/                # 系统级软件包
│   │   └── default.nix          # Homebrew casks + mas
│   └── home/                    # home-manager 配置
│       ├── default.nix          # 入口
│       └── zhaochanglong.nix    # 用户入口
└── shared/                      # 跨平台共享配置
    ├── system/                  # 共享系统配置
    │   └── default.nix          # 共享系统包 + 字体 + Lix 配置
    ├── home/                    # 共享 home-manager 配置
    │   ├── default.nix          # 入口
    │   ├── zsh.nix              # Zsh 配置
    │   ├── tmux/                # Tmux 配置
    │   ├── git.nix              # Git 全局配置
    │   ├── ssh.nix              # SSH 配置
    │   ├── direnv.nix           # Direnv 配置
    │   ├── helix.nix            # Helix 编辑器
    │   ├── uv.nix               # Python uv 工具
    │   ├── codex.nix            # Codex CLI
    │   ├── openclaude.nix       # OpenClaude 配置
    │   ├── opencode.nix         # OpenCode 配置
    │   └── mcp.nix              # MCP 工具
    ├── packages/                # 共享的自定义包
    │   ├── ecc-universal.nix
    │   ├── langcli.nix
    │   └── openclaude.nix
    └── secrets/                 # SOPS 加密的密钥文件
```

## Flake 输入源

| 输入 | 用途 |
|------|------|
| `nixpkgs` | 软件包仓库 (unstable) |
| `nix-darwin` | macOS 系统管理 |
| `home-manager` | 用户环境管理 |
| `nixvim` | Neovim 配置框架 |
| `sops-nix` | 密钥管理 |
| `lanzaboote` | NixOS 安全启动 |
| `plasma-manager` | KDE Plasma 配置管理 |
| `nix-flatpak` | Flatpak 支持 |
| `codewhale` | CodeWhale 工具 |

## 重要注意事项

- **Lix**: 本项目使用 Lix 替代标准 Nix（`shared/system/default.nix` 中配置）
- **格式化**: `nix fmt` 使用 Alejandra 格式化器
- **垃圾回收**: NixOS 已配置自动 GC（每天 02:00，保留 30 天）
- **允许非自由软件**: `nixpkgs.config.allowUnfree = true`
- **密钥管理**: 通过 sops-nix + age 加密，密钥文件在 `shared/secrets/`
- **Nix 必须在 git 追踪的文件上操作**：修改 `.nix` 文件后需要先 `git add` 再构建

## 工作流程

1. **修改配置文件** → 编辑对应的 `.nix` 文件
2. **暂存更改** → `git add <changed-files>`（Nix 只看 git 追踪的文件）
3. **检查语法** → `nixos-rebuild build --flake .#nixos` 或 `darwin-rebuild build --flake .#zhaochanglongdeMacBook-Air`
4. **应用更改** → `sudo nixos-rebuild switch --flake .#nixos` 或 `darwin-rebuild switch --flake .#zhaochanglongdeMacBook-Air`
5. **提交更改** → `git commit`

## 语言

使用中文与用户对话。

---
*更新于 2026-06-26*
