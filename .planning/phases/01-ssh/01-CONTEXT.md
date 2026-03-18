# Phase 1: SSH 配置 - Context

**Gathered:** 2026-03-18
**Status:** Ready for planning

<domain>
## Phase Boundary

配置 SSH 服务端和客户端支持 Agent Forwarding。使得 macOS 通过 SSH 连接到 NixOS 时，能够转发本地的 1Password SSH agent，用于远程的 git 认证和签名操作。

</domain>

<decisions>
## Implementation Decisions

### NixOS SSH Server 配置
- 在 `nixos/sshd.nix` 中添加 `AllowAgentForwarding = true`
- 保持现有安全设置不变（禁用密码登录、禁用 root 登录、仅公钥认证）

### macOS SSH Client 配置
- 使用 Host 别名 `nixos` 标识目标主机
- 为该主机单独创建 matchBlock，启用 `ForwardAgent yes`
- 保持现有 `*` matchBlock 用于 1Password agent socket 配置

### 连接信息
- Host 别名：`nixos`
- IP 地址：`172.24.2.76`
- 用户名：`zhaochanglong`
- SSH 端口：`22`（默认，无需显式指定）

### Claude's Discretion
- 具体的 Nix 配置语法细节
- matchBlock 中是否同时配置 hostname 和 user
- 配置文件的导入和合并方式

</decisions>

<specifics>
## Specific Ideas

- 使用 Host 别名方便记忆和使用
- 只转发到指定的 NixOS 主机，不全局开启（安全考量）

</specifics>

<canonical_refs>
## Canonical References

### SSH Agent Forwarding
- `PROJECT.md` — 约束：只转发到指定主机，声明式配置
- `REQUIREMENTS.md` — SSHD-01, SSHD-02, MAC-01, MAC-02 需求定义

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `nixos/sshd.nix` — 已有 SSH 服务端配置框架，需添加 AllowAgentForwarding
- `darwin/home/ssh.nix` — 已有 1Password agent socket 配置，需添加 ForwardAgent matchBlock
- `shared/home/ssh.nix` — 共享的 SSH 基础配置（GitHub via port 443）

### Established Patterns
- 使用 `programs.ssh.matchBlocks` 配置 SSH 主机
- 使用 `services.openssh.settings` 配置 SSH 服务端

### Integration Points
- `darwin/home/ssh.nix` 与 `shared/home/ssh.nix` 合并形成完整 SSH 配置
- `nixos/sshd.nix` 作为系统级服务配置

</code_context>

<deferred>
## Deferred Ideas

None — 讨论保持在阶段范围内

</deferred>

---

*Phase: 01-ssh*
*Context gathered: 2026-03-18*