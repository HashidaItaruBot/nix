---
phase: 09
slug: nixos-vllm-gpu
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-03-26
---

# Phase 09 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | systemd service + curl |
| **Config file** | nixos/containers/vllm.nix |
| **Quick run command** | `curl -s http://localhost:8000/v1/models` |
| **Full suite command** | `curl -s http://localhost:8000/v1/models && curl -s -X POST http://localhost:8000/v1/chat/completions -H "Content-Type: application/json" -d '{"model": "Qwen2.5-7B-Instruct", "messages": [{"role": "user", "content": "hi"}]}'` |
| **Estimated runtime** | ~10 seconds |

---

## Sampling Rate

- **After every task commit:** Run `grep -q "systemd.services.vllm" nixos/containers/vllm.nix`
- **After every plan wave:** Run `curl -s http://localhost:8000/v1/models`
- **Before `/gsd:verify-work`:** Full API test must pass
- **Max feedback latency:** 10 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 09-01-01 | 01 | 1 | VLLM-02 | unit | `grep -q '"render"' nixos/default.nix` | ✅ W0 | ⬜ pending |
| 09-01-02 | 01 | 1 | VLLM-01, VLLM-02 | integration | `grep -q "systemd.services.vllm" nixos/containers/vllm.nix` | ❌ W0 | ⬜ pending |
| 09-01-03 | 01 | 1 | VLLM-05 | unit | `grep -q "./vllm.nix" nixos/containers/default.nix` | ❌ W0 | ⬜ pending |
| 09-02-01 | 02 | 2 | VLLM-04 | checkpoint | (human gate for model files) | N/A | ⬜ pending |
| 09-02-02 | 02 | 2 | VLLM-01, VLLM-03 | integration | `systemctl is-active vllm` | N/A | ⬜ pending |
| 09-02-03 | 02 | 2 | VLLM-03, VLLM-04 | e2e | `curl -s http://localhost:8000/v1/models` | N/A | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [x] `nixos/containers/vllm.nix` — Created by Plan 01 Task 02
- [x] `/var/lib/vllm/models` — Created by Plan 01 Task 02 (tmpfiles)
- [x] `/var/lib/vllm/cache` — Created by Plan 01 Task 02 (tmpfiles)
- [x] GPU architecture confirmation — User must verify via `rocminfo`

*Wave 0 files are created by Plan 01 execution - this is valid.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| GPU 架构确认 | VLLM-02 | 需要物理检查硬件 | 运行 `rocminfo` 查看输出 |
| 模型下载 | VLLM-04 | 需要手动获取模型 | 确认模型文件存在于 `/var/lib/vllm/models` |
| 推理质量 | VLLM-04 | 需要人工评估 | 使用 OpenAI API 调用并检查响应质量 |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 10s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** 2026-03-26