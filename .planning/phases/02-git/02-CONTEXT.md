# Phase 2: Git 签名配置 - Context

**Gathered:** 2026-03-18
**Status:** Ready for planning

<domain>
## Phase Boundary

配置 NixOS git 使用转发的 SSH agent 进行签名。Phase 1 已完成 SSH Agent Forwarding 配置，本阶段修改 git signer 使其能够使用远程转发的密钥。

</domain>

<decisions>
## Implementation Decisions

### 签名器实现方式
- 使用 `ssh-keygen -Y sign` 作为 git signer
- 不创建包装脚本，直接配置 git 使用 ssh-keygen
- ssh-keygen 会自动使用 SSH_AUTH_SOCK 中的 agent

### 错误处理策略
- SSH_AUTH_SOCK 不可用时直接报错退出
- 不尝试回退到其他签名器（NixOS 通常不安装 1Password）
- 报错信息会明确提示用户需要通过 SSH agent forwarding 连接

### 配置位置安排
- 只在 `nixos/home/git.nix` 中设置 signer
- 保持 `shared/home/git.nix` 不变（darwin 继续使用 op-ssh-sign）
- NixOS 配置覆盖 shared 配置，实现平台隔离

### 密钥管理方式
- 签名公钥保持硬编码在配置中
- 当前使用 `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP5M2RGhIG1CslAdzx+1xcOFiAgJhw0FKFqhe/Wkm1qZ`
- 无需动态获取或配置化

### Claude's Discretion
- 具体的 git signing.signer 路径配置方式（使用 `lib.getExe` 或直接路径）
- 是否需要显式设置 `SSH_AUTH_SOCK` 环境变量检查

</decisions>

<canonical_refs>
## Canonical References

### Git SSH 签名
- `.planning/REQUIREMENTS.md` — GIT-01, GIT-02 需求定义
- `.planning/STATE.md` — 已确定的技术决策：使用 ssh-keygen -Y sign 代替 op-ssh-sign

### 相关代码
- `nixos/home/git.nix` — 当前 NixOS git 配置，需要添加 signer 设置
- `shared/home/git.nix` — shared 配置，NixOS 需要覆盖其 signer 设置

</canonical_refs>

<code_context>
## Existing Code Insights

### 当前配置结构
- `nixos/home/git.nix`: 已设置 signing.key, signing.format="ssh", signing.signByDefault=true
- `shared/home/git.nix`: 设置 `signer = op-ssh-sign`（被 darwin 继承）
- `darwin/home/git.nix`: 覆盖 signer 为 macOS 1Password 路径

### 需要修改
- `nixos/home/git.nix`: 添加 `programs.git.signing.signer` 设置为 ssh-keygen 路径
- NixOS home-manager 配置会自动合并 shared 配置，后面的设置会覆盖前面的

### Integration Points
- NixOS git 配置在 `nixos/home/default.nix` 中导入
- shared git 配置在全局 home-manager 配置中导入

</code_context>

<specifics>
## Specific Ideas

- "SSH agent forwarding 支持 ssh-keygen 但不支持 op-ssh-sign" — 这是核心约束
- 目标是让 git commit 签名在远程 NixOS 上能够使用 macOS 的 1Password 密钥

</specifics>

<deferred>
## Deferred Ideas

None — 讨论保持在 Phase 范围内

</deferred>

---

*Phase: 02-git*
*Context gathered: 2026-03-18*