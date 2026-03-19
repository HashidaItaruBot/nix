# Roadmap: SSH Agent Forwarding 配置

**Created:** 2026-03-18
**Phases:** 3
**Requirements:** 8

---

## Phase 1: SSH 配置

**Goal:** 配置 SSH 服务端和客户端支持 Agent Forwarding

**Requirements:** SSHD-01, SSHD-02, MAC-01, MAC-02

**Success Criteria:**
1. SSH 连接后 `$SSH_AUTH_SOCK` 环境变量有值
2. `ssh-add -L` 在远程能列出本地密钥
3. 现有 SSH 安全设置未改变

**Plans:** 2 plans

Plans:
- [x] 01-01-PLAN.md — NixOS sshd 启用 AllowAgentForwarding (b70f8e5)
- [x] 01-02-PLAN.md — macOS SSH 配置 ForwardAgent for nixos (dfa77df)

---

## Phase 2: Git 签名配置

**Goal:** 配置 NixOS git 使用转发的 SSH agent 进行签名

**Requirements:** GIT-01, GIT-02

**Success Criteria:**
1. `git commit` 成功创建带签名的提交
2. 签名验证通过 `git verify-commit`

**Plans:** 1 plan

Plans:
- [x] 02-01-PLAN.md — 配置 git signer 使用 ssh-keygen (736c979)

---

### Phase 02.1: Fix SSH agent signing failure for git operations (INSERTED)

**Goal:** 验证和修复 SSH agent 基础的 git 签名配置
**Requirements**: GIT-01, GIT-02
**Depends on:** Phase 2
**Plans:** 1 plan

Plans:
- [x] 02.1-01-PLAN.md — 配置 ssh-keygen 使用 ~/.ssh/id_ed25519.pub 进行 SSH agent 签名

## Phase 3: 验证

**Goal:** 确保所有功能正常工作

**Requirements:** VER-01, VER-02, VER-03

**Success Criteria:**
1. git push 成功推送到远程仓库
2. git pull 成功拉取远程更改
3. git commit 创建的提交签名有效

**Plans:** 3 plans

---

## Phase Dependency

```
Phase 1 ──► Phase 2 ──► Phase 3
```

Phase 2 依赖 Phase 1 完成的 SSH agent forwarding。
Phase 3 验证整个流程。

---

## Progress Tracking

| Phase | Status | Plans | Progress |
|-------|--------|-------|----------|
| 1 | ● | 2/2 | 100% |
| 2 | ◐ | 1/1 | 100% |
| 3 | ○ | 0/3 | 0% |

**Overall:** 6/8 requirements complete

### Phase 4: 修复 git SSH 认证问题导致无法拉取远端分支

**Goal:** [To be planned]
**Requirements**: TBD
**Depends on:** Phase 3
**Plans:** 0 plans

Plans:
- [ ] TBD (run /gsd:plan-phase 4 to break down)

---
*Roadmap created: 2026-03-18*
*Plans created: 2026-03-18*
*Plan 01-01 completed: 2026-03-18*
*Plan 01-02 completed: 2026-03-18*
*Plan 02-01 completed: 2026-03-18*
