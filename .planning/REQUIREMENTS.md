# Requirements: SSH Agent Forwarding 配置

**Defined:** 2026-03-18
**Core Value:** 让 NixOS 上的 git 操作能够无缝使用 macOS 上的 1Password SSH 密钥

## v1 Requirements

### NixOS SSH Server

- [x] **SSHD-01**: NixOS sshd 启用 AllowAgentForwarding
- [x] **SSHD-02**: NixOS sshd 配置正确保留现有安全设置

### macOS SSH Client

- [x] **MAC-01**: macOS SSH 配置为 NixOS 主机启用 ForwardAgent
- [x] **MAC-02**: macOS SSH 配置保持使用 1Password agent socket

### Git 签名

- [x] **GIT-01**: NixOS git signer 改用 ssh-keygen -Y sign
- [x] **GIT-02**: 创建签名脚本，使用 SSH agent 中的密钥

### 验证

- [x] **VER-01**: SSH 连接后验证 SSH_AUTH_SOCK 可用
- [x] **VER-02**: git push/pull 认证正常工作
- [x] **VER-03**: git commit 签名正常工作

## v2 Requirements

(无 — 保持范围聚焦)

## Out of Scope

| Feature | Reason |
|---------|--------|
| 配置新的 SSH 密钥 | 使用现有 1Password 中的密钥 |
| 配置 1Password SSH agent | 已配置完成 |
| NixOS 上安装 1Password | 非 SSH Agent Forwarding 方案 |
| 配置多个 NixOS 主机 | 先实现单一主机，后续可扩展 |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| SSHD-01 | Phase 1 | Complete |
| SSHD-02 | Phase 1 | Complete |
| MAC-01 | Phase 1 | Complete |
| MAC-02 | Phase 1 | Complete |
| GIT-01 | Phase 2 | Complete |
| GIT-02 | Phase 2 | Complete |
| VER-01 | Phase 3 | Complete |
| VER-02 | Phase 3 | Complete |
| VER-03 | Phase 3 | Complete |

**Coverage:**
- v1 requirements: 9 total (added VER-01, VER-02, VER-03)
- Mapped to phases: 9
- Unmapped: 0 ✓
- Complete: 9/9 ✓

---
*Requirements defined: 2026-03-18*