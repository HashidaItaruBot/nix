# Requirements: v1.3 Colima + OpenHands on macOS

**Defined:** 2026-03-20
**Core Value:** 在 macOS 上使用 Colima 运行 OpenHands AI 编程助手，通过 Web UI 访问，配置阿里百炼 LLM 后端

## v1.3 Requirements

### Colima 安装与配置

- [x] **COLIMA-01**: 通过 Homebrew 安装 Colima
- [x] **COLIMA-02**: 初始化 Colima VM (`colima start`)
- [x] **COLIMA-03**: 配置 Colima VM 资源（8GB+ RAM, 4+ CPUs）
- [x] **COLIMA-04**: 配置 launchd 自动启动
- [ ] **COLIMA-05**: 验证 Colima 容器运行能力

### OpenHands 容器

- [ ] **OH-01**: 使用官方镜像 (`ghcr.io/openhands/openhands:latest`)
- [ ] **OH-02**: Web UI 端口映射 (3000:3000)
- [ ] **OH-03**: 容器绑定到 0.0.0.0（非 127.0.0.1）
- [ ] **OH-04**: LLM 环境变量传递（LLM_API_KEY, LLM_MODEL, LLM_BASE_URL）
- [ ] **OH-05**: 容器可正常启动并无错误退出

### LLM 后端配置（阿里百炼）

- [ ] **LLM-01**: 配置阿里百炼 provider (`alibaba/qwen-plus`)
- [ ] **LLM-02**: 配置正确的 API Base URL
- [ ] **LLM-03**: API Key 正确传递到容器
- [ ] **LLM-04**: 支持 qwen3.5-plus 模型
- [ ] **LLM-05**: 支持 kimi-k2.5 模型（可选）

### 持久化与工作区

- [ ] **PERS-01**: `~/.openhands` 配置目录持久化
- [ ] **PERS-02**: 工作区目录挂载到容器
- [ ] **PERS-03**: Volume 挂载使用 SELinux 标签 (`:z` 或 `:Z`)
- [ ] **PERS-04**: 工作区路径为绝对路径且在 `/Users` 下
- [ ] **PERS-05**: 对话历史在容器重启后保留

## v2 Requirements

Deferred to future release.

### 高级功能

- **ADV-01**: 使用 Colima/ Docker 原生 API 管理容器
- **ADV-02**: litellm proxy 集成（多 LLM 路由、fallback）
- **ADV-03**: Git 仓库深度集成（自动 clone/push）
- **ADV-04**: 自定义 OpenHands 配置模板

### 优化与调优

- **OPT-01**: Colima VM 资源动态调整
- **OPT-02**: 容器启动脚本/服务定义
- **OPT-03**: 监控与日志收集

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| 在 NixOS 上运行 OpenHands | v1.3 仅限 macOS 本地 |
| 企业版 OpenHands | 需要购买 license，社区版足够 |
| 本地 LLM 模型（Ollama 等）| 阿里百炼已满足需求，defer 到未来 |
| 多用户支持 | 单用户场景足够 |
| OpenHands 源码修改 | 使用官方镜像，不定制 |
| Podman 兼容性 | 专注 Colima，Docker API 兼容性好 |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| COLIMA-01 | Phase 4 | Complete |
| COLIMA-02 | Phase 4 | Complete |
| COLIMA-03 | Phase 4 | Complete |
| COLIMA-04 | Phase 4 | Complete |
| COLIMA-05 | Phase 4 | Pending |
| OH-01 | Phase 5 | Pending |
| OH-02 | Phase 5 | Pending |
| OH-03 | Phase 5 | Pending |
| OH-04 | Phase 5 | Pending |
| OH-05 | Phase 5 | Pending |
| LLM-01 | Phase 6 | Pending |
| LLM-02 | Phase 6 | Pending |
| LLM-03 | Phase 6 | Pending |
| LLM-04 | Phase 6 | Pending |
| LLM-05 | Phase 6 | Pending |
| PERS-01 | Phase 7 | Pending |
| PERS-02 | Phase 7 | Pending |
| PERS-03 | Phase 7 | Pending |
| PERS-04 | Phase 7 | Pending |
| PERS-05 | Phase 7 | Pending |

**Coverage:**
- v1.3 requirements: 20 total
- Mapped to phases: 20
- Unmapped: 0 ✓

---
*Requirements defined: 2026-03-20*
*Last updated: 2026-03-20 after roadmap creation*
