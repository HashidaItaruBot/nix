---
phase: 8
phase_slug: nixos-openhands-ai
date: 2026-03-20
---

# Phase 8: OpenHands AI 助手容器部署 - Validation Strategy

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | systemd 服务状态检查 + 手动功能验证 |
| Config file | 无专用测试框架 |
| Quick run command | `systemctl is-active openhands` |
| Full suite command | `docker-compose -f /var/lib/openhands/docker-compose.yml ps` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| OH-01 | OpenHands 服务运行 | integration | `systemctl is-active openhands` | ❌ Wave 0 |
| OH-02 | Web UI 可访问 (端口 3000) | smoke | `curl -s http://localhost:3000` | ❌ Wave 0 |
| OH-03 | LLM API 配置正确 | unit | `docker exec openhands env \| grep LLM` | ❌ Wave 0 |
| OH-04 | 数据持久化 | integration | 重启后验证 `/var/lib/openhands/data` 存在 | ❌ Wave 0 |
| OH-05 | 开机自启 | integration | 重启后 `systemctl is-active openhands` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `systemctl status openhands`
- **Per wave merge:** `docker-compose ps && curl -s http://localhost:3000`
- **Phase gate:** 服务运行、Web UI 响应、持久化验证全部通过

## Wave 0 Gaps

需要创建的文件：
- [ ] `nixos/openhands/default.nix` — OpenHands 主配置
- [ ] `nixos/openhands/docker-compose.yml` — 容器编排定义
- [ ] `nixos/openhands/service.nix` — systemd 服务
- [ ] `nixos/packages/default.nix` — 添加 docker-compose
- [ ] `nixos/sops.nix` — 添加 OpenHands 密钥配置
- [ ] Framework install: `environment.systemPackages = [ pkgs.docker-compose ];`
