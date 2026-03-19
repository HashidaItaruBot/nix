# Research Summary: SSH Agent Forwarding

## Stack

| Component | Choice | Rationale |
|-----------|--------|-----------|
| macOS SSH Client | OpenSSH (系统自带) | 已有配置 |
| NixOS SSH Server | OpenSSH | 已配置，需添加 AllowAgentForwarding |
| Git 签名方式 | `ssh-keygen -Y sign` | 可通过 SSH agent 访问密钥，无需 1Password GUI |

## Key Findings

### SSH Agent Forwarding 配置

**macOS 端（客户端）**:
```nix
# darwin/home/ssh.nix
programs.ssh.matchBlocks."<nixos-host>" = {
  forwardAgent = true;
};
```

**NixOS 端（服务器）**:
```nix
# nixos/sshd.nix
services.openssh.settings.AllowAgentForwarding = true;
```

### Git Commit 签名问题

当前 NixOS 配置使用 `op-ssh-sign`，但这需要 1Password GUI 运行。

**解决方案**: 改用 `ssh-keygen -Y sign`，它可以通过 SSH agent 访问密钥。

```nix
# nixos/home/git.nix
programs.git.signing.signer = "ssh-keygen -Y sign -n git -f ~/.ssh/agent-key";
```

**注意**: 需要创建一个脚本或配置，让 `ssh-keygen` 使用转发的 agent。

## Table Stakes

- [x] macOS 1Password SSH agent 已配置
- [x] NixOS git 签名已配置（但 signer 需要修改）
- [x] 现有 Nix 配置结构清晰

## Pitfalls

| Issue | Prevention |
|-------|------------|
| 忘记在 sshd 启用 AllowAgentForwarding | 配置清单检查 |
| ssh-keygen 签名需要指定公钥路径 | 使用 SSH_AUTH_SOCK 环境变量 |
| SSH agent socket 路径在远程与本地不同 | 通过环境变量动态获取 |

## Build Order

1. 配置 NixOS sshd 允许 Agent Forwarding
2. 配置 macOS SSH 客户端启用 ForwardAgent
3. 修改 NixOS git signer 使用 ssh-keygen
4. 验证整个流程