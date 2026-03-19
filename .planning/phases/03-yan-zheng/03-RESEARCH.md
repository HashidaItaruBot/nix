# Phase 3: 验证 - Research

**Researched:** 2026-03-19
**Domain:** SSH Agent Forwarding Verification, Git SSH Signatures
**Confidence:** HIGH

## Summary

Phase 3 validates that the SSH Agent Forwarding configuration from Phase 1 and Git signing configuration from Phase 2 work correctly together. This phase focuses on three verification requirements:

1. **VER-01**: SSH connection后验证 SSH_AUTH_SOCK 可用
2. **VER-02**: git push/pull 认证正常工作
3. **VER-03**: git commit 创建的提交签名有效

The verification flow is sequential: first verify agent forwarding works (VER-01), then verify git remote operations succeed (VER-02), and finally verify commit signatures are valid (VER-03).

**Primary recommendation:** Execute verification commands in order on NixOS system after SSH connection from macOS; all verification is manual since it requires live SSH session with agent forwarding.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
None - Phase 3 is verification only, no configuration decisions.

### Claude's Discretion
- Verification command design
- Test script structure (if any)
- Error handling approach

### Deferred Ideas (OUT OF SCOPE)
None
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| VER-01 | SSH 连接后验证 SSH_AUTH_SOCK 可用 | `echo $SSH_AUTH_SOCK` shows socket path; `ssh-add -L` lists forwarded keys from 1Password agent |
| VER-02 | git push/pull 认证正常工作 | `git fetch origin` and `git push` succeed without authentication errors |
| VER-03 | git commit 签名正常工作 | `git commit --allow-empty -m "test"` creates signed commit; `git log --show-signature -1` shows "Good signature" |
</phase_requirements>

## Standard Stack

### Core
| Tool/Command | Purpose | Why Standard |
|--------------|---------|--------------|
| `ssh-add -L` | Lists public keys in SSH agent | Standard OpenSSH command to verify agent has keys |
| `echo $SSH_AUTH_SOCK` | Shows SSH agent socket path | Standard environment variable for agent location |
| `git log --show-signature` | Shows commit signature status | Built-in git signature verification |
| `git verify-commit` | Verifies commit signature | Official git signature verification command |

### Supporting
| Command | Purpose | When to Use |
|---------|---------|-------------|
| `ssh-keygen -Y verify` | Verify SSH signature manually | Debug signature issues |
| `git fetch/push/pull` | Test remote authentication | VER-02 verification |
| `git commit --allow-empty` | Create test commit | VER-03 verification without code changes |

### Installation
All commands are built-in to OpenSSH and Git, already available via Nixpkgs.

## Architecture Patterns

### Verification Flow

```
┌────────────────────┐     ┌─────────────────────┐     ┌───────────────────┐
│ macOS SSH Client   │────▶│ NixOS SSH Server    │────▶│ Verification      │
│ (1Password agent)  │     │ (AllowAgentForward) │     │ Commands          │
└────────────────────┘     └─────────────────────┘     └───────────────────┘
         │                           │                          │
         │  ForwardAgent: yes        │  SSH_AUTH_SOCK set      │  ssh-add -L
         │  (Phase 1 config)         │  (automatic)            │  git fetch
         │                           │                         │  git log --show-signature
```

### VER-01: SSH Agent Forwarding Verification

**What to check:**
1. `$SSH_AUTH_SOCK` environment variable is set after SSH connection
2. `ssh-add -L` outputs the public key from 1Password agent

**Expected output:**
```bash
# On NixOS after SSH from macOS
$ echo $SSH_AUTH_SOCK
/tmp/ssh-XXXXXX/agent.1234

$ ssh-add -L
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP5M2RGhIG1CslAdzx+1xcOFiAgJhw0FKFqhe/Wkm1qZ
```

**Failure output:**
```bash
$ ssh-add -L
Could not open a connection to your authentication agent: No such file or directory
```

### VER-02: Git Remote Authentication Verification

**What to check:**
1. `git fetch origin` succeeds without password prompt
2. `git push` succeeds (or reports "Everything up-to-date")

**Expected output:**
```bash
$ git fetch origin
# (no output = success)

$ git push
Everything up-to-date
```

**Failure output:**
```bash
$ git fetch origin
fatal: Could not read from remote repository.
Please make sure you have the correct access rights and the repository exists.
```

### VER-03: Git Commit Signature Verification

**What to check:**
1. `git commit --allow-empty -m "test"` creates commit without errors
2. `git log --show-signature -1` shows valid signature

**Expected output:**
```bash
$ git commit --allow-empty -m "test signed commit"
[main abc1234] test signed commit

$ git log --show-signature -1
commit abc1234...
gpg: Signature made Thu Mar 19 12:00:00 2026 CST
gpg:                using SSH key ED25519:SHA256:abcdef123456...
gpg: Good signature from changlong.zhao@outlook.com
Author: zhaochanglong <changlong.zhao@outlook.com>
Date:   Thu Mar 19 12:00:00 2026 CST

    test signed commit
```

**Failure output (agent not available):**
```bash
$ git commit --allow-empty -m "test"
error: unable to sign commit
fatal: signing failed: ssh-keygen: Operation not permitted
```

**Failure output (key mismatch):**
```bash
$ git log --show-signature -1
commit abc1234...
gpg: Signature made Thu Mar 19 12:00:00 2026 CST
gpg:                using SSH key ED25519:SHA256:xyz789...
gpg:                (this is not a Good signature)
gpg: Good signature from changlong.zhao@outlook.com
gpg: WARNING: This key is not certified with a trusted signature!
```

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Custom verification script | Bash script with multiple checks | Individual commands | Simpler to debug, each command is self-documenting |
| Wrapper for ssh-add | Custom agent query tool | Direct `ssh-add -L` | Standard command, well-documented output |
| Manual signature verification | Parse git log output manually | `git log --show-signature` | Built-in verification with clear output |
| Test commit with real changes | Create test files | `git commit --allow-empty` | No side effects, clean test |

**Key insight:** All verification commands are built into OpenSSH and Git. No custom tooling needed.

## Common Pitfalls

### Pitfall 1: SSH_AUTH_SOCK Path Invalid After Reconnect
**What goes wrong:** `$SSH_AUTH_SOCK` points to old socket that no longer exists
**Why it happens:** macOS 1Password agent socket path changes between sessions
**How to avoid:** Reconnect SSH session; macOS SSH config should point to current socket
**Warning signs:** `ssh-add -L` fails but `$SSH_AUTH_SOCK` has a value

### Pitfall 2: Key in Agent Doesn't Match Config
**What goes wrong:** Signature verification fails because key in 1Password differs from allowedSignersFile
**Why it happens:** Different SSH key loaded in 1Password vs configured in git.nix
**How to avoid:** Verify key fingerprint matches: `ssh-add -L` output should match `signing.key` in git config
**Warning signs:** `git log --show-signature` shows signature but "not a Good signature"

### Pitfall 3: ForwardAgent Not Enabled for Session
**What goes wrong:** SSH connection succeeds but agent not forwarded
**Why it happens:** macOS SSH config `forwardAgent = true` only for "nixos" host, but connecting with different hostname
**How to avoid:** Use exact hostname "nixos" as configured in darwin/home/ssh.nix
**Warning signs:** `ssh-add -L` fails immediately after SSH connection

### Pitfall 4: allowedSignersFile Missing Email
**What goes wrong:** Signature verification fails with "unknown signer"
**Why it happens:** Email in allowedSignersFile doesn't match git user.email
**How to avoid:** Ensure `changlong.zhao@outlook.com` in allowedSignersFile matches `user.email` in git config
**Warning signs:** `git log --show-signature` shows signature but no "Good signature from" line

## Code Examples

### VER-01 Verification Commands
```bash
# After SSH into NixOS from macOS
ssh nixos

# Check 1: SSH_AUTH_SOCK is set
echo $SSH_AUTH_SOCK
# Expected: /tmp/ssh-XXXXXX/agent.PID

# Check 2: Agent has keys
ssh-add -L
# Expected: ssh-ed25519 AAAA...
```

### VER-02 Verification Commands
```bash
# In git repository on NixOS
cd ~/repos/your-repo

# Check 1: Fetch succeeds
git fetch origin
# Expected: (no output or "Fetching origin")

# Check 2: Push succeeds
git push
# Expected: "Everything up-to-date" or "X files changed"
```

### VER-03 Verification Commands
```bash
# In git repository on NixOS
cd ~/repos/your-repo

# Check 1: Create signed commit
git commit --allow-empty -m "VER-03 test commit"
# Expected: "[main abc1234] VER-03 test commit"

# Check 2: Verify signature
git log --show-signature -1
# Expected: "Good signature from changlong.zhao@outlook.com"

# Alternative: Using git verify-commit
git verify-commit HEAD
# Expected: (no output = success)
```

### Manual Signature Verification (Debug)
```bash
# Export the signed data and signature
git cat-file blob HEAD > /tmp/commit_data
git cat-file blob HEAD.sig > /tmp/commit.sig 2>/dev/null || echo "No separate sig file"

# Use ssh-keygen -Y verify (advanced debugging)
ssh-keygen -Y verify -f ~/.ssh/allowed_signers -I changlong.zhao@outlook.com -n git -s /tmp/commit.sig < /tmp/commit_data
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| GPG signature verification | SSH signature verification | Git 2.34+ | Simpler key management |
| Manual key file verification | SSH agent forwarding | 2026 | No key files on remote |
| `git show --raw` for signature | `git log --show-signature` | Always | Clearer signature status |

**Deprecated/outdated:**
- `git show --raw`: Use `git log --show-signature` for clearer signature status
- Manual GPG verification: Use built-in SSH signature verification

## Open Questions

1. **What if user connects with different hostname?**
   - Current config only enables ForwardAgent for "nixos" host
   - If user connects via IP (172.24.2.76), agent forwarding won't work
   - Recommendation: Always use `ssh nixos` hostname

2. **How to handle multiple keys in 1Password?**
   - `ssh-add -L` may show multiple keys
   - ssh-keygen will try all keys in agent until one matches
   - Recommendation: Ensure target key is first/default in 1Password

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Manual verification + git built-in |
| Config file | N/A - verification via git/ssh commands |
| Quick run command | `ssh-add -L && git log --show-signature -1` |
| Full suite command | Full verification flow (VER-01, VER-02, VER-03) |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| VER-01 | SSH_AUTH_SOCK available after SSH | Manual | `echo $SSH_AUTH_SOCK && ssh-add -L` | ❌ Phase 3 |
| VER-02 | git push/pull auth works | Manual | `git fetch && git push` | ❌ Phase 3 |
| VER-03 | git commit signature works | Manual | `git log --show-signature -1` | ❌ Phase 3 |

### Sampling Rate
- **Per task commit:** Manual verification on NixOS
- **Per wave merge:** N/A - Phase 3 is final verification
- **Phase gate:** All three VER requirements must pass before phase complete

### Wave 0 Gaps
- No automated test infrastructure - verification requires live SSH session
- Test approach: User manually runs verification commands on NixOS
- No gaps - existing git/ssh commands provide all verification capability

## Sources

### Primary (HIGH confidence)
- ssh-keygen(1) man page - `-Y verify`, `-Y sign` options and SSH agent behavior
- git-scm.com documentation - `git log --show-signature`, `git verify-commit`
- OpenSSH ssh-add(1) - agent key listing and verification

### Secondary (MEDIUM confidence)
- WebSearch results for SSH agent forwarding verification patterns
- git-scm.com - SSH signature verification workflow

### Tertiary (LOW confidence)
- None - all verification commands verified with official documentation

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Based on official ssh-keygen and git documentation
- Architecture: HIGH - Follows documented SSH agent forwarding and signing workflow
- Pitfalls: HIGH - Based on documented failure modes and current configuration

**Research date:** 2026-03-19
**Valid until:** 90 days (SSH and Git protocols are stable)
