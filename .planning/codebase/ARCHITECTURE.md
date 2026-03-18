# 架构

## 概述

本项目采用 **模块化声明式架构**，通过 Nix Flakes 统一管理 macOS 和 NixOS 两个平台的系统配置。

## 架构模式

### Flake 输出模式

```
flake.nix (入口)
    │
    ├── nixosConfigurations."nixos"
    │       └── ./nixos (模块入口)
    │
    └── darwinConfigurations."zhaochanglongdeMacBook-Air"
            └── ./darwin (模块入口)
```

### 模块层次结构

```
                    ┌─────────────┐
                    │  flake.nix  │ (入口点)
                    └──────┬──────┘
                           │
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
    ┌──────────┐    ┌───────────┐    ┌──────────┐
    │  nixos/  │    │  darwin/  │    │ shared/  │
    │ (Linux)  │    │  (macOS)  │    │ (跨平台) │
    └────┬─────┘    └─────┬─────┘    └────┬─────┘
         │                │               │
         │    ┌───────────┴───────────┐   │
         │    │                       │   │
         ▼    ▼                       ▼   ▼
    ┌─────────────────────────────────────┐
    │           home-manager              │
    │        (用户级配置管理)               │
    └─────────────────────────────────────┘
```

## 核心抽象层

### 1. 系统配置层

**NixOS (`nixos/default.nix`)**:
- 硬件配置导入
- 网络配置
- 桌面环境 (Plasma 6)
- 服务配置
- 用户管理

**Darwin (`darwin/default.nix`)**:
- macOS 系统默认设置
- 用户配置
- PAM/TouchID 配置

### 2. 共享配置层 (`shared/`)

**目的**: 减少重复，确保一致性

- `shared/home/` - 跨平台用户配置
  - Git, Zsh, Tmux, SSH
  - Direnv, MCP, Claude Code
- `shared/system/` - 跨平台系统配置
  - Sops 密钥管理
- `shared/secrets/` - 加密密钥存储

### 3. 用户配置层 (home-manager)

**架构特点**:
- 使用 `useGlobalPkgs = true` 统一包源
- `extraSpecialArgs` 传递 inputs/self
- 每个用户独立的配置入口

**NixOS 用户配置** (`nixos/home/zhaochanglong.nix`):
```nix
imports = [
  "${self}/shared/home"      # 共享配置
  inputs.plasma-manager      # Plasma 桌面
  ./nixvim                   # Neovim 配置
  # ... 其他模块
];
```

**Darwin 用户配置** (`darwin/home/zhaochanglong.nix`):
```nix
imports = [
  "${self}/shared/home"      # 共享配置
  ./git.nix
  ./ssh.nix
];
```

## 数据流

### 配置构建流程

```
1. flake.nix 解析
        ↓
2. 收集 inputs (nixpkgs, home-manager, etc.)
        ↓
3. 构建系统配置 (nixosConfigurations / darwinConfigurations)
        ↓
4. 导入模块树
        ↓
5. home-manager 模块合并
        ↓
6. 生成系统配置
        ↓
7. 应用配置 (nixos-rebuild / darwin-rebuild)
```

### 密钥管理流程

```
sops.yaml (配置)
     ↓
secrets/*.yaml (加密)
     ↓
sops-nix 模块
     ↓
构建时解密
     ↓
环境变量注入 / 文件放置
```

## 入口点

| 入口文件 | 系统触发命令 |
|----------|--------------|
| `flake.nix` | `nix eval`, `nix build` |
| `nixos/default.nix` | `nixos-rebuild switch --flake .#nixos` |
| `darwin/default.nix` | `darwin-rebuild switch --flake .#darwin` |

## 特殊模块

### NixVim 配置系统

```
nixos/home/nixvim/
├── default.nix      # 入口
├── base.nix         # 基础配置
├── colorscheme.nix  # 主题
├── options.nix      # 选项
├── clipboard.nix    # 剪贴板
├── extra-plugins.nix
├── plugins/         # 插件配置
└── keymaps/         # 键盘映射
```

### MicroVM 配置

```
nixos/microvm/
├── default.nix      # 入口
└── openclaw.nix     # OpenClaw AI 虚拟机
```

## 设计原则

1. **声明式优先**: 所有配置通过 Nix 表达
2. **模块化**: 按功能划分独立模块
3. **DRY**: 通过 `shared/` 减少重复
4. **关注点分离**: 系统/用户/应用配置分离
5. **密钥安全**: 敏感信息通过 sops 加密