# 代码约定

## 概述

本项目遵循 Nix 生态系统的最佳实践，强调声明式配置和模块化设计。

## Nix 代码风格

### 格式化工具

- 使用 **alejandra** 作为格式化工具
- 配置: `formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;`

### 模块结构模式

#### 标准模块模式

```nix
{ pkgs, ... }: {
  # 导入其他模块
  imports = [ ./other-module.nix ];

  # 配置选项
  environment.systemPackages = with pkgs; [
    package1
    package2
  ];

  # 服务启用
  services.example.enable = true;
}
```

#### 带 inputs 的模块模式

```nix
{ self, inputs, config, ... }: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.username = import ./username.nix;
        extraSpecialArgs = { inherit inputs self; };
      };
    }
  ];
}
```

### 函数参数模式

```nix
# 最小参数
{ pkgs, ... }: { ... }

# 标准参数
{ config, lib, pkgs, ... }: { ... }

# 带 inputs
{ self, inputs, config, ... }: { ... }
```

## 命名约定

### 变量命名

- 使用 `camelCase` 命名变量和选项
- 使用 `lower_case` 命名文件和目录

### 选项命名

```nix
# 服务启用
services.example.enable = true;

# 包列表
environment.systemPackages = with pkgs; [ ... ];

# 用户配置
users.users.username = { ... };
```

## 组织模式

### Imports 组织

```nix
imports = [
  # 外部模块
  inputs.home-manager.nixosModules.home-manager

  # 共享模块
  "${self}/shared/home"

  # 本地模块 (按功能分组)
  ./git.nix
  ./ssh.nix
];
```

### 包组织

```nix
environment.systemPackages = with pkgs; [
  # 按功能分组注释

  # Core tools
  vim
  git

  # Development
  gcc
  nodejs
];
```

## 最佳实践

### 1. 避免命令式操作

```nix
# 正确 ✓ - 声明式
environment.systemPackages = [ pkgs.vim ];

# 错误 ✗ - 不应使用
# nix-env -i vim
```

### 2. 使用 with pkgs 简化

```nix
# 推荐
environment.systemPackages = with pkgs; [
  vim
  git
  htop
];

# 不推荐
environment.systemPackages = [
  pkgs.vim
  pkgs.git
  pkgs.htop
];
```

### 3. 密钥管理

```nix
# 使用 sops-nix 管理敏感信息
sops.secrets.api_key = {
  sopsFile = "${self}/shared/secrets/api_keys.yaml";
  owner = "root";
  mode = "0400";
};
```

### 4. 跨平台共享

```nix
# 在特定平台导入共享配置
imports = [ "${self}/shared/home" ];
```

### 5. 条件配置

```nix
# 使用 lib.mkForce 覆盖
GTK_IM_MODULE = lib.mkForce "";

# 使用 lib.mkIf 条件启用
# lib.mkIf config.services.xserver.enable { ... }
```

## 注释风格

### 中文注释

项目使用中文注释说明配置用途：

```nix
services.thermald.enable = true; # 启用温度管理
powerManagement.cpuFreqGovernor = "performance"; # 强制 CPU 模式为高性能
```

### 分组注释

```nix
environment.systemPackages = with pkgs; [
  # Core tools
  vim
  git

  # Development
  gcc
  nodejs
];
```

## 文件组织原则

1. **按功能分组**: 相关配置放在同一文件
2. **层次清晰**: 系统 → 用户 → 应用
3. **共享优先**: 跨平台配置放 `shared/`
4. **平台特定**: 只在 `nixos/` 或 `darwin/` 中放平台独有配置

## Home Manager 约定

```nix
home-manager = {
  useGlobalPkgs = true;      # 使用系统 nixpkgs
  useUserPackages = true;    # 用户包管理
  users.username = import ./username.nix;
  extraSpecialArgs = { inherit inputs self; };
  backupFileExtension = "bak";
};
```

## 禁止的操作

根据 `CLAUDE.md` 规定：

```bash
# 禁止
nix profile install
nix-env -i
nix-collect-garbage -d  # 除非明确要求
```

所有软件安装必须通过修改 Nix 配置文件完成。