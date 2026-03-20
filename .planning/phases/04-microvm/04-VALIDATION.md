---
phase: 4
slug: microvm
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
| **Framework** | NixOS VM tests (built-in) |
| **Config file** | None — use `nix build` evaluation |
| **Quick run command** | `nix build .#nixosConfigurations.nixos` |
| **Full suite command** | `nix build .#nixosConfigurations.nixos` |
| **Estimated runtime** | ~30 seconds |

---

## Sampling Rate

- **After every task commit:** Run `nix build .#nixosConfigurations.nixos` (eval only)
- **After every plan wave:** Run `nix build .#nixosConfigurations.nixos` (full build)
- **Before `/gsd:verify-work`:** Full build + MicroVM start test
- **Max feedback latency:** ~30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 04-01-01 | 01 | 1 | MIC-01 | build | `nix build .#nixosConfigurations.nixos` | ❌ W0 | ⬜ pending |
| 04-01-02 | 01 | 1 | MIC-03 | eval | `nix eval '.#nixosConfigurations.nixos.config.microvm.vms.openclaw.config.microvm.hypervisor'` | ❌ W0 | ⬜ pending |
| 04-01-03 | 01 | 1 | MIC-04 | eval | `nix eval '.#nixosConfigurations.nixos.config.microvm.vms.openclaw.config.microvm.mem'` | ❌ W0 | ⬜ pending |
| 04-02-01 | 02 | 2 | MIC-02 | manual | `systemctl start microvm-openclaw` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `nixos/microvm/default.nix` — host 模块配置
- [ ] `nixos/microvm/openclaw.nix` — guest 配置
- [ ] `nixos/default.nix` — 更新导入 `./microvm`
- [ ] 验证命令：`nix build .#nixosConfigurations.nixos`

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| MicroVM 可启动 | MIC-02 | 需要实际运行 MicroVM | `systemctl start microvm-openclaw` 并观察启动日志 |
| 可通过 console 访问 | MIC-02 | 需要人工验证连接 | `microvm-console openclaw` 检查是否可登录 |

---

## Validation Sign-Off

- [ ] All tasks have automated verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
