# Nix 配置项目

## What This Is

使用 Nix 声明式管理系统配置的 Flake 项目。支持 NixOS 和 macOS Darwin 双平台，通过 home-manager 管理用户环境。

**v1.3 新增：** 在 macOS 上使用 Colima 运行 OpenHands（AI 编程助手），通过 Web UI 访问，配置阿里百炼 LLM 后端。

## Core Value

所有系统配置和软件包管理必须通过修改 Nix 配置文件完成，完全声明式，可复现。

## Requirements

### Validated (v1.0 — 2026-03-19)

- ✓ macOS SSH 配置启用 ForwardAgent — v1.0
- ✓ NixOS SSH 配置允许 agent forwarding — v1.0
- ✓ 验证 git push/pull 能正常使用转发密钥 — v1.0
- ✓ 验证 git commit SSH 签名能正常工作 — v1.0

### Active (v1.1)

- [ ] 在 NixOS 上创建 MicroVM 运行 openclaw
- [ ] MicroVM 权限隔离（沙盒化）
- [ ] MicroVM 持久化存储
- [ ] MicroVM 网络访问（对外提供服务）
- [ ] MicroVM 开机自动启动

### Out of Scope

- MicroVM 与宿主机共享 SSH 密钥 — 不需要，MicroVM 独立运行
- macOS 平台 — 仅针对 NixOS

## Context

### 使用场景

1. openclaw 服务在隔离的 MicroVM 中运行
2. MicroVM 具有持久化存储，数据不会丢失
3. MicroVM 可以对外提供网络服务
4. 系统启动时 MicroVM 自动运行

## Constraints

- **平台**: 仅针对 NixOS
- **声明式**: 所有配置通过 Nix 配置文件管理
- **隔离性**: MicroVM 必须与宿主机隔离（不共享 SSH 密钥）

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| 使用 SSH Agent Forwarding | 1Password 无法在远程 NixOS 上运行，必须转发本地 agent | ✓ Good |
| 使用 ssh-keygen 代替 op-ssh-sign | ssh-keygen 支持 SSH agent forwarding，op-ssh-sign 不支持 | ✓ Good |
| NixOS SSH 不设置 IdentityAgent | 让 SSH 使用默认的 $SSH_AUTH_SOCK (从 macOS 转发) | ✓ Good |
| 平台特定的 git signer 配置 | nixos/home/git.nix 覆盖 signer，shared/home/git.nix 保留基础配置 | ✓ Good |

---

*Last updated: 2026-03-19 after v1.0, starting v1.1 MicroVM*
