# Phase 8 Context — NixOS 容器内 Docker 部署 OpenHands AI 编程助手

**Created:** 2026-03-20
**Updated:** 2026-03-21

---

## Architecture Decision

**Final approach:** NixOS 声明式容器 + Docker (容器内运行 Docker)

### Architecture Rationale

| Consideration | Decision |
|---------------|----------|
| **外层隔离** | nixos-container (系统级容器，提供强隔离) |
| **容器运行时** | Docker (容器内运行，OpenHands 官方兼容) |
| **部署方式** | Docker Compose (官方推荐配置) |
| **网络** | NAT 端口转发 (宿主机 3000 → 容器 3000) |
| **数据路径** | `/var/lib/openhands` (宿主机 bind mount) |
| **密钥管理** | sops-nix 加密，挂载到容器 |
| **LLM 后端** | 阿里百炼 (OpenAI 兼容 API) |
| **资源配置** | 4GB RAM, 4 CPU cores |

### Why Docker instead of Podman?

用户明确选择 Docker 以确保 OpenHands 兼容性：
1. OpenHands 官方文档使用 Docker
2. Docker Compose 配置可直接使用
3. 避免潜在的 Podman 兼容性问题

### Why nixos-container?

用户希望增强**隔离性**：
1. 系统级容器提供额外的隔离层
2. 与宿主机环境完全分离
3. 即使 OpenHands 或其沙箱容器出问题，也局限在容器内

---

## Configuration Structure

```
nixos/
├── default.nix                    # containers.openhands 定义
├── containers/
│   └── openhands.nix              # OpenHands 容器配置
├── sops.nix                       # LLM API 密钥加密
└── secrets/
    └── openhands.yaml             # 加密的密钥文件

# 容器内配置 (通过 bind mount 或 Nix 配置)
/var/lib/openhands/
├── docker-compose.yml             # Docker Compose 编排
├── data/                          # OpenHands 数据
└── workspace/                     # 工作空间
```

---

## Requirements Mapping

| Req ID | Description | Implementation |
|--------|-------------|----------------|
| OH-01 | OpenHands 服务运行 | nixos-container + Docker Compose |
| OH-02 | Web UI 端口 3000 可访问 | NAT 端口转发 |
| OH-03 | LLM API 密钥安全存储 | sops-nix 加密 + 环境变量注入 |
| OH-04 | 数据持久化 | `/var/lib/openhands` bind mount |
| OH-05 | 开机自启 | nixos-container autoStart |

---

## Technical Details

### NixOS 容器定义

```nix
# nixos/default.nix
containers.openhands = {
  autoStart = true;
  privateNetwork = true;
  hostBridge = null;  # NAT mode
  forwardPorts = [{
    containerPort = 3000;
    hostPort = 3000;
    protocol = "tcp";
  }];

  bindMounts = {
    "/var/lib/openhands" = {
      hostPath = "/var/lib/openhands";
      isReadOnly = false;
    };
    "/run/secrets/openhands" = {
      hostPath = "/run/secrets/openhands";
      isReadOnly = true;
    };
  };

  config = { config, pkgs, ... }: {
    # Docker inside container
    virtualisation.docker.enable = true;

    # Docker Compose service
    systemd.services.openhands = {
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
    };
  };
};
```

### Docker Compose 配置

```yaml
# /var/lib/openhands/docker-compose.yml
services:
  openhands:
    image: ghcr.io/openhands/openhands:latest
    container_name: openhands
    ports:
      - "3000:3000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./data:/.openhands
      - ./workspace:/opt/workspace_base
    environment:
      - LLM_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
      - LLM_API_KEY=${LLM_API_KEY}
      - LLM_MODEL=qwen-plus
    restart: unless-stopped
```

### SOPS 密钥配置

```nix
# nixos/sops.nix
sops.secrets.openhands_llm_api_key = {
  sopsFile = ./secrets/openhands.yaml;
  key = "LLM_API_KEY";
  owner = "root";
};
```

---

## LLM Configuration (阿里百炼)

| Variable | Value |
|----------|-------|
| `LLM_BASE_URL` | `https://dashscope.aliyuncs.com/compatible-mode/v1` |
| `LLM_API_KEY` | (SOPS 加密存储) |
| `LLM_MODEL` | `qwen-plus` 或 `qwen-turbo` |

---

## Resource Allocation

- **Memory:** 4GB
- **CPU:** 4 cores
- **Storage:** `/var/lib/openhands` (按需扩展)

---

## Prior Decisions to Preserve

| Decision | From | Status |
|----------|------|--------|
| 声明式 Nix 配置 | PROJECT.md | ✓ |
| SOPS 密钥管理 | Phase 8 Research | ✓ |
| 开机自启 | ROADMAP.md | ✓ |
| 数据持久化 | ROADMAP.md | ✓ |

---

## Out of Scope

- ~~宿主机直接运行 Podman~~ - 改为 nixos-container + Docker
- ~~嵌套 Podman~~ - 改为 Docker 以获得更好的 OpenHands 兼容性
- ~~Docker daemon on host~~ - Docker 运行在容器内

---

## Canonical References

### NixOS Containers
- NixOS Wiki: https://wiki.nixos.org/wiki/NixOS_Containers — 容器配置模式
- NixOS Manual § Containers — 声明式容器选项

### OpenHands
- OpenHands Docs: https://docs.openhands.dev/openhands/usage/run-openhands/local-setup — Docker 部署指南
- OpenHands GitHub: https://github.com/All-Hands-AI/OpenHands — 官方仓库

### 阿里百炼
- DashScope API: https://help.aliyun.com/zh/model-studio/developer-reference/use-qwen-by-calling-api — API 文档

---

*This context supersedes the prior "宿主机 Podman" architecture decision.*