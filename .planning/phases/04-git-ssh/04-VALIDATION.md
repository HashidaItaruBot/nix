---
phase: 4
slug: git-ssh
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-20
---

# Phase 4 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Manual verification checklist (no formal test framework) |
| **Config file** | N/A |
| **Quick run command** | Manual CLI commands (< 30 seconds each) |
| **Full suite command** | Full validation checklist from CONTEXT.md success criteria |
| **Estimated runtime** | ~2-3 minutes |

---

## Sampling Rate

- **After every task commit:** Manual verification of individual commands
- **After every plan wave:** Run full validation checklist
- **Before `/gsd:verify-work`:** All 5 success criteria must pass
- **Max feedback latency:** ~30 seconds per command

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 04-01-01 | 01 | 1 | COLIMA-01 | CLI check | `colima --version` | ❌ Wave 0 | ⬜ pending |
| 04-02-01 | 02 | 2 | COLIMA-02, COLIMA-03 | State check | `colima list` | ❌ Wave 0 | ⬜ pending |
| 04-02-02 | 02 | 2 | COLIMA-04 | Config check | `launchctl list \| grep colima` | ❌ Wave 0 | ⬜ pending |
| 04-03-01 | 03 | 3 | COLIMA-05 | Integration | `docker run --rm hello-world` | ❌ Wave 0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] Manual verification checklist — covers all COLIMA-XX requirements
- [ ] `darwin/home/colima.nix` — Colima home-manager module (new)
- [ ] `darwin/packages/default.nix` — add colima cask

*If none: "Existing infrastructure covers all phase requirements."*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| VM 正在运行 | COLIMA-03 | State verification requires human review | `colima list` — check "Running" status |
| VM 资源配置 (8GB RAM, 4 CPUs, 100GB disk) | COLIMA-03 | Configuration review | `colima list` output shows CPUS, MEMORY, DISK columns |
| launchd 自动启动配置 | COLIMA-04 | System service status | `launchctl list \| grep colima` confirms agent loaded |
| 可运行容器 | COLIMA-05 | Integration test | `docker run --rm hello-world` outputs "Hello from Docker!" |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending

---

## Wave 0 Gaps (from RESEARCH.md)

- [ ] Manual verification checklist — 覆盖所有 COLIMA-XX 要求的验证步骤
- [ ] `darwin/home/colima.nix` — Colima home-manager 模块（新建）
- [ ] `darwin/packages/default.nix` — 添加 colima cask
