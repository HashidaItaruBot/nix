# 测试

## 概述

本项目是一个 Nix 系统配置仓库，**没有传统的测试套件**。

## 配置验证方式

### 语法检查

```bash
# 评估配置语法
nix eval .#nixos
nix eval .#darwin
```

### 构建测试

```bash
# 构建 NixOS 配置 (不应用)
nix build .#nixosConfigurations.nixos.config.system.build.toplevel

# 构建 Darwin 配置
nix build .#darwinConfigurations.zhaochanglongdeMacBook-Air.config.system.build.toplevel
```

### 静态分析

```bash
# 使用 statix 检查 Nix 代码
statix check .

# 使用 deadnix 检查死代码
deadnix .
```

### 格式化检查

```bash
# 使用 alejandra 格式化
alejandra --check .

# 或使用 flake formatter
nix fmt -- --check
```

## 验证流程

### 应用前验证

1. **修改配置文件**
2. **检查语法**: `nix eval .#nixos`
3. **格式化代码**: `nix fmt`
4. **应用更改**: `nixos-rebuild switch --flake .#nixos`

### CI/CD

项目使用 GitHub Actions，配置在 `.github/` 目录。

## 替代测试策略

### 虚拟机测试

对于重大更改，可以先在虚拟机中测试：

```bash
# 使用 MicroVM 测试
# 参见 nixos/microvm/ 目录
```

### 配置回滚

NixOS 支持原子回滚：

```bash
# 列出可用配置
nixos-rebuild list-generations

# 回滚到上一版本
nixos-rebuild switch --rollback
```

### Darwin 回滚

```bash
# 查看历史配置
darwin-rebuild --list-generations

# 回滚
darwin-rebuild switch --rollback
```

## 监控和诊断

### 系统状态

```bash
# NixOS
systemctl status home-manager-zhaochanglong.service

# 检查 Nix store
nix store verify --all
```

### 配置差异

```bash
# 查看配置差异
nixos-rebuild switch --flake .#nixos 2>&1 | grep -A 20 "activating"
```

## 推荐的验证工作流

```
修改配置 → 格式化 (nix fmt) → 静态分析 (statix) → 评估 (nix eval) → 应用
```

## 注意事项

- 配置错误可能导致系统不可用
- 建议在虚拟机或测试环境中验证重大更改
- 使用 Git 跟踪所有配置更改
- 应用前确保理解更改内容