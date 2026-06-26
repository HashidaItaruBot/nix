# Nix Configuration

基于 Nix Flake 的统一声明式系统配置，管理 NixOS (x86_64-linux) 和 macOS (aarch64-darwin)。

## 概览

- **NixOS**: KDE Plasma 6 桌面环境，Hyprland 窗口管理器，PipeWire 音频，fcitx5 输入法
- **macOS**: nix-darwin + home-manager 管理用户环境
- 使用 **Lix** 替代标准 Nix
- 通过 **sops-nix + age** 管理密钥
- 通过 **home-manager** 统一管理用户配置

## 前置条件

- 启用 flake 的 Nix（或 Lix）

```nix
# ~/.config/nix/nix.conf 或 /etc/nix/nix.conf
experimental-features = nix-command flakes
```

## 快速开始

### NixOS

```bash
# 构建检查
nixos-rebuild build --flake .#nixos

# 应用配置
sudo nixos-rebuild switch --flake .#nixos
```

### Darwin/macOS

```bash
# 构建检查
darwin-rebuild build --flake .#zhaochanglongdeMacBook-Air

# 应用配置
darwin-rebuild switch --flake .#zhaochanglongdeMacBook-Air
```

## 项目结构

```text
.
├── flake.nix                    # Flake 入口
├── flake.lock
├── .sops.yaml
├── nixos/                       # NixOS 配置
│   ├── default.nix              # 系统配置 (KDE Plasma 6)
│   ├── hardware-configuration.nix
│   ├── sops.nix / sshd.nix / zerotier.nix / zram.nix
│   ├── packages/                # 系统级包 + Flatpak + Podman + Incus
│   └── home/                    # home-manager
│       ├── kitty.nix / vscode.nix / zed.nix
│       ├── config/              # Hyprland / Rofi / Waybar
│       └── nixvim/              # Neovim 完整配置
├── darwin/                      # macOS 配置
│   ├── default.nix
│   ├── packages/                # Homebrew casks + mas
│   └── home/                    # home-manager
└── shared/                      # 跨平台共享
    ├── system/                  # 共享系统包 + 字体 + Lix
    ├── home/                    # zsh / tmux / git / ssh / helix / uv 等
    ├── packages/                # 自定义包 (langcli, ecc-universal 等)
    └── secrets/                 # SOPS 加密密钥
```

## 密钥管理

使用 sops-nix + age 加密密钥文件。

```bash
# 编辑或创建密钥
sops shared/secrets/<name>.yaml

# 保存时自动加密，系统激活时解密到：
#   NixOS: /run/secrets/
#   Darwin: /run/user/$(id -u)/secrets/
```

## Flake 输入

| 输入 | 用途 |
|------|------|
| `nixpkgs` | 软件包仓库 (unstable) |
| `nix-darwin` | macOS 系统管理 |
| `home-manager` | 用户环境管理 |
| `nixvim` | Neovim 配置框架 |
| `sops-nix` | 密钥管理 |
| `lanzaboote` | NixOS 安全启动 |
| `plasma-manager` | KDE Plasma 配置 |
| `nix-flatpak` | Flatpak 支持 |
| `codewhale` | CodeWhale 工具 |

## 开发

### 修改流程

1. 编辑配置文件
2. `git add` 暂存更改（Nix 只识别 git 追踪的文件）
3. `nixos-rebuild build --flake .#<target>` 构建检查
4. `<rebuild-command> switch --flake .#<target>` 应用更改
5. `git commit` 提交

### 更新依赖

```bash
nix flake update              # 更新所有输入
nix flake update nixpkgs     # 仅更新 nixpkgs
nix flake lock --update-input nixpkgs
```

### 格式化

```bash
nix fmt  # 使用 Alejandra 格式化所有 .nix 文件
```
