# Nix Configuration

A unified Nix Flake configuration for managing NixOS and Darwin (macOS) systems with modular, cross-platform design.

## Overview

This repository provides declarative system configuration for:

- **NixOS**: Desktop/server configuration with secure boot (lanzaboote), and container support (Podman)
- **Darwin/macOS**: System configuration via nix-darwin with home-manager integration

Key features:

- Single source of truth for all configurations
- Secrets management via sops-nix with age encryption
- Modular structure for cross-platform code sharing
- Reproducible, version-controlled system state

## Prerequisites

- Nix with flakes enabled
- age or SSH key for sops-nix secrets

Enable flakes if not already:

```nix
# Add to ~/.config/nix/nix.conf or /etc/nix/nix.conf
experimental-features = nix-command flakes
```

## Rebuilding

### NixOS

Rebuild and switch to the new configuration:

```bash
sudo nixos-rebuild switch --flake .#nixos
```

### Darwin/macOS

Rebuild and switch to the new configuration:

```bash
darwin-rebuild switch --flake .#zhaochanglongdeMacBook-Air
```

## Secrets Management

Secrets are encrypted using sops-nix with age encryption.

### Adding/Editing Secrets

```bash
# Edit or create a new secret
sops shared/secrets/<secret-name>.yaml

# Secrets are automatically encrypted when saved
# They decrypt at system activation time
```

### How It Works

1. Secrets are stored encrypted in [`shared/secrets/`](shared/secrets/)
2. The [`.sops.yaml`](.sops.yaml) config specifies which age key can decrypt
3. On system activation, sops-nix decrypts secrets to `/run/secrets/`
4. Services read secrets from the ephemeral `/run/secrets/` path

## Development

### Making Changes

1. Edit configuration files in the appropriate directory:
   - [`nixos/`](nixos/) for NixOS-specific config
   - [`darwin/`](darwin/) for Darwin-specific config
   - [`shared/`](shared/) for cross-platform config

2. Stage changes (nix only sees git-tracked files):

   ```bash
   git add .
   ```

3. Test the build:

   ```bash
   # NixOS
   nixos-rebuild build --flake .#nixos

   # Darwin
   darwin-rebuild build --flake .#zhaochanglongdeMacBook-Air
   ```

4. Apply changes:

   ```bash
   # NixOS
   sudo nixos-rebuild switch --flake .#nixos

   # Darwin
   darwin-rebuild switch --flake .#zhaochanglongdeMacBook-Air
   ```

### Updating Dependencies

Periodically update flake inputs to get the latest packages:

```bash
# Update all inputs
nix flake update

# Update specific input
nix flake update nixpkgs

# Or lock a specific input to latest
nix flake lock --update-input nixpkgs
```

**Recommended:** Update inputs weekly or before major changes.

## Structure

```text
.
├── flake.nix           # Main flake configuration
├── flake.lock          # Pinned input versions
├── .sops.yaml          # SOPS encryption configuration
├── darwin/             # macOS-specific configuration
│   ├── default.nix     # Darwin system config
│   ├── home/           # Darwin home-manager config
│   ├── packages/       # Darwin-specific packages
│   └── sops.nix        # Darwin sops configuration
├── nixos/              # NixOS-specific configuration
│   ├── default.nix     # NixOS system config
│   ├── home/           # NixOS home-manager config
│   ├── packages/       # NixOS-specific packages
│   ├── hardware-configuration.nix
│   ├── secureboot/     # Secure boot keys
│   └── sops.nix        # NixOS sops configuration
└── shared/             # Cross-platform configuration
    ├── home/           # Shared home-manager config
    ├── secrets/        # Encrypted secrets
    └── system/         # Shared system config
```

## Validation

### Cross-Platform Secret Sharing

After rebuilding on both platforms, verify secrets are accessible:

- **NixOS**: Check `ls /run/secrets/` contains expected secrets
- **Darwin**: Check `ls /run/user/$(id -u)/secrets/` contains expected secrets

## Inputs

Key flake inputs:

- **nixpkgs**: Package repository
- **nix-darwin**: macOS system management
- **home-manager**: User environment management
- **sops-nix**: Secrets management
- **lanzaboote**: Secure boot for NixOS
- **nixvim**: Neovim configuration

## Hyprland 配置规划

本仓库已在 NixOS 上启用 Hyprland（系统级见 [`nixos/packages/hyprland.nix`](nixos/packages/hyprland.nix)，用户级见 [`nixos/home/hyprland/default.nix`](nixos/home/hyprland/default.nix)）。当前用户级配置为单文件，基础框架可用，但存在一些问题需要修复，且缺少配套组件。下面是规划。

### 现有环境（已扫描全仓库）

读完全项目后，Hyprland 不是孤立运行，需要和以下既有配置协同：

| 系统/服务 | 当前状态 | 与 Hyprland 的关系 |
|-----------|---------|-------------------|
| **SDDM** (`services.displayManager.sddm`) | 启用 | 登录后选择 Hyprland 会话；UWSM 已通过 `withUWSM = true` 接管 |
| **Plasma6** (`services.desktopManager.plasma6`) | 启用 | 与 Hyprland 并存（用户在 SDDM 选择会话），共享 `~/.config` |
| **Plasma 锁屏** (`programs.plasma.kscreenlocker`) | 5 分钟自动锁屏 | **与 hyprlock/hypridle 冲突** — Hyprland 会话下 Plasma 锁屏不会激活，需用 hyprlock 替代 |
| **linux-wallpaperengine** (`services.linux-wallpaperengine`) | 启用，壁纸 ID `823335782`，显示器 `DP-3` | **已管理壁纸**，不需 `hyprpaper`；可在 `exec-once` 中显式启动或交给 systemd 用户服务 |
| **fcitx5** (`i18n.inputMethod`) | 启用，含 rime/chinese-addons/material-color | Hyprland 会话下需通过 `exec-once` 或 systemd 用户单元拉起 |
| **blueman** (`services.blueman`) | 启用 | 需在 `exec-once` 启动 `blueman-applet` 才有托盘 |
| **1Password GUI** (`programs._1password-gui`) | 启用，polkit 授权 zhaochanglong | 已自启（desktop 文件），无需 `exec-once` |
| **NetworkManager** | 启用 | 可选 `nm-applet` 托盘 |
| **PipeWire** + `rtkit` | 启用 | 音频已就绪 |
| **polkit-kde-agent** | 未显式启用 | Hyprland 会话需手动启动 `polkit-kde-authentication-agent-1` |
| **ghostty** | 启用（`programs.ghostty`） | 当前 hyprland 配置中 `terminal = "ghotty"` 是拼写错误 |
| **kitty** | 已配置（`nixos/home/kitty.nix`） | 作为备用终端 |
| **AMD GPU** | `amdgpu` 内核模块 + `hardware.graphics` + ROCm | 硬件层已就绪，仅需 `env` 补充 |
| **zen 内核 + btrfs + lanzaboote** | 安全启动已启用 | 不影响 Hyprland |
| **power-profiles-daemon + thermald** | 启用 | 不影响 Hyprland |
| **UWSM** (`withUWSM = true`) | Hyprland 通过 UWSM 启动 | `exec-once` 应使用 `systemctl --user start` 或 UWSM 推荐 WAY（`uwsm app -- ...`）以获得 systemd 单元管理 |

### 当前问题

1. **拼写错误**：`terminal = "ghotty"` 应为 `ghostty`
2. **`hyprlauncher` 未安装**：`menu = "hyprlauncher"` 但系统包未声明，建议改用 `wofi` 或 `fuzzel`（轻量、Wayland 原生）
3. **缺少 `exec-once`**：无 polkit-agent、blueman-applet、fcitx5、wallpaperengine 启动项
4. **显示器配置不具体**：`monitor = [ ",preferred,auto,auto" ]` 未指定 `DP-3`（已知主显示器名）
5. **锁屏方案缺失**：Plasma 锁屏在 Hyprland 下不生效，需要 `hyprlock` + `hypridle`
6. **环境变量不足**：`env` 仅 `XCURSOR_SIZE` / `HYPRCURSOR_SIZE`，缺 QT/GTK/XDG/IME/AMD 相关
7. **窗口规则单薄**：仅 3 条 `windowrulev2`
8. **Logo 未禁用**：`disable_hyprland_logo = false` 通常应设为 `true`
9. **无 submap**：缺少 resize 子模式
10. **`linux-wallpaperengine` 未在 Hyprland 下显式启动**：可能依赖 systemd 用户服务，但建议在 `exec-once` 中冗余拉起
11. **截图/录屏工具未安装**：缺少 `grim` / `slurp` / `wl-clipboard` / `wf-recorder`
12. **无状态栏**：Plasma panel 不在 Hyprland 会话中运行，需要 `waybar` 或替代

### 目标结构

将单文件拆分为模块化结构：

```text
nixos/home/hyprland/
├── default.nix      # 主入口，import 各子模块
├── settings.nix     # 核心设置：general / decoration / animations / input / misc / dwindle / master
├── bindings.nix     # bind / binde / bindm / bindl + submap（resize 等）
├── rules.nix        # windowrulev2 + layerrule
├── exec.nix         # exec-once 自启项
├── env.nix          # env 环境变量
└── components.nix   # 配套组件：hyprlock / hypridle / waybar（不启用 hyprpaper）
```

### 配套组件选型（基于现有环境修订）

| 组件 | 用途 | 选型 | 备注 |
|------|------|------|------|
| 状态栏 | panel / tray | `waybar` | 生态成熟；提供模块化配置 |
| 壁纸 | wallpaper | **保留 `linux-wallpaperengine`** | 已在 `zhaochanglong.nix` 中配置，不重复引入 `hyprpaper` |
| 锁屏 | lock screen | `hyprlock` | 替代 Plasma kscreenlocker（Hyprland 会话下不生效） |
| 空闲 | idle management | `hypridle` | 配合 `hyprlock`；登录会话后才生效，不影响 SDDM |
| 启动器 | launcher | `fuzzel`（推荐）或 `wofi` | 轻量、Wayland 原生；`hyprlauncher` 上游不活跃 |
| 通知 | notification | `mako` | Wayland 原生，配置简单 |
| 截图 | screenshot | `grim` + `slurp` + `wl-clipboard` | 标准组合 |
| 录屏 | screen record | `wf-recorder` | OBS 太重，日常用 wf-recorder 足够；Sunshine 已有 OBS |
| Polkit | 权限弹窗 | `polkit-kde-agent` | 与 Plasma 共存，复用 KDE 风格 |

### `exec-once` 启动项规划（考虑 UWSM）

由于系统级启用了 `withUWSM = true`，推荐使用 `uwsm app --` 启动图形应用，让 systemd 接管生命周期：

```text
# 状态栏与通知
uwsm app -- waybar
uwsm app -- mako

# 锁屏与空闲
uwsm app -- hypridle

# 权限代理（KDE 风格，与 Plasma 共存）
uwsm app -- ${pkgs.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1

# 蓝牙托盘（系统服务已启用 blueman）
uwsm app -- blueman-applet

# 输入法（系统级 fcitx5 已启用，此处冗余拉起确保会话内激活）
uwsm app -- fcitx5 -d --replace

# 壁纸（已有 systemd 用户服务，按需冗余）
# uwsm app -- linux-wallpaperengine
```

### `env` 环境变量规划

```text
# 光标
XCURSOR_SIZE,24
HYPRCURSOR_SIZE,24

# Qt / GTK
QT_QPA_PLATFORM,wayland;xcb
QT_QPA_PLATFORMTHEME,qt6ct  # 与 Plasma6 对齐
QT_WAYLAND_DISABLE_WINDOWDECORATION,1

# XDG
XDG_CURRENT_DESKTOP,Hyprland
XDG_SESSION_TYPE,wayland
XDG_SESSION_DESKTOP,Hyprland

# SDL / Java
SDL_VIDEODRIVER,wayland
_JAVA_AWT_WM_NONREPARENTING,1

# AMD 显卡（硬件层已就绪）
LIBVA_DRIVER_NAME,radeonsi
VDPAU_DRIVER,radeonsi

# 输入法（与 Plasma 会话保持一致）
GTK_IM_MODULE,fcitx
QT_IM_MODULE,fcitx
XMODIFIERS,@im=fcitx
```

注意：`nixos/default.nix` 中已用 `lib.mkForce ""` 强制清空 `GTK_IM_MODULE` / `QT_IM_MODULE`，这是为了 fcitx5 用 Wayland 输入协议（而非 GTK/Qt IM 模块）。Hyprland `env` 中应保持一致，**不要重新设置这两个变量**，只设 `XMODIFIERS`。

### 窗口规则规划

补充 `windowrulev2`：

```text
# Polkit 弹窗浮动居中
float, class:^(org.kde.polkit-kde-authentication-agent-1)$
center, class:^(org.kde.polkit-kde-authentication-agent-1)$

# 文件选择器浮动
float, title:^(Open Files)$
float, title:^(File Upload)$
float, title:^(Save File)$

# 常见工具浮动
float, class:^(org.pulseaudio.pavucontrol)$
float, class:^(.blueman-manager-wrapped)$
float, class:^(nm-connection-editor)$

# 1Password 浮动 + pin（可选）
float, class:^(1password)$
# pin, class:^(1password)$

# Steam 浮动子窗口
float, class:^(steam)$, title:^(?!Steam$)

# 浏览器对话框
float, class:^(firefox)$, title:^(?!Mozilla Firefox$)

# XWayland 拖拽修复（保留）
nofocus, xwayland:1, class:^$, title:^$

# 阻止最大化（保留）
nomaximizerequest, class:.*

# hyprland-run 定位（保留）
move 20 monitor_h-120, float, class:hyprland-run
```

### 按键绑定规划

保留现有绑定，补充：

- **Resize submap**：`SUPER+SHIFT+R` 进入（避开 `SUPER+R` 启动器）
  - `h/l` 左右调整宽度
  - `k/j` 上下调整高度
  - `ESC` / `SUPER+SHIFT+R` 退出
- **截图**：
  - `SUPER+SHIFT+S` → `grim -g "$(slurp)" - | wl-copy`（截图到剪贴板）
  - `SUPER+SHIFT+P` → 保存到 `~/Pictures/Screenshots/$(date +%Y%m%d-%H%M%S).png`（截图到文件）
- **屏幕录制**：`SUPER+SHIFT+V` → `wf-recorder -g "$(slurp)" -f ~/Videos/recordings/$(date +%Y%m%d-%H%M%S).mp4`
- **锁屏**：`SUPER+L` → `hyprlock`
- **空闲切换**：`SUPER+SHIFT+L` → `hyprctl dispatch dpms off`（关屏不锁）
- **启动器**：`SUPER+R` → `fuzzel`（替代 hyprlauncher）

### 显示器配置规划

已知主显示器 `DP-3`（来自 `linux-wallpaperengine` 配置），但具体分辨率/刷新率未知。建议：

1. **短期**：保留 `preferred,auto,auto`，添加注释提示用 `hyprctl monitors` 查询
2. **长期**：用户运行 `hyprctl monitors` 后，将输出贴入，写入具体配置：
   ```text
   monitor=DP-3,<width>x<height>@<rate>,0x0,1
   # 若有副屏：
   # monitor=HDMI-A-1,1920x1080@60,<DP-3 width>x0,1
   ```

### AMD 显卡适配

硬件层（`amdgpu` 驱动、`hardware.graphics` + ROCm）已在 [`nixos/hardware-configuration.nix`](nixos/hardware-configuration.nix) 中完成，Hyprland 侧只需：

- 在 `env.nix` 追加 `LIBVA_DRIVER_NAME=radeonsi` / `VDPAU_DRIVER=radeonsi`（已在上文 `env` 规划中）
- **Tearing**：AMD 在 Hyprland 下偶有撕裂，可设 `general:allow_tearing = false` + `vfr = true`，或在需要时启用 `allow_tearing`（注意 VRR 兼容性）
- **GLES 渲染**：若遇到媒体播放蓝屏问题，可强制走 GLES（参见近期 commit `d788ca9`）

### 实施步骤

1. **阶段 1：修复与拆分**
   - 修复 `ghostty` 拼写
   - 把 `menu` 从 `hyprlauncher` 改为 `fuzzel`（或确认是否要安装 hyprlauncher）
   - 将单文件拆分为 `settings.nix` / `bindings.nix` / `rules.nix` / `exec.nix` / `env.nix`
   - `disable_hyprland_logo = true`
   - 补充基础 `env`（含 AMD 变量）与 `windowrulev2`
   - `monitor` 显式写 `DP-3`（待用户提供分辨率）

2. **阶段 2：配套组件**
   - 启用 `hyprlock` + `hypridle`（home-manager 模块）
   - 启用 `waybar`，提供基础配置（含 tray for blueman / nm-applet / 1password）
   - 启用 `mako` 通知
   - 安装 `fuzzel` / `grim` / `slurp` / `wl-clipboard` / `wf-recorder`
   - `exec-once` 中用 `uwsm app --` 拉起上述组件 + polkit-kde-agent + fcitx5 + blueman-applet

3. **阶段 3：绑定与规则完善**
   - 添加 resize submap（`SUPER+SHIFT+R`）
   - 添加截图 / 录屏 / 锁屏绑定
   - 按实际使用习惯补充 `windowrulev2`

4. **阶段 4：验证与微调**
   - `nix eval .#nixos` 检查语法
   - `sudo nixos-rebuild switch --flake .#nixos`
   - 从 SDDM 选择 Hyprland 会话登录测试
   - 验证 `linux-wallpaperengine` 壁纸显示
   - 验证 fcitx5 在 Hyprland 下可用
   - 验证 hyprlock 锁屏（`SUPER+L`）
   - 验证截图快捷键

### 待用户确认事项

在进入实施前，需要用户确认以下选项：

- [ ] 启动器：`fuzzel`（推荐）/ `wofi` / `hyprlauncher` / `rofi-wayland`
- [ ] 通知：`mako`（推荐）/ `dunst` / `swaync` / 不需要
- [ ] 显示器配置：请运行 `hyprctl monitors` 并贴出输出，以便写入具体 `monitor=DP-3,...`
- [ ] 主题偏好（影响 waybar 配色与窗口边框色）：Catppuccin / Tokyo Night / Breeze / 自定义
- [ ] 是否需要 submap（resize / move 等）
- [ ] 是否需要 `nm-applet` 托盘（NetworkManager 已启用，但 Plasma 会话用 applet，Hyprland 需要单独启动）
