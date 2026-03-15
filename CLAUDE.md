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

1. **安装软件** → 修改 `packages/default.nix` 或 `home.packages`
2. **系统配置** → 修改对应的 `configuration.nix` 或模块文件
3. **用户环境** → 修改 `home/` 目录下的 home-manager 配置
4. **添加服务** → 修改 `systemd` 或 `launchd` 相关 Nix 模块

### 应用更改

修改配置后，使用以下命令应用更改：

```bash
# NixOS
sudo nixos-rebuild switch --flake .#nixos

# Darwin
darwin-rebuild switch --flake .#darwin

# 仅更新 home-manager (如果独立使用)
home-manager switch --flake .
```

## 项目结构

```
.
├── flake.nix           # Flake 入口
├── nixos/              # NixOS 配置
│   ├── default.nix     # 系统配置入口
│   ├── packages/       # NixOS 系统级包
│   └── home/           # home-manager 配置
├── darwin/             # macOS Darwin 配置
│   ├── default.nix     # 系统配置入口
│   ├── packages/       # Darwin 系统级包
│   └── home/           # home-manager 配置
└── shared/             # 跨平台共享配置
    ├── home/           # 共享的 home-manager 配置
    └── system/         # 共享的系统配置
```

## 工作流程

1. **修改配置文件** → 编辑对应的 `.nix` 文件
2. **检查语法** → `nix eval .#nixos` 或 `nix eval .#darwin`
3. **应用更改** → `nixos-rebuild switch` 或 `darwin-rebuild switch`
4. **提交更改** → `git commit`

## 语言

使用中文与用户对话。

---
*创建于 2026-03-15*