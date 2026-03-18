# 技术栈

## 概述

这是一个 **macOS + NixOS 混合** 的声明式系统配置项目，使用 Nix Flakes 进行统一管理。

## 核心技术

### Nix 生态系统

| 组件 | 版本/来源 | 用途 |
|------|----------|------|
| **Nix Flakes** | experimental-features | 声明式包管理和配置 |
| **Lix** | stable (替代 CppNix) | 现代 Nix 实现 |
| **nixpkgs** | nixpkgs-unstable | 软件包源 |
| **alejandra** | - | Nix 代码格式化 |

### 系统配置框架

| 框架 | 平台 | 用途 |
|------|------|------|
| **nix-darwin** | macOS | macOS 系统配置管理 |
| **home-manager** | 跨平台 | 用户级配置管理 |
| **plasma-manager** | NixOS | KDE Plasma 桌面配置 |
| **nixvim** | 跨平台 | Neovim 配置管理 |

### 安全与密钥管理

| 工具 | 用途 |
|------|------|
| **sops-nix** | 加密密钥管理 |
| **ssh-to-age** | SSH 密钥转 AGE 密钥 |
| **1Password** | 密码管理器集成 |

### 虚拟化

| 工具 | 用途 |
|------|------|
| **microvm.nix** | 轻量级虚拟机 |
| **Waydroid** | Android 容器 |
| **QEMU** | 系统虚拟化 |

### 启动安全

| 工具 | 用途 |
|------|------|
| **lanzaboote** | SecureBoot 支持 |

## 输入依赖 (flake.nix)

```nix
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  nix-darwin.url = "github:nix-darwin/nix-darwin";
  nixvim.url = "github:nix-community/nixvim";
  home-manager.url = "github:nix-community/home-manager";
  lanzaboote.url = "github:nix-community/lanzaboote/v1.0.0";
  sops-nix.url = "github:Mic92/sops-nix";
  nix-flatpak.url = "github:gmodena/nix-flatpak";
  plasma-manager.url = "github:nix-community/plasma-manager";
  microvm.url = "github:microvm-nix/microvm.nix";
  nix-openclaw.url = "github:openclaw/nix-openclaw";
};
```

## 输出配置

### NixOS 配置

- **系统**: `x86_64-linux`
- **配置名**: `nixos`
- **入口模块**: `./nixos`

### Darwin 配置

- **系统**: `aarch64-darwin`
- **配置名**: `zhaochanglongdeMacBook-Air`
- **入口模块**: `./darwin`

## 开发工具

### NixOS 系统级工具

- `nixd`, `nil` - Nix LSP
- `statix` - Nix 静态分析
- `alejandra` - Nix 格式化
- `nom` - Nix 输出监控

### 编程语言环境

- Node.js + pnpm
- GCC + Clang + CMake
- Python (Jupyter)

## 桌面环境

### NixOS

- **桌面**: KDE Plasma 6
- **显示管理器**: SDDM
- **音频**: PipeWire
- **输入法**: Fcitx5 + Rime

### macOS

- 通过 Homebrew 管理桌面应用
- Dock/Finder 系统配置

## 包管理

### NixOS

- `environment.systemPackages` - 系统包
- `home.packages` - 用户包
- Flatpak 支持 (`nix-flatpak`)

### macOS

- Homebrew casks - GUI 应用
- `environment.systemPackages` - CLI 工具

## 字体配置

NixOS 配置了丰富的中文字体：

- Sarasa Gothic (更纱黑体)
- Noto CJK 系列
- Nerd Fonts (Fira Code, JetBrains Mono, Hack, Noto)