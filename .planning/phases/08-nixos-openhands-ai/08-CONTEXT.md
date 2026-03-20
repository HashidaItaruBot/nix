# Phase 8 Context — 使用 Podman 容器部署 OpenHands AI 编程助手

**Created:** 2026-03-20
**Updated:** 2026-03-20

---

## Architecture Decision

**Original approach:** Docker + Docker Compose
**Pivot 1:** nixos-container + Podman (用户要求抛弃 Docker)
**Final approach:** 宿主机直接运行 Podman 容器（简化架构）

### Final Decision Rationale

| Consideration | Decision |
|---------------|----------|
| **容器运行时** | Podman (无守护进程，rootless) |
| **部署位置** | 宿主机直接运行（非 nixos-container 内） |
| **编排工具** | podman-compose (Docker Compose 替代) |
| **数据路径** | `/home/zhaochanglong/.openhands` (用户级) |
| **服务管理** | systemd oneshot 服务 |
| **Docker 兼容** | podman-docker (仅提供 API 兼容，非必需) |

### Why Not nixos-container?

OpenHands 本身需要创建子容器来执行代码（沙箱功能）。即使将 OpenHands 放在 nixos-container 内：
1. 它仍需调用宿主机 socket 创建子容器
2. nixos-container 的隔离层对 OpenHands 没有实际价值
3. 反而增加调试复杂度和嵌套容器问题

**直接运行在宿主机是最简单且实用的方案。**

---

## Configuration Structure

```
nixos/
├── default.nix              # virtualisation.podman.enable
├── packages/default.nix     # podman, podman-compose
├── openhands/
│   ├── default.nix          # systemd 服务定义
│   └── podman-compose.yml   # Podman 容器编排
├── sops.nix                 # LLM API 密钥加密
└── home/
    └── zhaochanglong.nix    # 用户环境配置
```

---

## Requirements Mapping

| Req ID | Description | Implementation |
|--------|-------------|----------------|
| OH-01 | OpenHands 服务运行 | podman-compose + systemd |
| OH-02 | Web UI 端口 3000 可访问 | 容器端口映射 + 防火墙 |
| OH-03 | LLM API 密钥安全存储 | sops-nix 加密 |
| OH-04 | 数据持久化 | `~/.openhands` 卷挂载 |
| OH-05 | 开机自启 | systemd `wantedBy` |

---

## Technical Details

### Podman 配置

```nix
# nixos/default.nix
virtualisation.podman = {
  enable = true;
  dockerCompat = true;  # /var/run/docker.sock → podman.sock
  defaultNetwork.settings.dns_enabled = true;
};
```

### 容器编排

```yaml
# /home/zhaochanglong/.openhands/podman-compose.yml
services:
  openhands:
    image: ghcr.io/openhands/openhands:latest
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

### systemd 服务

```nix
# nixos/openhands/default.nix
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
```

### SOPS 密钥

```nix
# nixos/sops.nix
sops.secrets.openhands_llm_api_key = {
  file = "/home/zhaochanglong/.openhands/.env";
  format = "env";
  sopsFile = ./secrets/openhands.yaml;
};
```

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

- ~~nixos-container 系统容器~~ - 改为宿主机直接运行
- ~~嵌套容器~~ - 不必要的复杂性
- ~~Docker daemon~~ - 使用 Podman 代替

---

## Next Steps

1. 更新 Phase 8 计划文件（3 个 plans）
2. 执行 Plan 01: Podman 基础设施
3. 执行 Plan 02: OpenHands 容器编排
4. 执行 Plan 03: SOPS 密钥和验证

---

*This context supersedes all prior Phase 8 architecture decisions.*
