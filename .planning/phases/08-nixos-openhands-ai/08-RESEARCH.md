# Phase 8: 在 NixOS 容器内部署 OpenHands AI 编程助手 - Research

**Researched:** 2026-03-20
**Domain:** NixOS 容器部署、OpenHands AI 助手
**Confidence:** MEDIUM

## Summary

OpenHands 是一个开源 AI 编程助手，支持多种部署方式。本研究调查了在 NixOS 容器内部署 OpenHands 的技术方案。

OpenHands 采用客户端 - 服务器架构：主应用容器（端口 3000）提供 Web UI 和 REST API，并需要 Docker 守护进程来创建沙箱容器执行代码。部署核心配置包括 LLM API 密钥、工作区挂载、文件持久化存储。

NixOS 提供两种容器管理方式：声明式（`virtualisation.containers` 配置 OCI 容器运行时）和命令式（`nixos-container` 工具创建系统级容器）。本项目已启用 `virtualisation.containers.enable = true`，但需注意这是用于 Podman/Docker 等 OCI 容器的基础配置，而非直接运行应用容器的声明式服务定义。

**Primary recommendation:** 使用 Docker Compose 在 NixOS 上运行 OpenHands 容器，通过 systemd 服务实现开机自启，利用 NixOS 的声明式配置管理 Docker 安装和容器服务。

## User Constraints (from CONTEXT.md)

### Locked Decisions
*No CONTEXT.md exists for this phase yet.*

### Claude's Discretion
*To be determined during planning.*

### Deferred Ideas (OUT OF SCOPE)
*To be determined during planning.*

## Phase Requirements

*Requirements TBD during planning phase.*

## Standard Stack

### Core
| Library/Tool | Version | Purpose | Why Standard |
|--------------|---------|---------|--------------|
| Docker | 28.x | 容器运行时 | OpenHands 官方支持的唯一容器运行时 |
| Docker Compose | 2.x | 多容器编排 | OpenHands 提供官方 docker-compose.yml |
| NixOS virtualisation.docker | 25.05+ | NixOS Docker 集成 | 声明式安装和管理 Docker |

### Supporting
| Library/Tool | Version | Purpose | When to Use |
|--------------|---------|---------|-------------|
| systemd | 256+ | 服务管理和自启 | 容器开机自动启动 |
| NixOS sops | 3.x | 密钥管理 | 安全存储 LLM API 密钥（项目已启用 sops） |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Docker Compose | NixOS 声明式容器 | NixOS 容器功能有限，不支持复杂的 Docker 依赖关系 |
| Docker runtime | Podman | OpenHands 明确要求 Docker socket 访问 |
| systemd service | Docker native restart | systemd 提供更好的日志和依赖管理 |

**Installation:**

在 NixOS 中通过 flake 声明式安装：

```nix
# nixos/packages/default.nix
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}

# nixos/default.nix
{
  virtualisation.docker.enable = true;
  users.users.zhaochanglong.extraGroups = [ "docker" ];
}
```

**Version verification:**

```bash
nix shell nixpkgs#docker --command docker --version
nix shell nixpkgs#docker-compose --command docker-compose --version
```

## Architecture Patterns

### Recommended Project Structure

```
nixos/
├── default.nix              # 系统配置入口（已启用 virtualisation.containers）
├── packages/
│   └── default.nix          # 添加 docker-compose
├── openhands/
│   ├── default.nix          # OpenHands 服务配置
│   ├── docker-compose.yml   # OpenHands 容器编排
│   └── service.nix          # systemd 服务定义
└── home/
    └── zhaochanglong.nix    # 用户配置（添加 docker 组）
```

### Pattern 1: Docker Compose with systemd 管理

**What:** 使用 Docker Compose 定义容器，通过 systemd 服务管理生命周期

**When to use:** 需要复杂的容器配置、网络、卷挂载时

**Example:**

```nix
# nixos/openhands/service.nix
{ config, pkgs, ... }:
{
  systemd.services.openhands = {
    description = "OpenHands AI Assistant";
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" ];
    requires = [ "docker.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/var/lib/openhands";
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
    };

    environment = {
      LLM_API_KEY_FILE = "/var/lib/openhands/.env";
    };
  };
}
```

### Pattern 2: SOPS 密钥管理

**What:** 使用 sops-nix 加密存储 LLM API 密钥

**When to use:** 生产环境需要安全存储敏感配置

**Example:**

```nix
# nixos/sops.nix (已有配置)
{
  sops.secrets.openhands_llm_api_key.file = /var/lib/openhands/.env;
}
```

### Anti-Patterns to Avoid

- **不要直接在 configuration.nix 中硬编码 API 密钥** — 使用 sops 或 EnvironmentFile
- **不要使用 `docker run` 命令式启动** — 使用 systemd 声明式管理
- **不要将持久化数据放在容器内** — 必须挂载外部卷

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| 容器编排 | 手写 docker run 脚本 | Docker Compose | 官方支持、依赖管理、健康检查 |
| 密钥管理 | 明文 .env 文件 | sops-nix | 加密存储、版本控制安全 |
| 服务自启 | cron 或 rc.local | systemd | 标准化、日志聚合、依赖管理 |
| 日志管理 | 自定义日志脚本 | systemd journal | 集中化、结构化查询 |
| 网络配置 | 手动 iptables | Docker Compose networks | 声明式、可重现 |

**Key insight:** OpenHands 官方仅提供 Docker Compose 部署方案，自行实现会遗漏健康检查、网络隔离、沙箱配置等关键功能。

## Common Pitfalls

### Pitfall 1: Docker Socket 权限问题

**What goes wrong:** OpenHands 容器无法访问宿主 Docker 守护进程，无法创建沙箱容器

**Why it happens:** Docker socket (`/var/run/docker.sock`) 默认只允许 docker 组成员访问

**How to avoid:**
1. 确保运行 OpenHands 的用户在 docker 组
2. 在 docker-compose.yml 中正确挂载 socket：`/var/run/docker.sock:/var/run/docker.sock`

**Warning signs:**
- 错误信息："Cannot connect to the Docker daemon"
- 沙箱容器无法启动

### Pitfall 2: 文件存储路径配置错误

**What goes wrong:** OpenHands 的配置文件和工作区数据在容器重启后丢失

**Why it happens:** 未正确配置持久化卷挂载

**How to avoid:**
```yaml
volumes:
  - ~/.openhands:/.openhands              # 配置存储
  - /opt/workspace:/opt/workspace_base    # 工作区
```

**Warning signs:**
- 重启后对话历史丢失
- 工作区文件消失

### Pitfall 3: LLM API 密钥未配置

**What goes wrong:** OpenHands 启动但无法调用 LLM

**Why it happens:** 环境变量 `LLM_API_KEY` 未设置或值错误

**How to avoid:**
```bash
# 在 docker-compose.yml 或 .env 文件配置
environment:
  - LLM_API_KEY=${LLM_API_KEY}
  - LLM_MODEL=claude-sonnet-4-5-20250929
```

### Pitfall 4: NixOS 防火墙阻止网络访问

**What goes wrong:** OpenHands Web UI 无法从外部访问

**Why it happens:** NixOS 防火墙未开放 3000 端口

**How to avoid:**
```nix
networking.firewall.allowedTCPPorts = [ 3000 ];
```

### Pitfall 5: 容器启动顺序问题

**What goes wrong:** OpenHands 启动失败因为 Docker 服务未就绪

**Why it happens:** systemd 服务未配置正确的依赖关系

**How to avoid:**
```nix
systemd.services.openhands = {
  after = [ "docker.service" ];
  requires = [ "docker.service" ];
};
```

## Code Examples

### OpenHands Docker Compose 配置

```yaml
# /var/lib/openhands/docker-compose.yml
services:
  openhands:
    image: openhands:latest
    build:
      context: ./
      dockerfile: ./containers/app/Dockerfile
    container_name: openhands-app
    environment:
      - LLM_API_KEY=${LLM_API_KEY}
      - LLM_MODEL=claude-sonnet-4-5-20250929
      - AGENT_SERVER_IMAGE_REPOSITORY=ghcr.io/openhands/agent-server
      - AGENT_SERVER_IMAGE_TAG=1.12.0-python
      - WORKSPACE_MOUNT_PATH=/opt/workspace_base
    ports:
      - "3000:3000"
    extra_hosts:
      - "host.docker.internal:host-gateway"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /var/lib/openhands/data:/.openhands
      - /opt/workspace:/opt/workspace_base
    restart: unless-stopped
```

### NixOS Docker 配置

```nix
# nixos/default.nix
{
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;  # 自动清理悬空镜像
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];

  users.users.zhaochanglong.extraGroups = [ "docker" "containers" ];
}
```

### systemd 服务定义

```nix
# nixos/openhands/service.nix
{ config, pkgs, lib, ... }:
{
  systemd.services.openhands = {
    description = "OpenHands AI Programming Assistant";
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" "network-online.target" ];
    requires = [ "docker.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/var/lib/openhands";
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f /var/lib/openhands/docker-compose.yml up -d";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f /var/lib/openhands/docker-compose.yml down";
      Restart = "on-failure";
      RestartSec = "10s";
    };

    environment = {
      DOCKER_HOST = "unix:///var/run/docker.sock";
    };
  };

  # 环境变量文件（由 sops 管理）
  environment.etc."openhands.env".source = config.sops.secrets.openhands_env.path;
}
```

### SOPS 密钥配置

```nix
# nixos/sops.nix
{
  sops.secrets = {
    openhands_llm_api_key = {
      file = "/var/lib/openhands/.env";
      format = "env";
      sopsFile = ./secrets/openhands.yaml;
    };
  };
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| 手动 docker run | Docker Compose | 2020+ | 声明式编排、可重现 |
| 明文密钥配置 | sops-nix 加密 | 2023+ | 安全密钥管理 |
| 手动服务管理 | systemd 集成 | NixOS 传统 | 自动化运维 |
| 独立容器 | 容器 + 沙箱架构 | OpenHands 设计 | 安全代码执行 |

**Deprecated/outdated:**
- OpenHands 旧版 `CODEACT_AGENT` 配置：已被统一的 agent-server 架构替代
- 直接运行在宿主的模式：推荐使用 Docker 沙箱隔离

## Open Questions

1. **OpenHands 在 NixOS 容器（LXC）内运行 Docker 的兼容性**
   - 问题：NixOS 原生容器（`nixos-container`）内运行 Docker 需要嵌套虚拟化或 Docker-in-Docker
   - 已知：OpenHands 需要 Docker socket 访问
   - 建议：直接在宿主机运行 Docker 容器，而非 NixOS LXC 容器内
   - 需要验证：是否可通过 `virtualisation.docker.rootless` 实现

2. **最佳持久化路径选择**
   - 选项 A：`/var/lib/openhands`（系统级）
   - 选项 B：`/home/zhaochanglong/.openhands`（用户级）
   - 建议：系统级部署使用 `/var/lib/openhands`

3. **LLM 提供商配置细节**
   - OpenHands 支持多种 LLM（Anthropic、OpenAI、Azure 等）
   - 具体模型名称和 API 端点需要用户根据实际选择配置

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | systemd 服务状态检查 + 手动功能验证 |
| Config file | 无专用测试框架 |
| Quick run command | `systemctl status openhands` |
| Full suite command | `docker-compose -f /var/lib/openhands/docker-compose.yml ps` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| OH-01 | OpenHands 服务运行 | integration | `systemctl is-active openhands` | ❌ Wave 0 |
| OH-02 | Web UI 可访问 (端口 3000) | smoke | `curl -s http://localhost:3000` | ❌ Wave 0 |
| OH-03 | LLM API 配置正确 | unit | `docker exec openhands env \| grep LLM` | ❌ Wave 0 |
| OH-04 | 数据持久化 | integration | 重启后验证 `~/.openhands` 存在 | ❌ Wave 0 |
| OH-05 | 开机自启 | integration | 重启后 `systemctl is-active openhands` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `systemctl status openhands`
- **Per wave merge:** `docker-compose ps && curl -s http://localhost:3000`
- **Phase gate:** 服务运行、Web UI 响应、持久化验证全部通过

### Wave 0 Gaps
- [ ] `nixos/openhands/default.nix` — OpenHands 主配置
- [ ] `nixos/openhands/docker-compose.yml` — 容器编排定义
- [ ] `nixos/openhands/service.nix` — systemd 服务
- [ ] `nixos/packages/default.nix` — 添加 docker-compose
- [ ] `nixos/sops.nix` — 添加 OpenHands 密钥配置
- [ ] Framework install: `environment.systemPackages = [ pkgs.docker-compose ];`

## Sources

### Primary (HIGH confidence)
- [OpenHands docker-compose.yml](https://raw.githubusercontent.com/All-Hands-AI/OpenHands/main/docker-compose.yml) — 官方容器配置
- [OpenHands Dockerfile](https://raw.githubusercontent.com/All-Hands-AI/OpenHands/main/containers/app/Dockerfile) — 官方构建配置
- [OpenHands pyproject.toml](https://raw.githubusercontent.com/All-Hands-AI/OpenHands/main/pyproject.toml) — 依赖和元数据
- [NixOS containers.nix module](https://raw.githubusercontent.com/NixOS/nixpkgs/master/nixos/modules/virtualisation/containers.nix) — NixOS 容器模块源码
- [NixOS Manual - Containers](https://nixos.org/manual/nixos/stable/index.html#ch-container) — 官方文档

### Secondary (MEDIUM confidence)
- WebSearch: OpenHands deployment configuration — 需与官方源交叉验证
- WebSearch: NixOS containers configuration — 需与 NixOS 手册交叉验证

### Tertiary (LOW confidence)
- 社区博客和非官方教程 — 标记为需要验证

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - 基于 OpenHands 官方 docker-compose.yml 和 NixOS 官方文档
- Architecture: MEDIUM - Docker Compose + systemd 是标准模式，但 NixOS 集成需要验证
- Pitfalls: MEDIUM - 基于 Docker 和 OpenHands 已知问题，NixOS 特定问题需要实际验证

**Research date:** 2026-03-20
**Valid until:** 90 days (OpenHands 和 Docker 配置相对稳定)
