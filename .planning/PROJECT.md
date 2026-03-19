# SSH Agent Forwarding 配置

## What This Is

为 macOS 配置 SSH agent forwarding，使其通过 SSH 连接到 NixOS 时能够使用本地 1Password 的 SSH 密钥。

## Core Value

让 NixOS 上的 git 操作（push/pull/commit 签名）能够无缝使用 macOS 上的 1Password SSH 密钥。

## Requirements

### Validated (v1.0 — 2026-03-19)

- ✓ macOS SSH 配置启用 ForwardAgent — v1.0
- ✓ NixOS SSH 配置允许 agent forwarding — v1.0
- ✓ 验证 git push/pull 能正常使用转发密钥 — v1.0
- ✓ 验证 git commit SSH 签名能正常工作 — v1.0

### Active

- [ ] Phase 4: 修复 git SSH 认证问题导致无法拉取远端分支 (TBD)

### Out of Scope

- 配置新的 SSH 密钥 — 使用现有 1Password 中的密钥
- 配置 1Password SSH agent — 已配置完成
- 在 NixOS 上安装 1Password — 非 SSH Agent Forwarding 方案

## Current State (after v1.0)

**Shipped:** 2026-03-19

**Delivered:**
- NixOS sshd 启用 AllowAgentForwarding
- macOS SSH 客户端为 nixos 主机配置 ForwardAgent=true
- NixOS git 配置使用 ssh-keygen 进行 SSH 签名
- 所有 9 个 v1 requirements 验证通过

**Codebase:**
- 3,162 LOC Nix
- Key files: `nixos/sshd.nix`, `darwin/home/ssh.nix`, `nixos/home/git.nix`, `nixos/home/ssh.nix`

**Known Issues:**
- Phase 01 缺少完整的 Nyquist VALIDATION.md (可在 v1.1 补充)

## Context

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
| 使用 SSH Agent Forwarding | 1Password 无法在远程 NixOS 上运行，必须转发本地 agent | ✓ Good |
| 使用 ssh-keygen 代替 op-ssh-sign | ssh-keygen 支持 SSH agent forwarding，op-ssh-sign 不支持 | ✓ Good |
| NixOS SSH 不设置 IdentityAgent | 让 SSH 使用默认的 $SSH_AUTH_SOCK (从 macOS 转发) | ✓ Good |
| 平台特定的 git signer 配置 | nixos/home/git.nix 覆盖 signer，shared/home/git.nix 保留基础配置 | ✓ Good |

---

*Last updated: 2026-03-19 after v1.0 milestone*
