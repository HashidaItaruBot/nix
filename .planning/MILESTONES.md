# MILESTONES

## v1.0 — SSH Agent Forwarding 配置

**Shipped:** 2026-03-19
**Phases:** 1-3 | **Plans:** 4 | **Tasks:** 4

### Overview

为 macOS 配置 SSH agent forwarding，使其通过 SSH 连接到 NixOS 时能够使用本地 1Password 的 SSH 密钥。

### Key Accomplishments

1. **NixOS SSH 服务器启用 AllowAgentForwarding** — 允许远程客户端转发 SSH agent
2. **macOS SSH 客户端配置 ForwardAgent** — 为 nixos 主机启用 agent 转发
3. **NixOS git 配置使用 ssh-keygen** — 替代 op-ssh-sign，支持 SSH agent 转发
4. **所有验证测试通过** — SSH_AUTH_SOCK 转发、git push/pull 认证、git commit 签名全部正常

### Statistics

| Metric | Value |
|--------|-------|
| Timeline | 2026-03-18 → 2026-03-19 (2 days) |
| Files modified | 4 (nixos/sshd.nix, darwin/home/ssh.nix, nixos/home/git.nix, nixos/home/ssh.nix) |
| Requirements | 9/9 complete |
| Audit status | PASSED |

### Known Gaps

None — all v1 requirements satisfied.

### Archive

- `.planning/milestones/v1.0-ROADMAP.md` — Full phase details
- `.planning/milestones/v1.0-REQUIREMENTS.md` — Requirements with outcomes
- `.planning/milestones/v1.0-MILESTONE-AUDIT.md` — Audit report

---

## v1.1 — (Not started)

---

*For current roadmap, see .planning/ROADMAP.md*
