---
phase: "01"
slug: ssh
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-18
---

# Phase 01 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Nix eval / darwin-rebuild |
| **Config file** | `flake.nix` |
| **Quick run command** | `nix eval .#darwin --json` |
| **Full suite command** | `darwin-rebuild build --flake .#darwin` |
| **Estimated runtime** | ~30 seconds |

---

## Sampling Rate

- **After every task commit:** Run `nix eval .#darwin --json`
- **After every plan wave:** Run `darwin-rebuild build --flake .#darwin`
- **Before `/gsd:verify-work`:** Build must succeed
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 01-01-01 | 01 | 1 | SSHD-01 | build | `nix eval .#nixos` | ✅ | ⬜ pending |
| 01-01-02 | 01 | 1 | SSHD-02 | build | `nix eval .#nixos` | ✅ | ⬜ pending |
| 01-02-01 | 02 | 1 | MAC-01 | build | `nix eval .#darwin` | ✅ | ⬜ pending |
| 01-02-02 | 02 | 1 | MAC-02 | build | `nix eval .#darwin` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [x] Existing infrastructure covers all phase requirements.

Nix 配置项目不需要额外的测试框架。验证通过：
1. `nix eval` - 配置语法验证
2. `darwin-rebuild build` - 构建验证
3. 手动测试 - SSH Agent Forwarding 功能

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| SSH Agent Forwarding | SSHD-01, SSHD-02, MAC-01, MAC-02 | 需要真实 SSH 连接和 1Password agent | 1. 在 macOS 上启动 1Password 并解锁<br>2. `ssh nixos` 连接到 NixOS<br>3. `echo $SSH_AUTH_SOCK` 应显示 socket 路径<br>4. `ssh-add -L` 应列出本地密钥 |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending