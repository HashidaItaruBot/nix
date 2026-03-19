# Roadmap: SSH Agent Forwarding 配置

**Created:** 2026-03-18
**Current Milestone:** v1.0 ✅ SHIPPED

---

## Milestones

- ✅ **v1.0 SSH Agent Forwarding** — Phases 1-3 (shipped 2026-03-19)
- 📋 **v1.1 Enhancements** — Phase 4+ (planned)

---

## Phases

<details>
<summary>✅ v1.0 SSH Agent Forwarding (Phases 1-3) — SHIPPED 2026-03-19</summary>

### Phase 1: SSH 配置

**Goal:** 配置 SSH 服务端和客户端支持 Agent Forwarding

**Requirements:** SSHD-01, SSHD-02, MAC-01, MAC-02

**Plans:** 2 plans

Plans:
- [x] 01-01-PLAN.md — NixOS sshd 启用 AllowAgentForwarding (b70f8e5)
- [x] 01-02-PLAN.md — macOS SSH 配置 ForwardAgent for nixos (dfa77df)

---

### Phase 2: Git 签名配置

**Goal:** 配置 NixOS git 使用转发的 SSH agent 进行签名

**Requirements:** GIT-01, GIT-02

**Plans:** 1 plan

Plans:
- [x] 02-01-PLAN.md — 配置 git signer 使用 ssh-keygen (736c979)

---

### Phase 02.1: Fix SSH agent signing failure for git operations (INSERTED)

**Goal:** 验证和修复 SSH agent 基础的 git 签名配置
**Requirements:** GIT-01, GIT-02
**Depends on:** Phase 2
**Plans:** 1 plan

Plans:
- [x] 02.1-01-PLAN.md — 配置 ssh-keygen 使用 ~/.ssh/id_ed25519.pub 进行 SSH agent 签名

---

### Phase 3: 验证

**Goal:** 确保所有功能正常工作

**Requirements:** VER-01, VER-02, VER-03

**Plans:** 1 plan

Plans:
- [x] 03-01-PLAN.md — 验证 SSH Agent Forwarding 和 Git 签名 (VER-01/VER-02/VER-03 passed)

---

**Phase Dependency:**
```
Phase 1 ──► Phase 2 ──► Phase 3
```

</details>

---

### v1.1 Enhancements (Planned)

#### Phase 4: 修复 git SSH 认证问题导致无法拉取远端分支

**Goal:** [To be planned]
**Requirements:** TBD
**Depends on:** Phase 3
**Plans:** 0 plans

Plans:
- [ ] TBD (run /gsd:plan-phase 4 to break down)

---

## Progress Tracking

| Phase | Milestone | Status | Plans | Progress |
|-------|-----------|--------|-------|----------|
| 1 | v1.0 | ✅ Complete | 2/2 | 100% |
| 2 | v1.0 | ✅ Complete | 1/1 | 100% |
| 02.1 | v1.0 | ✅ Complete | 1/1 | 100% |
| 3 | v1.0 | ✅ Complete | 1/1 | 100% |
| 4 | v1.1 | 📋 Planned | 0/0 | 0% |

**Overall:** v1.0 shipped — 9/9 requirements complete

---

*Roadmap created: 2026-03-18*
*v1.0 shipped: 2026-03-19*
*See .planning/milestones/v1.0-ROADMAP.md for full v1.0 details*
