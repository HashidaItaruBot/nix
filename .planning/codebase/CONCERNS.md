# 关注点

## 概述

本文档记录项目中潜在的技术债务、已知问题和需要关注的领域。

## 技术债务

### 1. 重复的 Homebrew Cask

**位置**: `darwin/packages/default.nix`

**问题**: `zerotier-one` 和 `moonlight` 在 casks 列表中出现两次：

```nix
casks = [
  # ...
  "zerotier-one"
  # ...
  "zerotier-one"  # 重复
  "moonlight"
  # ...
  "moonlight"     # 重复
];
```

**影响**: 虽然不会导致错误，但降低可维护性。

**建议**: 删除重复项。

### 2. 硬编码的显示器配置

**位置**: `nixos/home/zhaochanglong.nix:28-31`

```nix
wallpapers = [
  {
    monitor = "DP-3";  # 硬编码显示器名称
    wallpaperId = "823335782";
  }
];
```

**问题**: 显示器名称 `DP-3` 是硬件相关的，更换显示器或连接方式后可能失效。

**建议**: 考虑使用更灵活的配置方式。

### 3. 未使用的变量

**位置**: 多个文件

部分模块导入了 `inputs` 参数但未完全使用。

## 安全关注点

### 1. 密钥权限

**位置**: `shared/system/sops.nix`

```nix
sops.secrets.mihomo_config = {
  mode = "0400";  # 只有 root 可读
  owner = "root";
};
```

部分密钥使用 `0444` 权限（全局可读）：

```nix
deepseek_api_key = {
  mode = "0444";  # 所有用户可读
};
```

**风险**: API 密钥对所有用户可见。

**建议**: 限制敏感密钥的访问权限。

### 2. 环境变量注入

**位置**: `shared/system/sops.nix:34-41`

通过 `environment.extraInit` 将密钥注入环境变量。

**风险**: 环境变量可能被日志或进程列表泄露。

### 3. SSH 公钥硬编码

**位置**: `nixos/default.nix:111-113`

```nix
openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP5M2RGhIG1CslAdzx+1xcOFiAgJhw0FKFqhe/Wkm1qZ"
];
```

**注意**: 这是公开的 SSH 公钥，不是私钥，安全性可接受。

## 配置复杂度

### 1. NixVim 配置分散

**位置**: `nixos/home/nixvim/`

NixVim 配拆分为多个文件，虽然模块化，但可能增加维护成本。

**现状**: 约 20+ 个插件配置文件。

### 2. 混合包管理

**问题**:
- NixOS: 使用 `nixpkgs` + `flatpak`
- macOS: 使用 `nixpkgs` + `homebrew`

**风险**: 包版本可能不一致，依赖管理复杂。

## 依赖风险

### 1. Flake Inputs 不稳定

使用 `nixpkgs-unstable` 作为主要包源：

```nix
nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
```

**风险**: 可能引入未经测试的更新。

**缓解**: 使用 `flake.lock` 锁定版本。

### 2. 外部 Input 依赖

依赖多个外部 flake inputs：
- nix-darwin
- home-manager
- nixvim
- lanzaboote
- sops-nix
- plasma-manager
- microvm
- nix-openclaw

**风险**: 上游变更可能破坏配置。

## 性能关注点

### 1. 系统重建时间

由于配置复杂度和大量插件，系统重建可能较慢。

**建议**: 使用 `nh` 工具加速。

### 2. Mihomo 代理

**位置**: `nixos/default.nix:49-55`

```nix
services.mihomo = {
  enable = false;  # 当前禁用
  tunMode = true;
};
```

**注意**: TUN 模式可能影响网络性能。

## 功能待完善

### 1. Darwin SSH 配置缺失

**位置**: `darwin/home/`

当前只有 `git.nix` 和 `ssh.nix`，缺少完整的用户配置。

### 2. 共享 secrets 路径

**位置**: `shared/secrets/`

secrets 文件需要手动管理，没有自动化同步机制。

### 3. 缺少 CI 验证

虽然有 `.github/` 目录，但缺少自动化的配置验证。

## 文档缺失

- 缺少每个模块的详细文档
- 缺少配置选项说明
- 缺少故障排除指南

## 改进建议优先级

| 优先级 | 问题 | 行动 |
|--------|------|------|
| 高 | 重复的 Homebrew casks | 立即修复 |
| 高 | 密钥权限过宽 | 审查并收紧 |
| 中 | 硬编码显示器配置 | 添加注释或参数化 |
| 中 | 依赖版本不稳定 | 定期更新 lock |
| 低 | 文档缺失 | 逐步完善 |