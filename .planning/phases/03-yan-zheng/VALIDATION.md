# Phase 3: 验证 - Validation Strategy

**Created:** 2026-03-19
**Phase:** 03-yan-zheng
**Type:** Manual verification with remote SSH commands

## Validation Approach

This phase validates SSH Agent Forwarding and Git signing configuration through **remote command execution via SSH**. All verification commands run on the NixOS target system, invoked from macOS.

### Why Manual Verification

Phase 3 is inherently a **manual verification phase** because:

1. **SSH Agent Forwarding requires live session** - The forwarded SSH agent from 1Password on macOS is only accessible within an active SSH session to NixOS
2. **Git operations require user repository context** - Git push/pull and commit operations must run in the user's working directory
3. **Visual signature verification** - `git log --show-signature` output requires human interpretation of "Good signature" status

### Automation Limitations

| Verification | Can Automate? | Why |
|--------------|---------------|-----|
| VER-01: SSH_AUTH_SOCK check | PARTIAL - can run via `ssh nixos 'command'` | Requires active SSH session, but commands can be remotely invoked |
| VER-02: Git fetch/push | PARTIAL - can run via `ssh nixos 'cd repo && git fetch'` | Requires network access and SSH keys, but commands can be remotely invoked |
| VER-03: Commit signature | PARTIAL - can run via `ssh nixos 'git commit && git log --show-signature'` | Creates test commit, but signature validation requires human review |

## Validation Commands

All commands are designed to run **from macOS** and execute **on NixOS** via SSH:

### VER-01: SSH Agent Forwarding

```bash
# Single command to verify both SSH_AUTH_SOCK and agent keys
ssh nixos 'echo $SSH_AUTH_SOCK && ssh-add -L'
```

**Expected output:**
```
/tmp/ssh-XXXXXX/agent.1234
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP5M2RGhIG1CslAdzx+1xcOFiAgJhw0FKFqhe/Wkm1qZ
```

**Failure output:**
```
Could not open a connection to your authentication agent: No such file or directory
```

### VER-02: Git Remote Authentication

```bash
# Verify git fetch and push work
ssh nixos 'cd ~/Documents/nix && git fetch origin && git push'
```

**Expected output:**
```
Everything up-to-date
```

**Failure output:**
```
fatal: Could not read from remote repository.
Please make sure you have the correct access rights and the repository exists.
```

### VER-03: Git Commit Signature

```bash
# Create test commit and verify signature
ssh nixos 'cd ~/Documents/nix && git commit --allow-empty -m "VER-03 test" && git log --show-signature -1'
```

**Expected output:**
```
[main abc1234] VER-03 test
commit abc1234...
gpg: Signature made Thu Mar 19 12:00:00 2026 CST
gpg:                using SSH key ED25519:SHA256:abcdef123456...
gpg: Good signature from changlong.zhao@outlook.com
Author: zhaochanglong <changlong.zhao@outlook.com>
```

**Failure output:**
```
error: unable to sign commit
fatal: signing failed: ssh-keygen: Operation not permitted
```

## Nyquist Compliance

This phase uses **remote command execution** as the automated verification method:

| Nyquist Requirement | Implementation |
|---------------------|----------------|
| Automated `<verify>` commands | All three tasks have `ssh nixos '...'` commands |
| Test before implementation | N/A - verification phase, no code to write |
| Fast feedback (< 60s) | Each SSH command completes in < 10s |
| Reproducible | Commands are deterministic and idempotent (except VER-03 creates commit) |

### Why SSH Commands Count as Automated

The `<automated>` field contains commands like:
```bash
ssh nixos 'echo $SSH_AUTH_SOCK && ssh-add -L'
```

These ARE automated because:
1. **No human interpretation needed** - Command output is deterministic
2. **Machine-readable** - Return codes and output can be parsed
3. **Repeatable** - Same command produces same result
4. **Fast** - Completes in seconds

The **checkpoint:human-verify** tasks are for:
1. Confirming the automated commands succeeded (human review of output)
2. Making go/no-go decisions for the phase
3. Interpreting signature status ("Good signature" vs warnings)

## Gap Closure

If verification fails:

1. **VER-01 failure** → Gap in Phase 1 SSH Agent Forwarding configuration
2. **VER-02 failure** → Gap in SSH key setup or git remote URL
3. **VER-03 failure** → Gap in Phase 2 git signing configuration

Create gap closure plans via `/gsd:plan-phase --gaps` after documenting failures in UAT.md.
