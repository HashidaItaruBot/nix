# Nix Configuration

基于 Nix Flake 的声明式系统配置，管理两台 NixOS (x86_64-linux) 机器。

## 概览

- **NixOS**: KDE Plasma 6 桌面环境，Hyprland 窗口管理器，PipeWire 音频，fcitx5 输入法
- 使用 **Lix** 替代标准 Nix
- 通过 **sops-nix + age** 管理密钥
- 通过 **home-manager** 统一管理用户配置
- **lanzaboote** 安全启动

## 前置条件

- 启用 flake 的 Nix（或 Lix）

```nix
# ~/.config/nix/nix.conf 或 /etc/nix/nix.conf
experimental-features = nix-command flakes
```

## 机器

| 机器 | 主机名 | 硬件配置 |
|------|--------|----------|
| LIANLI (B850M) | `b850m` | AMD Ryzen + RX 7900 XT, Btrfs + LUKS + TPM2 |
| Hades | `hades` | AMD Ryzen + AMD GPU, Btrfs + LUKS + TPM2 |

## 快速开始

```bash
# 构建检查
nixos-rebuild build --flake .#b850m
nixos-rebuild build --flake .#hades

# 应用配置
sudo nixos-rebuild switch --flake .#b850m
sudo nixos-rebuild switch --flake .#hades
```

## 项目结构

```text
.
├── flake.nix                    # Flake 入口，定义系统配置和输入源
├── flake.lock
├── .sops.yaml                   # SOPS 加密配置
├── default.nix                  # 系统配置入口 (KDE Plasma 6 + SDDM)
├── sops.nix                     # 密钥管理 (mihomo, Secure Boot, API keys)
├── sshd.nix                     # SSH 服务
├── zerotier.nix                 # ZeroTier 网络
├── zram.nix                     # ZRAM 内存压缩
├── hardware/                    # 各机器硬件配置
│   ├── b850m.nix                # LIANLI B850M (LUKS + TPM2, Zen 内核, ROCm)
│   └── hades.nix                # Hades (LUKS + TPM2, Zen 内核, ROCm)
├── packages/                    # 系统级软件包
│   ├── default.nix              # 桌面应用 + Steam + Sunshine + 开发工具
│   ├── flatpak.nix              # Flatpak 支持
│   ├── podman.nix               # Podman 容器
│   ├── hyprland.nix             # Hyprland 窗口管理器
│   ├── ccache.nix               # C/C++ 编译缓存
│   ├── coolercontrol.nix        # 硬件温控 (liquidctl)
│   ├── reasonix.nix             # Reasonix CLI 工具
│   ├── nipaplay-appimage.nix    # NipaPlay AppImage 封装
│   ├── ecc-universal.nix        # ECC Universal 工具
│   └── langcli.nix              # LangCLI 工具
├── home/                        # home-manager 配置
│   ├── default.nix              # 入口
│   ├── zhaochanglong.nix        # 用户入口（导入各模块）
│   ├── git.nix                  # Git 全局配置 (SSH 签名)
│   ├── ssh.nix                  # SSH 配置
│   ├── zsh.nix                  # Zsh 配置
│   ├── tmux/                    # Tmux 配置
│   ├── direnv.nix               # Direnv 配置
│   ├── helix.nix                # Helix 编辑器
│   ├── uv.nix                   # Python uv 工具
│   ├── codex.nix                # Codex CLI
│   ├── openclaude.nix           # OpenClaude 配置
│   ├── opencode.nix             # OpenCode 配置
│   ├── kitty.nix                # Kitty 终端
│   ├── vscode.nix               # VS Code
│   ├── zed.nix                  # Zed 编辑器
│   ├── 1password.nix            # 1Password 自动启动
│   ├── appimage.nix             # AppImage 集成
│   ├── sbt.nix                  # Scala/SBT 配置
│   ├── podman/                  # Podman 用户配置
│   ├── mcp.nix                  # MCP 服务器 (playwright, sequential-thinking, exa)
│   └── config/                  # 桌面环境配置
│       ├── hypr/                # Hyprland 窗口管理器
│       ├── rofi/                # Rofi 启动器
│       └── waybar/              # Waybar 状态栏
├── secrets/                     # SOPS 加密密钥文件
│   ├── api_keys.yaml            # API 密钥 (DeepSeek, Exa)
│   ├── mihomo_config.yaml       # Mihomo 配置
│   └── secureboot.yaml          # Secure Boot 密钥
└── secureboot/                  # Secure Boot 证书
    ├── GUID
    └── keys/
        ├── PK/PK.pem
        ├── KEK/KEK.pem
        └── db/db.pem
```

## 密钥管理

使用 sops-nix + age 加密密钥文件。

```bash
# 编辑或创建密钥
sops secrets/<name>.yaml

# 保存时自动加密，系统激活时解密到：
#   /run/secrets/
```

管理的密钥：
- `mihomo_config` — 代理配置
- `sb_pk_key / sb_kek_key / sb_db_key` — Secure Boot 私钥
- `exa_api_key / deepseek_api_key` — API 密钥（导出为环境变量）

## Flake 输入

| 输入 | 用途 |
|------|------|
| `nixpkgs` | 软件包仓库 (unstable) |
| `home-manager` | 用户环境管理 |
| `lanzaboote` | NixOS 安全启动 |
| `sops-nix` | 密钥管理 |
| `nix-flatpak` | Flatpak 支持 |
| `plasma-manager` | KDE Plasma 配置管理 |

## 开发

### 修改流程

1. 编辑配置文件
2. `git add` 暂存更改（Nix 只识别 git 追踪的文件）
3. `nixos-rebuild build --flake .#<host>` 构建检查
4. `sudo nixos-rebuild switch --flake .#<host>` 应用更改
5. `git commit` 提交

### 更新依赖

```bash
nix flake update              # 更新所有输入
nix flake update nixpkgs      # 仅更新 nixpkgs
nix flake lock --update-input nixpkgs
```

### 格式化

```bash
nix fmt  # 使用 Alejandra 格式化所有 .nix 文件
```

### CI

CI 通过 `.github/workflows/ci.yml` 自动构建检查所有主机配置。
