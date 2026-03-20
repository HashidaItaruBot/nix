# NixOS 容器使用指南

## 已启用配置

NixOS 原生容器支持已通过以下配置启用：

```nix
virtualisation = {
  containers.enable = true;
};
```

用户已添加到 `containers` 组，无需 root 权限即可管理容器。

## 应用配置

```bash
sudo nixos-rebuild switch --flake .#nixos
```

## 容器管理命令

### 创建容器

```bash
# 创建名为 web 的容器
sudo nix-container create web

# 创建带有配置的容器（声明式）
sudo nix-container create mycontainer --config '
{ config, pkgs, ... }: {
  networking.hostName = "mycontainer";
  environment.systemPackages = [ pkgs.vim pkgs.git ];
  services.sshd.enable = true;
}'
```

### 启动/停止容器

```bash
sudo nix-container start web
sudo nix-container stop web
sudo nix-container restart web
```

### 查看容器状态

```bash
sudo nix-container list
```

### 进入容器

```bash
# 登录到容器
sudo nix-container login web

# 或在容器中执行命令
sudo nix-container exec web -- ls -la /
```

### 复制文件

```bash
# 主机 -> 容器
sudo nix-container copy-in web ./local-file /container/path/

# 容器 -> 主机
sudo nix-container copy-out web /container/file ./local-path
```

### 删除容器

```bash
sudo nix-container stop web
sudo nix-container destroy web
```

## 声明式容器配置（推荐）

在 `nixos/default.nix` 中添加：

```nix
containers.containers.myweb = {
  autoStart = true;
  config = { config, pkgs, ... }: {
    networking.hostName = "myweb";
    services.nginx.enable = true;
    environment.systemPackages = [ pkgs.nginx ];
  };
};
```

然后运行 `sudo nixos-rebuild switch --flake .#nixos` 自动创建并启动容器。

## 容器特点

| 特性 | 说明 |
|------|------|
| 隔离性 | 使用 Linux namespace 和 cgroups |
| 性能 | 近乎原生性能，无虚拟化开销 |
| 声明式 | 容器配置可纳入 Nix 管理 |
| 轻量 | 共享主机内核，占用资源少 |
| 安全 | 可选特权/非特权模式 |

## 与 Docker 对比

| 方面 | NixOS Containers | Docker |
|------|-----------------|--------|
| 配置方式 | 声明式 Nix | 命令式/Compose |
| 镜像管理 | Nix 包 | Docker 镜像 |
| 适用场景 | 系统服务 | 应用容器 |
| 学习曲线 | 需了解 Nix | 生态成熟 |

## 学习资源

- [NixOS 官方文档 - Containers](https://nixos.org/manual/nixos/stable/#ch-containers)
- [nix-container 手册页](https://nixos.org/manual/nixos/stable/#man-nix-container)
