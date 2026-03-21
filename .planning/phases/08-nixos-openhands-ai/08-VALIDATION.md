---
phase: 8
phase_slug: nixos-openhands-ai
date: 2026-03-21
---

# Phase 8: OpenHands AI 助手容器部署 - Validation Strategy

## Validation Architecture

### Architecture Note

**重要：** OpenHands 使用 nixos-container + Docker 架构部署：
- 外层：NixOS 声明式容器 (`container@openhands` systemd 服务)
- 内层：Docker 容器运行 OpenHands 服务

所有测试命令必须正确区分宿主机和容器内操作。

### Test Framework
| Property | Value |
|----------|-------|
| Framework | systemd 服务状态检查 + NixOS 容器命令 + 手动功能验证 |
| Config file | 无专用测试框架 |
| Quick run command | `systemctl is-active container@openhands` |
| Full suite command | `nixos-container run openhands -- docker-compose -f /var/lib/openhands/docker-compose.yml ps` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| OH-01 | OpenHands 服务运行 | integration | `systemctl is-active container@openhands` | ✅ Plan 01 |
| OH-02 | Web UI 可访问 (端口 3000) | smoke | `curl -s http://localhost:3000` | ✅ Plan 01 |
| OH-03 | LLM API 配置正确 | unit | `nixos-container run openhands -- docker exec openhands env \| grep LLM` | ✅ Plan 02 |
| OH-04 | 数据持久化 | integration | 重启后验证 `/var/lib/openhands/data` 存在 | ✅ Plan 01 |
| OH-05 | 开机自启 | integration | 重启后 `systemctl is-active container@openhands` | ✅ Plan 01 |

### Sampling Rate
- **Per task commit:** `systemctl status container@openhands`
- **Per wave merge:** `nixos-container run openhands -- docker-compose ps && curl -s http://localhost:3000`
- **Phase gate:** 容器运行、Web UI 响应、持久化验证全部通过

## Wave 0 Gaps

需要创建的文件 (已在 Plan 01-03 中定义):

- [x] `nixos/containers/openhands.nix` — OpenHands NixOS 容器配置 (Plan 01)
- [x] `nixos/containers/docker-compose.yml` — Docker Compose 编排定义 (Plan 01)
- [x] `nixos/default.nix` — 导入 containers 模块 (Plan 01)
- [x] `nixos/sops.nix` — 添加 OpenHands LLM API 密钥配置 (Plan 02)
- [x] `nixos/secrets/openhands.yaml` — 加密的 LLM API 密钥 (Plan 02)

## Test Commands Reference

### 宿主机命令 (Host Commands)

```bash
# 检查 NixOS 容器状态
systemctl status container@openhands

# 列出所有 NixOS 容器
nixos-container list

# 检查容器服务是否 active
systemctl is-active container@openhands

# 检查端口转发
ss -tlnp | grep 3000

# 测试 Web UI 可访问性
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000
```

### 容器内命令 (Container Commands)

```bash
# 在容器内执行命令
nixos-container run openhands -- <command>

# 检查容器内 Docker 服务
nixos-container run openhands -- systemctl status docker

# 检查容器内 OpenHands 服务
nixos-container run openhands -- systemctl status openhands

# 检查容器内 Docker 容器状态
nixos-container run openhands -- docker ps

# 检查 LLM 环境变量配置
nixos-container run openhands -- docker exec openhands env | grep LLM
```

### 数据持久化验证

```bash
# 检查宿主机数据目录
ls -la /var/lib/openhands/

# 检查容器内挂载
nixos-container run openhands -- ls -la /var/lib/openhands/

# 验证 bind mount (在容器内创建文件，宿主机检查)
nixos-container run openhands -- touch /var/lib/openhands/data/test-persist
ls -la /var/lib/openhands/data/test-persist
```

### 密钥验证

```bash
# 检查宿主机上的 SOPS 密钥路径
ls -la /run/secrets/openhands/

# 检查容器内是否可访问密钥
nixos-container run openhands -- ls -la /run/secrets/openhands/
```

## Validation Checklist

### Plan 01 验证 (配置文件)
- [ ] `nixos/containers/openhands.nix` 文件存在
- [ ] `nixos/containers/docker-compose.yml` 文件存在
- [ ] `nixos/default.nix` 包含 `./containers` 导入
- [ ] 配置包含 `autoStart = true`
- [ ] 配置包含 `forwardPorts` 端口 3000
- [ ] 配置包含 `bindMounts` 数据持久化

### Plan 02 验证 (密钥管理)
- [ ] `nixos/sops.nix` 包含 `openhands_llm_api_key` 配置
- [ ] `nixos/secrets/openhands.yaml` 文件存在且已加密
- [ ] 密钥文件包含 `LLM_API_KEY` 键

### Plan 03 验证 (部署)
- [ ] `nixos-container list` 显示 openhands
- [ ] `systemctl is-active container@openhands` 返回 active
- [ ] `curl localhost:3000` 返回 HTTP 200
- [ ] `/var/lib/openhands/data` 目录存在
- [ ] `/var/lib/openhands/workspace` 目录存在

## Common Issues

### 容器未启动
```bash
# 检查容器状态
nixos-container status openhands

# 手动启动容器
systemctl start container@openhands

# 查看容器日志
journalctl -u container@openhands
```

### Docker 服务问题
```bash
# 在容器内检查 Docker
nixos-container run openhands -- systemctl status docker

# 重启容器内 Docker
nixos-container run openhands -- systemctl restart docker
```

### Web UI 无法访问
```bash
# 检查端口监听
ss -tlnp | grep 3000

# 检查容器内 OpenHands 服务
nixos-container run openhands -- systemctl status openhands

# 检查容器内 Docker 容器
nixos-container run openhands -- docker logs openhands
```