---
plan_version: 1.0
created: 2026-03-20
mode: quick
---

# Quick Task Plan 260320-ohh: 在 macOS 上面使用容器运行 OpenHands

**Goal:** 使用 Colima 在 macOS 上运行 OpenHands 容器，Web UI 可通过浏览器访问

---

## Implementation Decisions

| Decision | Rationale |
|----------|-----------|
| 使用 Colima 作为容器运行时 | 用户指定，macOS 上轻量级 Docker 兼容方案 |
| 使用官方镜像 `ghcr.io/openhands/openhands:latest` | 官方维护，最新稳定版 |
| 端口映射 `3000:3000` | OpenHands 默认 Web UI 端口 |
| 卷挂载 `~/.openhands` 和 workspace 目录 | 持久化配置和工作区文件 |
| Colima 自动处理卷挂载 | 无需手动配置 SELinux 标签 |

---

## Tasks

### Task 1: 创建 OpenHands Nix 配置 ✓

**files:**
- `shared/home/openhands.nix` — OpenHands home-manager 模块
- `shared/home/default.nix` — 导入 openhands 模块

**action:**
1. 创建 `shared/home/openhands.nix` 定义 OpenHands 容器配置：
   - 镜像：`ghcr.io/openhands/openhands:latest`
   - 端口：`3000`
   - 环境变量：`LLM_MODEL`, `LLM_API_KEY`, `LLM_BASE_URL`
   - 卷挂载：`~/.openhands`, `~/openhands-workspace`
2. 在 `shared/home/default.nix` 中导入模块

**verify:**
- `nix eval .#darwin` 语法检查通过 ✓

**done:**
- OpenHands Nix 模块创建完成

---

### Task 2: 配置 Colima 资源 ✓

**files:**
- `darwin/home/colima.nix` — Colima home-manager 模块
- `darwin/home/zhaochanglong.nix` — 导入 colima 模块

**action:**
1. 创建 Colima home-manager 模块：
   - 安装 colima, docker, docker-compose 包
   - 配置 launchd agent 自动启动
   - 资源配置：8GB RAM, 4 CPUs, 100GB 磁盘

**verify:**
- Colima 资源配置符合 OpenHands 最低要求 ✓

**done:**
- Colima 配置已更新支持 OpenHands

---

### Task 3: 创建运行说明文档 ✓

**files:**
- `docs/openhands-run.md` — OpenHands 运行指南

**action:**
创建文档包含：
1. 前置条件检查（Colima 运行中）
2. 应用配置的命令
3. 访问 Web UI 的方式
4. 环境变量配置说明（LLM API Key 等）
5. 常见问题排查

**verify:**
- 文档包含完整的运行步骤 ✓
- 包含阿里百炼 LLM 配置示例 ✓

**done:**
- 用户可根据文档独立运行 OpenHands

---

## Must Haves (Verification Truths)

| Truth | How to Verify |
|-------|---------------|
| OpenHands 容器启动 | `docker ps` 显示容器运行中 |
| Web UI 可访问 | `curl http://localhost:3000` 返回 HTML |
| 卷挂载正常 | `docker exec openhands ls -la /workspace` 显示文件 |
| 环境变量传递 | `docker exec openhands env | grep LLM` 显示配置 |

---

## Key Links

- [OpenHands GitHub](https://github.com/OpenHands/OpenHands)
- [Colima GitHub](https://github.com/abiosoft/colima)
- 项目研究：`.planning/research/STACK.md`
- 项目陷阱：`.planning/research/PITFALLS.md`
