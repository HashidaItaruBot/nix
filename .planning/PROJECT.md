# SSH Agent Forwarding 配置

## What This Is

为 macOS 配置 SSH agent forwarding，使其通过 SSH 连接到 NixOS 时能够使用本地 1Password 的 SSH 密钥。用于解决 macOS 远程连接 NixOS 后无法使用 NixOS 上的 1Password 的问题。

## Core Value

让 NixOS 上的 git 操作（push/pull/commit 签名）能够无缝使用 macOS 上的 1Password SSH 密钥。

## Requirements

### Validated

(N/A — 新功能配置)

### Active

- [ ] macOS SSH 配置启用 ForwardAgent
- [ ] NixOS SSH 配置允许 agent forwarding
- [ ] 验证 git push/pull 能正常使用转发密钥
- [ ] 验证 git commit SSH 签名能正常工作

### Out of Scope

- 配置新的 SSH 密钥 — 使用现有 1Password 中的密钥
- 配置 1Password SSH agent — 已配置完成
- 配置 NixOS git 签名 — 已配置完成

## Context

### 已有状态

- macOS 上 1Password SSH agent 已配置，本地可用
- NixOS 上 git commit SSH 签名已配置
- 使用 `ssh user@host` 方式连接

### 使用场景

1. macOS 用户通过 SSH 连接到 NixOS 系统
2. 在 NixOS 上执行 `git push`/`git pull` 时需要 SSH 认证
3. 在 NixOS 上执行 `git commit` 时需要 SSH 签名
4. 所有密钥操作通过 macOS 的 1Password 完成

## Constraints

- **兼容性**: 必须兼容现有 Nix 配置结构（darwin/nixos 分离）
- **安全**: 只转发到指定的 NixOS 主机，不全局开启
- **声明式**: 所有配置通过 Nix 配置文件管理

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| 使用 SSH Agent Forwarding | 1Password 无法在远程 NixOS 上运行，必须转发本地 agent | — Pending |

---
*Last updated: 2026-03-18 after initialization*