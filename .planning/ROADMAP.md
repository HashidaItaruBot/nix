# Roadmap: v1.3 Colima + OpenHands on macOS

**Created:** 2026-03-20
**Core Value:** 在 macOS 上使用 Colima 运行 OpenHands AI 编程助手，通过 Web UI 访问，配置阿里百炼 LLM 后端

---

## Phases

- [ ] **Phase 4: Colima 安装与初始化** - 安装 Colima 并配置可运行容器的虚拟机环境
- [ ] **Phase 5: OpenHands 容器运行** - 使用官方镜像启动 OpenHands 容器，Web UI 可访问
- [ ] **Phase 6: 阿里百炼 LLM 后端配置** - 配置 Qwen/Kimi 模型，API 认证通过
- [ ] **Phase 7: 持久化与工作区集成** - 配置卷挂载，对话历史和工作区文件持久化

---

## Phase Details

### Phase 4: Colima 安装与初始化

**Goal:** Colima 在 macOS 上可运行容器

**Depends on:** Nothing (first phase of v1.3)

**Requirements:** COLIMA-01, COLIMA-02, COLIMA-03, COLIMA-04, COLIMA-05

**Success Criteria** (what must be TRUE):
  1. `colima --version` 返回已安装版本号
  2. `colima status` 显示 VM 状态为 "Running"
  3. VM 资源配置为 8GB+ RAM, 4+ CPUs
  4. `docker run --rm hello-world` 成功执行并无错误退出 (Colima 提供 Docker 兼容 API)
  5. `docker ps` 可正常列出容器

**Plans:** 2/3 plans executed

Plans:
- [ ] 04-01-PLAN.md — 安装 Colima，创建验证脚本
- [ ] 04-02-PLAN.md — 配置 Colima VM 初始化和 launchd 自动启动
- [ ] 04-03-PLAN.md — 验证 Colima 完整功能（checkpoint）

---

### Phase 5: OpenHands 容器运行

**Goal:** OpenHands 容器正常运行，Web UI 可通过浏览器访问

**Depends on:** Phase 4 (Colima 运行环境)

**Requirements:** OH-01, OH-02, OH-03, OH-04, OH-05

**Success Criteria** (what must be TRUE):
  1. 使用 `ghcr.io/openhands/openhands:latest` 镜像启动容器
  2. 浏览器访问 `http://localhost:3000` 显示 OpenHands Web UI
  3. 容器绑定到 `0.0.0.0:3000` (非 `127.0.0.1`)
  4. 容器传递 LLM_API_KEY, LLM_MODEL, LLM_BASE_URL 环境变量
  5. 容器启动后无错误退出，日志正常

**Plans:** TBD

---

### Phase 6: 阿里百炼 LLM 后端配置

**Goal:** OpenHands 使用阿里百炼 LLM (qwen3.5-plus, kimi-k2.5) 完成 AI 任务

**Depends on:** Phase 5 (OpenHands 容器运行)

**Requirements:** LLM-01, LLM-02, LLM-03, LLM-04, LLM-05

**Success Criteria** (what must be TRUE):
  1. LLM_MODEL 配置为 `alibaba/qwen-plus` 或等效标识
  2. LLM_BASE_URL 配置为 `https://dashscope.aliyuncs.com/compatible-mode/v1`
  3. API Key 通过环境变量正确传递到容器
  4. OpenHands 可调用 qwen3.5-plus 模型完成任务
  5. OpenHands 可调用 kimi-k2.5 模型完成任务 (可选)

**Plans:** TBD

---

### Phase 7: 持久化与工作区集成

**Goal:** 工作区目录和对话历史在容器重启后保留

**Depends on:** Phase 5 (OpenHands 容器运行)

**Requirements:** PERS-01, PERS-02, PERS-03, PERS-04, PERS-05

**Success Criteria** (what must be TRUE):
  1. `~/.openhands` 目录挂载到容器，配置文件持久化
  2. 工作区目录 (如 `~/projects/myapp`) 挂载到容器 `/workspace`
  3. 卷挂载使用 SELinux 标签 (`:z` 或 `:Z`)
  4. 工作区路径为 `/Users` 下的绝对路径
  5. 容器重启后，之前的对话历史仍然可用

**Plans:** TBD

---

## Progress Table

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 4. Colima 安装与初始化 | 2/3 | In Progress|  |
| 5. OpenHands 容器运行 | 0/5 | Not started | - |
| 6. 阿里百炼 LLM 后端配置 | 0/5 | Not started | - |
| 7. 持久化与工作区集成 | 0/5 | Not started | - |

---

## Requirement Coverage

| Requirement | Phase | Status |
|-------------|-------|--------|
| COLIMA-01 | Phase 4 | Pending |
| COLIMA-02 | Phase 4 | Pending |
| COLIMA-03 | Phase 4 | Pending |
| COLIMA-04 | Phase 4 | Pending |
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

**Coverage:** 20/20 v1.3 requirements mapped ✓

---

*Last updated: 2026-03-20*
