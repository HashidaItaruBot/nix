# v1.1 Roadmap — MicroVM 运行 OpenClaw

**Milestone:** v1.1
**Created:** 2026-03-19
**Updated:** 2026-03-21
**Granularity:** Coarse (5 phases)
**Coverage:** 25/25 requirements mapped

---

## Phases

- [ ] **Phase 4: MicroVM 基础设施** - 创建可启动的 MicroVM 基础环境
- [ ] **Phase 5: 存储与持久化** - 配置只读 Nix store 共享和持久化数据卷
- [ ] **Phase 6: 网络配置** - 配置 TAP 桥接接口使 MicroVM 获得独立 LAN IP
- [ ] **Phase 7: openclaw 集成与运维** - 运行 openclaw Gateway 服务并配置开机自启
- [ ] **Phase 8: OpenHands AI 助手** - 在 NixOS 容器内部署 OpenHands 编程助手

---

## Phase Details

### Phase 4: MicroVM 基础设施
**Goal**: MicroVM 可启动并运行 NixOS guest

**Depends on**: Nothing (foundation phase)

**Requirements**: MIC-01, MIC-02, MIC-03, MIC-04

**Success Criteria** (what must be TRUE):
1. 用户可通过 `nixos-rebuild switch` 将 microvm.nix 集成到 NixOS 配置
2. 用户可通过 `systemctl start microvm-openclaw` 启动 MicroVM
3. MicroVM 成功引导 NixOS guest 并可通过 `virsh console` 访问
4. MicroVM 配置使用 cloud-hypervisor 作为 hypervisor
5. MicroVM 分配 2GB 内存并稳定运行

**Plans**: 2 plans

**Plans:**
- [ ] 04-01-PLAN.md — 创建 MicroVM 基础设施配置文件 (Wave 1, MIC-01/03/04)
- [ ] 04-02-PLAN.md — 验证 MicroVM 可启动和 console 访问 (Wave 2, MIC-02)

---

### Phase 5: 存储与持久化
**Goal**: MicroVM 具有持久化存储，数据不会丢失

**Depends on**: Phase 4

**Requirements**: STO-01, STO-02, STO-03, STO-04

**Success Criteria** (what must be TRUE):
1. MicroVM 内 `/nix/.ro-store` 挂载点可访问 host 的 Nix store（只读）
2. MicroVM 内 `/var/lib/openclaw` 目录可读写且数据重启后保留
3. 在 host 上构建的 Nix 包可在 MicroVM 内使用
4. 用户可验证重启后 MicroVM 内数据未丢失

**Plans**: TBD

---

### Phase 6: 网络配置
**Goal**: MicroVM 可对外提供网络服务

**Depends on**: Phase 4

**Requirements**: NET-01, NET-02, NET-03, NET-04

**Success Criteria** (what must be TRUE):
1. host 上存在 TAP 桥接接口（systemd-networkd 管理）
2. MicroVM 获得独立的 LAN IP 地址（与 host 同一网段）
3. 从 LAN 其他设备可 ping 通 MicroVM 的 IP
4. 从 LAN 其他设备可访问 MicroVM 的 18789 端口

**Plans**: TBD

---

### Phase 7: openclaw 集成与运维
**Goal**: openclaw 服务在 MicroVM 中运行并开机自启

**Depends on**: Phase 5, Phase 6

**Requirements**: OCL-01, OCL-02, OCL-03, OCL-04, OPS-01, OPS-02, OPS-03, OPS-04

**Success Criteria** (what must be TRUE):
1. MicroVM 内 Node.js 22+ 运行时可用
2. openclaw Gateway 服务运行在端口 18789 并可响应请求
3. secrets 文件位于持久化卷中且权限正确
4. host 重启后 MicroVM 自动启动（无需手动干预）
5. systemd 服务依赖正确（TAP → virtiofsd → VM）
6. MicroVM 配置资源限制（CPU/内存）

**Plans**: TBD

---

### Phase 8: 在 NixOS 容器内部署 OpenHands AI 编程助手
**Goal**: OpenHands AI 编程助手在 nixos-container 内运行并可通过 Web UI 访问

**Requirements**: OH-01, OH-02, OH-03, OH-04, OH-05

**Depends on:** Phase 7 (OpenHands 与 MicroVM 独立部署)

**Architecture:** NixOS 声明式容器 + Docker (容器内运行 Docker)

| Component | Decision |
|-----------|----------|
| 外层隔离 | nixos-container (系统级容器) |
| 容器运行时 | Docker (容器内运行) |
| 部署方式 | Docker Compose |
| 网络 | NAT 端口转发 (宿主机 3000 → 容器 3000) |
| 数据路径 | /var/lib/openhands (宿主机 bind mount) |
| 密钥管理 | sops-nix 加密 |
| LLM 后端 | 阿里百炼 (OpenAI 兼容 API) |

**Success Criteria** (what must be TRUE):
1. OpenHands 服务可通过 `systemctl start container@openhands` 启动
2. Web UI 在端口 3000 可访问（通过宿主机转发）
3. LLM API 密钥通过 sops 加密存储
4. 数据持久化配置正确，重启后数据不丢失
5. nixos-container 配置开机自启

**Plans:** 3 plans

Plans:
- [ ] 08-01-PLAN.md — 创建 nixos-container 配置和 Docker Compose 编排 (Wave 1, OH-01/02/04/05)
- [ ] 08-02-PLAN.md — 配置 SOPS 密钥管理 (Wave 2, OH-03)
- [ ] 08-03-PLAN.md — 应用配置并验证服务运行 (Wave 3, 所有 OH 需求验证)

---

## Progress Table

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 4. MicroVM 基础设施 | 0/2 | Planned | - |
| 5. 存储与持久化 | 0/4 | Not started | - |
| 6. 网络配置 | 0/4 | Not started | - |
| 7. openclaw 集成与运维 | 0/6 | Not started | - |
| 8. OpenHands AI 助手 | 0/3 | Planned | - |

---

## Requirement Coverage

| Requirement ID | Phase | Category |
|----------------|-------|----------|
| MIC-01 | Phase 4 | MIC |
| MIC-02 | Phase 4 | MIC |
| MIC-03 | Phase 4 | MIC |
| MIC-04 | Phase 4 | MIC |
| STO-01 | Phase 5 | STO |
| STO-02 | Phase 5 | STO |
| STO-03 | Phase 5 | STO |
| STO-04 | Phase 5 | STO |
| NET-01 | Phase 6 | NET |
| NET-02 | Phase 6 | NET |
| NET-03 | Phase 6 | NET |
| NET-04 | Phase 6 | NET |
| OCL-01 | Phase 7 | OCL |
| OCL-02 | Phase 7 | OCL |
| OCL-03 | Phase 7 | OCL |
| OCL-04 | Phase 7 | OCL |
| OPS-01 | Phase 7 | OPS |
| OPS-02 | Phase 7 | OPS |
| OPS-03 | Phase 7 | OPS |
| OPS-04 | Phase 7 | OPS |
| OH-01 | Phase 8 | OH |
| OH-02 | Phase 8 | OH |
| OH-03 | Phase 8 | OH |
| OH-04 | Phase 8 | OH |
| OH-05 | Phase 8 | OH |

**Coverage:** 25/25 v1.1 requirements mapped ✓

---

*Created: 2026-03-19*
*Phase 8 planned: 2026-03-20*
*Phase 8 revised: 2026-03-21 (架构: nixos-container + Docker)*