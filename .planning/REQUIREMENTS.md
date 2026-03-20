# v1.1 Requirements

**Milestone:** v1.1 — MicroVM 运行 OpenClaw
**Created:** 2026-03-19
**Status:** Roadmap created

---

## v1 Requirements

### MIC (MicroVM 基础设施)

- [ ] **MIC-01**: microvm.nix 集成到 NixOS 配置
- [ ] **MIC-02**: MicroVM 可启动并运行 NixOS guest
- [ ] **MIC-03**: 配置 cloud-hypervisor 作为 hypervisor
- [ ] **MIC-04**: 配置 2GB 内存分配

### STO (存储和持久化)

- [ ] **STO-01**: virtiofs 只读共享 host 的 `/nix/store`
- [ ] **STO-02**: ext4 块设备卷用于持久化存储
- [ ] **STO-03**: 持久化目录挂载到 MicroVM 内正确位置
- [ ] **STO-04**: Nix 包在 host 上构建（避免 Nix DB 遗忘问题）

### NET (网络配置)

- [ ] **NET-01**: TAP 桥接接口配置
- [ ] **NET-02**: MicroVM 获得独立 LAN IP 地址
- [ ] **NET-03**: openclaw 端口 18789 可访问
- [ ] **NET-04**: systemd-networkd 桥接服务配置

### OCL (openclaw 集成)

- [ ] **OCL-01**: Node.js 22+ 运行时配置
- [ ] **OCL-02**: openclaw Gateway 服务运行
- [ ] **OCL-03**: nix-openclaw home-manager 模块集成
- [ ] **OCL-04**: secrets 文件放置在持久化卷中

### OPS (运维加固)

- [ ] **OPS-01**: MicroVM 开机自动启动
- [ ] **OPS-02**: systemd 服务依赖正确配置
- [ ] **OPS-03**: 资源限制配置（CPU/内存）
- [ ] **OPS-04**: 验证重启后 MicroVM 自动恢复

### OH (OpenHands AI 助手)

- [ ] **OH-01**: OpenHands 服务在 nixos-container 内运行
- [ ] **OH-02**: Web UI 在端口 3000 可访问
- [ ] **OH-03**: LLM API 密钥通过 sops 加密存储
- [ ] **OH-04**: 数据持久化配置正确
- [ ] **OH-05**: 容器开机自启

---

## Future Requirements (Deferred)

### 监控和可观测性

- [ ] MicroVM 日志聚合到 host journal
- [ ] openclaw 健康检查端点监控
- [ ] 资源使用率监控（CPU/内存/磁盘）

### 高级隔离

- [ ] 配置 seccomp 系统调用过滤
- [ ] 配置 cgroups v2 资源控制
- [ ] 网络流量限制和 QoS

---

## Out of Scope

**明确排除的功能：**

- SSH Agent Forwarding 到 MicroVM — 需求明确不需要与宿主机共享 SSH 密钥
- macOS 平台支持 — microvm.nix 仅支持 NixOS
- Docker-in-MicroVM — 不必要的复杂性
- 动态资源调整 — v1.1 使用静态配置

---

## Traceability

*Updated: 2026-03-19 after roadmap creation*

| Requirement | Phase | Status |
|-------------|-------|--------|
| MIC-01 | Phase 4 | Pending |
| MIC-02 | Phase 4 | Pending |
| MIC-03 | Phase 4 | Pending |
| MIC-04 | Phase 4 | Pending |
| STO-01 | Phase 5 | Pending |
| STO-02 | Phase 5 | Pending |
| STO-03 | Phase 5 | Pending |
| STO-04 | Phase 5 | Pending |
| NET-01 | Phase 6 | Pending |
| NET-02 | Phase 6 | Pending |
| NET-03 | Phase 6 | Pending |
| NET-04 | Phase 6 | Pending |
| OCL-01 | Phase 7 | Pending |
| OCL-02 | Phase 7 | Pending |
| OCL-03 | Phase 7 | Pending |
| OCL-04 | Phase 7 | Pending |
| OPS-01 | Phase 7 | Pending |
| OPS-02 | Phase 7 | Pending |
| OPS-03 | Phase 7 | Pending |
| OPS-04 | Phase 7 | Pending |
| OH-01 | Phase 8 | Pending |
| OH-02 | Phase 8 | Pending |
| OH-03 | Phase 8 | Pending |
| OH-04 | Phase 8 | Pending |
| OH-05 | Phase 8 | Pending |

**Coverage:** 25/25 v1 requirements mapped ✓

---

*Created: 2026-03-19*
*Roadmap created: 2026-03-19*
