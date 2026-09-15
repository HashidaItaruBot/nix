# Nix Configuration

基于 Nix Flake 的声明式系统配置，管理两台 NixOS (x86_64-linux) 机器。

## 概览

- **NixOS 26.05**：KDE Plasma 6 桌面环境，Hyprland 窗口管理器，PipeWire 音频，fcitx5 输入法
- 使用 **Lix** 替代标准 Nix
- 通过 **sops-nix + age** 管理密钥
- 通过 **home-manager** + **plasma-manager** 统一管理用户与桌面配置
- **lanzaboote** 安全启动 + TPM2 LUKS 解密
- **nixpkgs-unstable overlay**：按需引入 unstable 软件包（Cursor、Zed 等）
- 游戏与串流：Steam、Sunshine、WiVRn + Monado（OpenXR/VR）
- 网络：NetworkManager、ZeroTier

## 前置条件

- 启用 flake 的 Nix（或 Lix）

```nix
# ~/.config/nix/nix.conf 或 /etc/nix/nix.conf
experimental-features = nix-command flakes
```

## 机器

| Flake target | 主机名 | 主板 / 硬件 | 网卡 | GPU | 特殊内核模块 |
|-------------|--------|-------------|------|-----|-------------|
| `.#b850m` | `b850m` | Gigabyte B850M | r8125 (2.5G) + mt7921e (WiFi) | RX 7900 XT (RDNA3) | r8125, it87, drivetemp |
| `.#hades` | `hades` | — | — | AMD RDNA3 | — |

两台机器均使用 Btrfs 子卷 + LUKS + TPM2 自动解密，Zen 内核，ROCm 支持。

`b850m` 额外配置了 PCIe ASPM 禁用、it87 主板传感器、mt7921e udev 规则，以及 lanzaboote measured boot（PCR 0/4/7）。

## 快速开始

构建或切换前，先确认当前主机名并选择对应的 flake target：

```bash
hostname
# b850m → --flake .#b850m
# hades → --flake .#hades
```

```bash
# 构建检查
nixos-rebuild build --flake .#b850m
nixos-rebuild build --flake .#hades

# 应用配置
sudo nixos-rebuild switch --flake .#b850m
sudo nixos-rebuild switch --flake .#hades
```

> Nix 只在 git 追踪的文件上操作，修改 `.nix` 文件后需先 `git add` 再构建。

## 项目结构

```text
.
├── flake.nix                    # Flake 入口，定义系统配置和输入源
├── flake.lock
├── .sops.yaml                   # SOPS 加密配置
├── default.nix                  # 系统配置入口 (KDE Plasma 6 + SDDM + PipeWire + fcitx5)
├── sops.nix                     # 密钥管理 (mihomo, API keys)
├── sshd.nix                     # SSH 服务
├── zram.nix                     # ZRAM 内存压缩 (zstd)
├── firewall.nix                 # 防火墙端口 (SillyTavern, Openlist 等)
├── overlays/                    # nixpkgs overlay
│   ├── default.nix              # 挂载 unstable overlay
│   └── unstable.nix             # 从 nixpkgs-unstable 引入选定软件包
├── hardware/                    # 各机器硬件配置
│   ├── b850m.nix                # LIANLI B850M (LUKS+TPM2, Zen, ROCm, lanzaboote)
│   └── hades.nix                # Hades (LUKS+TPM2, Zen, ROCm, lanzaboote)
├── packages/                    # 系统级软件包与服务
│   ├── default.nix              # 桌面应用 + Steam + Sunshine + 开发工具
│   ├── flatpak.nix              # Flatpak 支持
│   ├── podman.nix               # Podman 容器
│   ├── hyprland.nix             # Hyprland 窗口管理器
│   ├── ccache.nix               # C/C++ 编译缓存
│   ├── coolercontrol.nix        # 硬件温控 (liquidctl)
│   ├── wivrn.nix                # WiVRn + Monado VR 串流
│   ├── nix-ld.nix               # nix-ld 动态链接支持
│   ├── zerotier.nix             # ZeroTier 网络
│   ├── reasonix.nix             # Reasonix CLI 自定义包
│   ├── codegraph.nix            # Codegraph 工具
│   ├── nipaplay-appimage.nix    # NipaPlay AppImage 封装
│   ├── ecc-universal.nix        # ECC Universal 工具
│   ├── langcli.nix              # LangCLI 工具
│   └── openclaude.nix           # OpenClaude 自定义包
├── home/                        # home-manager 配置
│   ├── default.nix              # 入口（挂载 home-manager）
│   ├── zhaochanglong.nix        # 用户入口（导入各模块）
│   ├── git.nix                  # Git 配置 (SSH 签名 via 1Password)
│   ├── ssh.nix                  # SSH 配置
│   ├── zsh.nix                  # Zsh 配置
│   ├── tmux/                    # Tmux 配置
│   ├── direnv.nix               # Direnv 配置
│   ├── helix.nix                # Helix 编辑器
│   ├── nixvim/                  # Neovim (nixvim) 配置
│   ├── uv.nix                   # Python uv 工具
│   ├── codex.nix                # Codex CLI
│   ├── openclaude.nix           # OpenClaude 配置
│   ├── opencode.nix             # OpenCode 配置
│   ├── kitty.nix                # Kitty 终端
│   ├── zed.nix                  # Zed 编辑器
│   ├── 1password.nix            # 1Password 自动启动
│   ├── appimage.nix             # AppImage 集成
│   ├── podman/                  # Podman 用户配置 (Openlist)
│   └── config/                  # 桌面环境配置
│       ├── hypr/                # Hyprland 窗口管理器
│       ├── rofi/                # Rofi 启动器
│       └── waybar/              # Waybar 状态栏
└── secrets/                     # SOPS 加密密钥文件
    ├── api_keys.yaml            # API 密钥 (DeepSeek, Exa)
    └── mihomo_config.yaml       # Mihomo 代理配置
```

## 密钥管理

使用 sops-nix + age 加密密钥文件。

```bash
# 编辑或创建密钥
sops secrets/<name>.yaml

# 保存时自动加密，系统激活时解密到 /run/secrets/
```

管理的密钥：

- `mihomo_config` — 代理配置（mihomo 服务当前默认关闭）
- `exa_api_key` / `deepseek_api_key` — API 密钥（导出为环境变量）

Secure Boot 证书通过 lanzaboote 的 `pkiBundle = "/etc/secureboot"` 引用，需在目标机器上预先部署。

## Flake 输入

| 输入 | 用途 |
|------|------|
| `nixpkgs` | 软件包仓库 (nixos-26.05) |
| `nixpkgs-unstable` | 选定软件包的 unstable 来源（经 overlay 引入） |
| `home-manager` | 用户环境管理 (release-26.05) |
| `lanzaboote` | NixOS 安全启动 (v1.1.0) |
| `sops-nix` | 密钥管理 |
| `nix-flatpak` | Flatpak 支持 (v0.7.0) |
| `plasma-manager` | KDE Plasma 配置管理 |
| `nixvim` | Neovim 声明式配置 (nixos-26.05) |

## 开发

### 修改流程

1. 执行 `hostname` 确认当前机器
2. 编辑配置文件
3. `git add` 暂存更改（Nix 只识别 git 追踪的文件）
4. `nixos-rebuild build --flake .#<host>` 构建检查
5. `sudo nixos-rebuild switch --flake .#<host>` 应用更改
6. `git commit` 提交

### 新增软件惯例

- **系统级 GUI 应用 / CLI 工具** → `packages/default.nix` 的 `environment.systemPackages`
- **用户级 home-manager 配置** → `home/` 下新建 `.nix` 文件，在 `home/zhaochanglong.nix` 的 `imports` 中引用
- **自定义包** → `packages/` 下新建 `.nix` 文件，在 `packages/default.nix` 中用 `callPackage` 引用
- **系统服务** → 新建 `.nix` 模块文件，在 `default.nix` 的 `imports` 中引用
- **密钥** → `secrets/` 下新建/编辑 `.yaml`，在 `sops.nix` 中声明

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

`.github/workflows/ci.yml` 在 push/PR 到 `main` 时执行 flake 有效性检查。
