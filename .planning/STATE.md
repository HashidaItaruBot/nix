# STATE.md

**Project:** SSH Agent Forwarding 配置
**Updated:** 2026-03-18T15:18:15Z

---

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-18)

**Core value:** 让 NixOS 上的 git 操作能够无缝使用 macOS 上的 1Password SSH 密钥
**Current focus:** Phase 1 - SSH 配置 (Complete)

---

## Milestone: v1.0

**Status:** In Progress
**Started:** 2026-03-18

### Phase Progress

| Phase | Name | Status | Plans Complete |
|-------|------|--------|----------------|
| 1 | SSH 配置 | ● Complete | 2/2 |
| 2 | Git 签名配置 | ○ Pending | 0/2 |
| 3 | 验证 | ○ Pending | 0/3 |

### Current Phase

**Phase 1: SSH 配置** (All plans complete)

- [x] Plan 01: 修改 `nixos/sshd.nix` 添加 AllowAgentForwarding **DONE** (b70f8e5)
- [x] Plan 02: 修改 `darwin/home/ssh.nix` 添加 ForwardAgent **DONE** (dfa77df)

### Next Action

Phase 1 complete. Ready for Phase 2: Git 签名配置.

---

## Requirements Status

| Category | Total | Complete | Pending |
|----------|-------|----------|---------|
| SSHD | 2 | 2 | 0 |
| MAC | 2 | 2 | 0 |
| GIT | 2 | 0 | 2 |
| VER | 2 | 0 | 2 |
| **Total** | 8 | 4 | 4 |

---

## Key Files

| File | Purpose |
|------|---------|
| `nixos/sshd.nix` | NixOS SSH 服务器配置 |
| `darwin/home/ssh.nix` | macOS SSH 客户端配置 |
| `nixos/home/git.nix` | NixOS git 签名配置 |
| `shared/home/git.nix` | 共享 git 配置 |

---

## Decisions Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-03-18 | 使用 ssh-keygen -Y sign 代替 op-ssh-sign | SSH agent forwarding 支持 ssh-keygen 但不支持 op-ssh-sign |
| 2026-03-18 | AllowAgentForwarding 放在 AuthorizedKeysFile 之后 | 保持设置的逻辑分组 |
| 2026-03-18 | macOS SSH config uses matchBlocks with forwardAgent=true for nixos host | Enables agent forwarding while preserving 1Password agent socket |

---

## Session Log

| Timestamp | Action |
|-----------|--------|
| 2026-03-18 | Plan 01-01 completed (b70f8e5) |
| 2026-03-18T15:16:32Z | Started 01-02-PLAN.md execution |
| 2026-03-18T15:18:15Z | Completed 01-02-PLAN.md (dfa77df) |

---
*State initialized: 2026-03-18*
*Plans created: 2026-03-18*
*Plan 01-01 completed: 2026-03-18*
*Plan 01-02 completed: 2026-03-18*