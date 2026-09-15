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

### 识别当前机器

**任何构建或切换操作之前，必须先通过 `hostname` 识别当前机器**，然后选择对应的 flake target：

```bash
hostname
# 输出 b850m → 使用 --flake .#b850m
# 输出 hades  → 使用 --flake .#hades
```

### 应用更改

修改配置后，使用以下命令应用更改（**先执行 `hostname` 确认机器**）：

```bash
# 当前机器为 b850m (LIANLI B850M)
sudo nixos-rebuild switch --flake .#b850m

# 当前机器为 hades
sudo nixos-rebuild switch --flake .#hades

# 仅检查构建 (不切换) — 同样需要先确认 hostname
nixos-rebuild build --flake .#b850m  # 或 .#hades
```

## 项目结构

```
.
├── flake.nix                    # Flake 入口，定义系统配置和输入源
├── flake.lock                   # 锁定输入版本
├── .sops.yaml                   # SOPS 加密配置
├── default.nix                  # 系统配置入口 (KDE Plasma 6 + SDDM + PipeWire + fcitx5)
├── sops.nix                     # 密钥管理 (mihomo, Secure Boot, API keys)
├── sshd.nix                     # SSH 服务
├── zram.nix                     # ZRAM 内存压缩 (zstd)
├── hardware/                    # 各机器硬件配置
│   ├── b850m.nix                # LIANLI B850M (LUKS+TPM2, Zen, ROCm, lanzaboote)
│   └── hades.nix                # Hades (LUKS+TPM2, Zen, ROCm, lanzaboote)
├── packages/                    # 系统级软件包
│   ├── default.nix              # 桌面应用 + Steam + Sunshine + 开发工具
│   ├── flatpak.nix              # Flatpak 支持
│   ├── podman.nix               # Podman 容器
│   ├── hyprland.nix             # Hyprland 窗口管理器
│   ├── ccache.nix               # C/C++ 编译缓存
│   ├── coolercontrol.nix        # 硬件温控 (liquidctl)
│   ├── reasonix.nix             # Reasonix CLI 自定义包
│   ├── nipaplay-appimage.nix    # NipaPlay AppImage 封装
│   ├── ecc-universal.nix        # ECC Universal 工具
│   ├── zerotier.nix             # ZeroTier 网络
│   └── langcli.nix              # LangCLI 工具
├── home/                        # home-manager 配置
│   ├── default.nix              # 入口（挂载 home-manager + plasma-manager）
│   ├── zhaochanglong.nix        # 用户入口（导入各模块）
│   ├── git.nix                  # Git 配置 (SSH 签名 via 1Password)
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
│   ├── api_keys.yaml            # API 密钥
│   ├── mihomo_config.yaml       # Mihomo 代理配置
│   └── secureboot.yaml          # Secure Boot 私钥
├── secureboot/                  # Secure Boot 证书
│   ├── GUID
│   └── keys/{PK,KEK,db}/
└── .github/workflows/ci.yml     # CI 构建检查
```

## Flake 输入源

| 输入 | 用途 |
|------|------|
| `nixpkgs` | 软件包仓库 (unstable) |
| `home-manager` | 用户环境管理 |
| `lanzaboote` | NixOS 安全启动 (v1.1.0) |
| `sops-nix` | 密钥管理 |
| `nix-flatpak` | Flatpak 支持 (v0.7.0) |
| `plasma-manager` | KDE Plasma 配置管理 |

## 机器

| flake target | 主机名 | 主板 | 网卡 | GPU | 特殊内核模块 |
|-------------|--------|------|------|-----|-------------|
| `.#b850m` | `b850m` | Gigabyte B850M | r8125 (2.5G) + mt7921e (WiFi) | RX 7900 XT (RDNA3) | r8125, it87, drivetemp |
| `.#hades` | `hades` | 其他 | 无特殊网卡 | AMD RDNA3 | 无 |

硬件配置文件位于 `hardware/` 目录：
- `hardware/b850m.nix` — 包含 PCIe ASPM 禁用、内核参数调优、it87 传感器、mt7921e udev 规则
- `hardware/hades.nix` — 更简洁的配置，无特殊内核模块或参数

## 重要注意事项

- **Lix**: 本项目使用 Lix 替代标准 Nix（`default.nix` 中 `nix.package = pkgs.lixPackageSets.stable.lix`）
- **格式化**: `nix fmt` 使用 Alejandra 格式化器
- **垃圾回收**: 已配置自动 GC（每天 02:00，保留 30 天）+ 自动 store 优化
- **允许非自由软件**: `nixpkgs.config.allowUnfree = true`
- **密钥管理**: 通过 sops-nix + age 加密，密钥文件在 `secrets/`
- **安全启动**: 通过 lanzaboote + TPM2 LUKS 解密实现，证书在 `secureboot/`，私钥通过 sops 管理
- **显示服务器**: X11 (KDE Plasma 6 + SDDM)，Hyprland Wayland 合成器可用
- **音频**: PipeWire (ALSA/PulseAudio 兼容)
- **CPU 调控器**: 性能模式 (`performance`)
- **Nix 必须在 git 追踪的文件上操作**：修改 `.nix` 文件后需要先 `git add` 再构建

## 工作流程

1. **识别机器** → `hostname` 确定当前机器（b850m 或 hades），后续命令使用对应的 flake target
2. **修改配置文件** → 编辑对应的 `.nix` 文件
3. **暂存更改** → `git add <changed-files>`（Nix 只看 git 追踪的文件）
4. **检查语法** → `nixos-rebuild build --flake .#<hostname>`
5. **应用更改** → `sudo nixos-rebuild switch --flake .#<hostname>`
6. **提交更改** → `git commit`

## 新增软件的惯例

- **系统级 GUI 应用/CLI 工具** → `packages/default.nix` 的 `environment.systemPackages`
- **用户级 home-manager 配置** → `home/` 下新建 `.nix` 文件，然后在 `home/zhaochanglong.nix` 的 `imports` 中引用
- **自定义包** → `packages/` 下新建 `.nix` 文件，在 `packages/default.nix` 中用 `callPackage` 引用
- **系统服务** → 新建 `.nix` 模块文件，在 `default.nix` 的 `imports` 中引用
- **密钥** → `secrets/` 下新建/编辑 `.yaml`，在 `sops.nix` 中声明

## 语言

使用中文与用户对话。

---
*更新于 2026-07-30*
