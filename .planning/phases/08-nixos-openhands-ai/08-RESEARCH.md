# Phase 8: 使用 Podman 容器部署 OpenHands AI 编程助手 - Research

**Researched:** 2026-03-20
**Updated:** 2026-03-20
**Domain:** NixOS、Podman、OpenHands 部署
**Confidence:** HIGH

## Summary

OpenHands 是一个开源 AI 编程助手，采用客户端 - 服务器架构。主应用（端口 3000）提供 Web UI 和 REST API，并需要容器运行时来创建沙箱容器执行代码。

**本研究采用最终架构：** 在 NixOS 宿主机上直接使用 Podman 运行 OpenHands 容器，通过 podman-compose 编排，systemd 服务管理生命周期，sops-nix 加密存储 LLM API 密钥。

Podman 是无守护进程的容器引擎，支持 rootless 模式，与 Docker CLI 完全兼容。在 NixOS 上通过声明式配置集成，是 Docker 的理想替代品。

**Primary recommendation:** 宿主机直接运行 Podman 容器是最简单且实用的方案。

## User Constraints (from CONTEXT.md)

### Locked Decisions

| Decision | Rationale |
|----------|-----------|
| **宿主机直接运行** | 无需 nixos-container 嵌套，简化架构 |
| **Podman** | 无守护进程，rootless，NixOS 原生支持 |
| **podman-compose** | Docker Compose 替代品，声明式编排 |
| **用户级数据路径** | `/home/zhaochanglong/.openhands` 方便访问 |

### Requirements

| Req ID | Description |
|--------|-------------|
| OH-01 | OpenHands 服务运行 |
| OH-02 | Web UI 在端口 3000 可访问 |
| OH-03 | LLM API 密钥通过 sops 加密存储 |
| OH-04 | 数据持久化配置正确 |
| OH-05 | 开机自启 |

## Standard Stack

### Core
| Library/Tool | Version | Purpose | Why Standard |
|--------------|---------|---------|--------------|
| Podman | 5.x | 容器运行时 | NixOS 官方支持，无守护进程 |
| podman-compose | 2.x | 容器编排 | Docker Compose 替代 |
| NixOS virtualisation.podman | 25.05+ | NixOS Podman 集成 | 声明式安装 |

### Supporting
| Library/Tool | Version | Purpose | When to Use |
|--------------|---------|---------|-------------|
| systemd | 256+ | 服务管理 | 开机自启和日志 |
| NixOS sops | 3.x | 密钥管理 | LLM API 密钥加密 |
| NixOS firewall | 25.05+ | 端口访问 | 开放 3000 端口 |

### Installation

```nix
# nixos/packages/default.nix
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    podman
    podman-compose
  ];
}

# nixos/default.nix
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];

  users.users.zhaochanglong.extraGroups = [ "wheel" "networkmanager" "video" ];
}
```

## Architecture Patterns

### Recommended Project Structure

```
nixos/
├── default.nix              # virtualisation.podman
├── packages/
│   └── default.nix          # podman, podman-compose
├── openhands/
│   ├── default.nix          # systemd 服务
│   └── podman-compose.yml   # 容器编排
├── sops.nix                 # 密钥加密
└── home/
    └── zhaochanglong.nix    # 用户配置
```

### Pattern 1: systemd 服务管理

```nix
# nixos/openhands/default.nix
{ config, pkgs, ... }:
{
  systemd.services.openhands = {
    description = "OpenHands AI Programming Assistant";
    wantedBy = [ "multi-user.target" ];
    after = [ "podman.service" ];
    requires = [ "podman.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "zhaochanglong";
      WorkingDirectory = "/home/zhaochanglong/.openhands";
      ExecStart = "${pkgs.podman-compose}/bin/podman-compose -f /home/zhaochanglong/.openhands/podman-compose.yml up -d";
      ExecStop = "${pkgs.podman-compose}/bin/podman-compose -f /home/zhaochanglong/.openhands/podman-compose.yml down";
    };
  };
}
```

### Pattern 2: podman-compose 编排

```yaml
# /home/zhaochanglong/.openhands/podman-compose.yml
services:
  openhands:
    image: ghcr.io/openhands/openhands:latest
    container_name: openhands-app
    ports:
      - "3000:3000"
    volumes:
      - /var/run/podman/podman.sock:/var/run/docker.sock
      - /home/zhaochanglong/.openhands/data:/.openhands
      - /home/zhaochanglong/.openhands/workspace:/opt/workspace_base
    environment:
      - LLM_API_KEY=${LLM_API_KEY}
      - LLM_MODEL=claude-sonnet-4-5-20250929
    restart: unless-stopped
```

### Pattern 3: SOPS 密钥管理

```nix
# nixos/sops.nix
{
  sops.secrets.openhands_llm_api_key = {
    file = "/home/zhaochanglong/.openhands/.env";
    format = "env";
    sopsFile = ./secrets/openhands.yaml;
  };
}
```

## Common Pitfalls

### Pitfall 1: Podman socket 权限

**Problem:** OpenHands 容器无法连接 Podman socket

**Solution:**
```nix
# 启用 Docker 兼容层
virtualisation.podman.dockerCompat = true;
# socket 路径：/var/run/podman/podman.sock
```

### Pitfall 2: 防火墙阻止访问

**Problem:** Web UI 无法从外部访问

**Solution:**
```nix
networking.firewall.allowedTCPPorts = [ 3000 ];
```

### Pitfall 3: 数据丢失

**Problem:** 容器重启后数据丢失

**Solution:**
```yaml
volumes:
  - /home/zhaochanglong/.openhands/data:/.openhands
```

### Pitfall 4: 服务启动顺序

**Problem:** OpenHands 启动时 Podman 未就绪

**Solution:**
```nix
systemd.services.openhands = {
  after = [ "podman.service" ];
  requires = [ "podman.service" ];
};
```

## Code Examples

### 完整 NixOS 配置

```nix
# nixos/default.nix
{ config, pkgs, ... }:
{
  imports = [ ./packages/default.nix ./openhands/default.nix ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];

  users.users.zhaochanglong.extraGroups = [ "wheel" "networkmanager" "video" ];
}
```

```nix
# nixos/openhands/default.nix
{ config, pkgs, ... }:
{
  systemd.services.openhands = {
    description = "OpenHands AI Programming Assistant";
    wantedBy = [ "multi-user.target" ];
    after = [ "podman.service" ];
    requires = [ "podman.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "zhaochanglong";
      WorkingDirectory = "/home/zhaochanglong/.openhands";
      ExecStart = "${pkgs.podman-compose}/bin/podman-compose up -d";
      ExecStop = "${pkgs.podman-compose}/bin/podman-compose down";
    };
  };
}
```

## Validation Architecture

| Req ID | Test Command |
|--------|--------------|
| OH-01 | `systemctl is-active openhands` |
| OH-02 | `curl -s http://localhost:3000` |
| OH-03 | `podman exec openhands env \| grep LLM` |
| OH-04 | `ls -la ~/.openhands/data` |
| OH-05 | `systemctl list-dependencies multi-user.target \| grep openhands` |

## Sources

- [NixOS Podman Module](https://search.nixos.org/options?channel=unstable&show=virtualisation.podman)
- [Podman Documentation](https://podman.io/docs)
- [OpenHands Docker Compose](https://github.com/All-Hands-AI/OpenHands/blob/main/docker-compose.yml)

**Confidence:** HIGH - 基于官方文档和标准实践
**Research date:** 2026-03-20
