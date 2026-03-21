# Phase 8: OpenHands AI 助手 - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-03-21
**Phase:** 08-nixos-openhands-ai
**Areas discussed:** 架构变更动机, 容器运行时, 网络, 存储, 密钥, LLM 后端, 资源配置

---

## 架构变更动机

| Option | Description | Selected |
|--------|-------------|----------|
| 隔离性 | 容器提供额外的隔离层，增强安全性 | ✓ |
| 学习目的 | 尝试新技术，学习 nixos-container 用法 | |
| 架构统一 | 与 MicroVM 方案（Phase 4-7）保持架构一致性 | |
| 其他 | 其他原因 | |

**User's choice:** 隔离性
**Notes:** 用户希望增强安全隔离，选择 nixos-container 作为外层隔离

---

## 容器运行时

| Option | Description | Selected |
|--------|-------------|----------|
| 嵌套 Podman | 容器内运行 Podman，完全自包含，但架构复杂 | |
| Socket 透传 | 将宿主机的 Podman socket 挂载到容器内 | |
| 替代沙箱 | 在容器内使用 systemd-nspawn 或其他轻量隔离 | |
| **Docker** | 容器内运行 Docker，OpenHands 官方兼容 | ✓ |

**User's choice:** Docker (用户补充说明)
**Notes:** 用户明确要求使用 Docker 而非 Podman，以获得更好的 OpenHands 兼容性

---

## 网络配置

| Option | Description | Selected |
|--------|-------------|----------|
| 桥接网络 | 容器获得独立 IP，与宿主机同一网段 | |
| NAT 端口转发 | 使用 NAT，宿主机端口转发到容器 | ✓ |

**User's choice:** NAT 端口转发
**Notes:** 配置更简单，宿主机端口 3000 转发到容器端口 3000

---

## 数据持久化

| Option | Description | Selected |
|--------|-------------|----------|
| 宿主机目录 | 使用 bind mount 挂载宿主机目录 | ✓ |
| 容器卷 | 使用 NixOS ephemeralRoot 块设备 | |

**User's choice:** 宿主机目录
**Notes:** 数据存储在 `/var/lib/openhands`

---

## 密钥管理

| Option | Description | Selected |
|--------|-------------|----------|
| SOPS 加密 | 使用 sops-nix 加密，密钥文件挂载到容器内 | ✓ |
| 环境变量 | 容器环境变量直接配置，简单但不安全 | |
| 容器内 SOPS | 在容器内使用 agenix 或其他方案 | |

**User's choice:** SOPS 加密
**Notes:** 使用 sops-nix 加密 LLM API 密钥

---

## LLM 后端

| Option | Description | Selected |
|--------|-------------|----------|
| Claude API | 使用 Claude API，配置 ANTHROPIC_API_KEY | |
| Ollama 本地 | 使用本地 Ollama 实例 | |
| OpenAI 兼容 | 使用 OpenAI 兼容 API | ✓ |

**User's choice:** OpenAI 兼容

**Provider 选择:**

| Option | Description | Selected |
|--------|-------------|----------|
| 阿里百炼 | 阿里云百炼 Qwen 模型，国内访问稳定 | ✓ |
| DeepSeek | DeepSeek V3/R1，性价比高 | |
| 其他服务 | 其他 OpenAI 兼容服务 | |

**User's choice:** 阿里百炼
**Notes:** 配置 `LLM_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1`

---

## 资源配置

| Option | Description | Selected |
|--------|-------------|----------|
| 轻量配置 | 2GB 内存，2 核 CPU | |
| 标准配置 | 4GB 内存，4 核 CPU | ✓ |
| 高配 | 8GB 内存，8 核 CPU | |

**User's choice:** 标准配置
**Notes:** 适合日常开发使用

---

## Claude's Discretion

- OpenHands 镜像版本选择 (latest 或特定版本)
- 具体的 Qwen 模型选择 (qwen-plus / qwen-turbo / qwen-max)
- 防火墙配置细节
- 日志轮转配置

---

## Deferred Ideas

无 — 讨论保持在 Phase 范围内

---

*Discussion completed: 2026-03-21*