# Phase 1: SSH 配置 - Research

**Researched:** 2026-03-18
**Domain:** NixOS/home-manager SSH Agent Forwarding 配置
**Confidence:** HIGH

## Summary

本阶段研究如何在 NixOS 和 macOS 之间配置 SSH Agent Forwarding，使 macOS 上的 1Password SSH agent 能够转发到 NixOS 远程主机，用于 git 认证操作。

**Primary recommendation:** 使用 NixOS 的 `services.openssh.settings.AllowAgentForwarding = true` 和 home-manager 的 `programs.ssh.matchBlocks."nixos".forwardAgent = true` 实现声明式配置。

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- 在 `nixos/sshd.nix` 中添加 `AllowAgentForwarding = true`
- 保持现有安全设置不变（禁用密码登录、禁用 root 登录、仅公钥认证）
- 使用 Host 别名 `nixos` 标识目标主机
- 为该主机单独创建 matchBlock，启用 `ForwardAgent yes`
- 保持现有 `*` matchBlock 用于 1Password agent socket 配置
- Host 别名：`nixos`，IP 地址：`172.24.2.76`，用户名：`zhaochanglong`，SSH 端口：`22`

### Claude's Discretion
- 具体的 Nix 配置语法细节
- matchBlock 中是否同时配置 hostname 和 user
- 配置文件的导入和合并方式

### Deferred Ideas (OUT OF SCOPE)
None
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| SSHD-01 | NixOS sshd 启用 AllowAgentForwarding | `services.openssh.settings` 使用 freeformType，支持任意 sshd_config 选项 |
| SSHD-02 | NixOS sshd 配置正确保留现有安全设置 | 现有配置已设置 PasswordAuthentication=false, PermitRootLogin=no 等，新配置为增量添加 |
| MAC-01 | macOS SSH 配置为 NixOS 主机启用 ForwardAgent | `programs.ssh.matchBlocks` 支持 `forwardAgent` 选项 |
| MAC-02 | macOS SSH 配置保持使用 1Password agent socket | 现有 `identityAgent` 配置在 `*` matchBlock 中，新配置不影响 |
</phase_requirements>

## Standard Stack

### Core
| Library/Module | Version | Purpose | Why Standard |
|---------------|---------|---------|--------------|
| NixOS openssh | nixpkgs-unstable | SSH 服务端配置 | NixOS 官方模块，声明式配置 |
| home-manager ssh | master | SSH 客户端配置 | 已在项目中使用，支持 matchBlocks |

### Supporting
| Library/Module | Purpose | When to Use |
|---------------|---------|-------------|
| `services.openssh.settings` | SSH 服务端设置 | 配置 sshd_config 选项 |
| `programs.ssh.matchBlocks` | SSH 客户端主机块 | 配置 per-host SSH 选项 |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| home-manager matchBlocks | 直接编辑 ~/.ssh/config | 非声明式，不被 Nix 管理 |
| freeform settings | extraConfig 字符串 | extraConfig 追加到末尾，无法与 settings 混合使用 |

## Architecture Patterns

### Recommended Project Structure
```
nixos/
├── sshd.nix              # SSH 服务端配置 (添加 AllowAgentForwarding)
└── home/
    └── ssh.nix           # NixOS SSH 客户端配置

darwin/home/
└── ssh.nix               # macOS SSH 客户端配置 (添加 ForwardAgent)

shared/home/
└── ssh.nix               # 共享 SSH 基础配置 (GitHub via 443)
```

### Pattern 1: NixOS SSH Server Settings
**What:** 使用 `services.openssh.settings` 配置 sshd 选项
**When to use:** 需要声明式管理 sshd_config 时
**Example:**
```nix
# Source: NixOS nixpkgs sshd.nix module
services.openssh = {
  enable = true;
  settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "no";
    PubkeyAuthentication = true;
    AllowAgentForwarding = true;  # 添加此行
  };
};
```

### Pattern 2: home-manager SSH MatchBlocks
**What:** 使用 `programs.ssh.matchBlocks` 配置 per-host SSH 选项
**When to use:** 需要为不同主机配置不同 SSH 行为时
**Example:**
```nix
# Source: home-manager ssh.nix module
programs.ssh = {
  enable = true;
  matchBlocks = {
    "nixos" = {
      hostname = "172.24.2.76";
      user = "zhaochanglong";
      forwardAgent = true;
    };
    "*" = {
      identityAgent = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
    };
  };
};
```

### Pattern 3: 配置合并顺序
**What:** home-manager 配置合并规则
**When to use:** 多个配置文件需要合并时
**Example:**
```nix
# shared/home/ssh.nix - 基础配置
programs.ssh = {
  enable = true;
  enableDefaultConfig = false;
  matchBlocks = { ... };
};

# darwin/home/ssh.nix - darwin 特定配置 (后导入，覆盖)
programs.ssh.matchBlocks."*" = { identityAgent = "..."; };
programs.ssh.matchBlocks."nixos" = { forwardAgent = true; ... };
```

### Anti-Patterns to Avoid
- **全局启用 ForwardAgent:** 不要在 `*` matchBlock 中设置 `forwardAgent = true`，只为需要的特定主机启用
- **混用 settings 和 extraConfig:** `services.openssh.settings` 和 `extraConfig` 不应同时配置相同选项

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| SSH 配置管理 | 手动编辑 ~/.ssh/config | home-manager matchBlocks | 声明式管理，版本控制 |
| SSH 服务端配置 | 手动编辑 /etc/ssh/sshd_config | services.openssh.settings | 声明式，系统重建后保留 |

**Key insight:** NixOS 和 home-manager 提供完整的 SSH 配置管理，无需手动编辑配置文件。

## Common Pitfalls

### Pitfall 1: AllowAgentForwarding 默认值
**What goes wrong:** 假设需要显式启用，但默认值已经是 `yes`
**Why it happens:** OpenSSH 文档说明 `AllowAgentForwarding` 默认为 `yes`
**How to avoid:** 显式设置 `AllowAgentForwarding = true` 以确保配置清晰，即使默认已启用
**Warning signs:** 配置文件中没有明确说明 agent forwarding 是否启用

### Pitfall 2: ForwardAgent 安全风险
**What goes wrong:** 全局启用 ForwardAgent 导致安全风险
**Why it happens:** 远程主机的 root 用户或具有文件访问权限的用户可以使用转发的 agent
**How to avoid:** 只为信任的特定主机启用 ForwardAgent
**Warning signs:** `ssh-add -L` 在不信任的主机上也能看到本地密钥

### Pitfall 3: matchBlocks 合并冲突
**What goes wrong:** 多个配置文件定义相同 matchBlock 导致意外行为
**Why it happens:** home-manager 的 `matchBlocks` 是 attrset，后导入的配置会覆盖
**How to avoid:** 确保每个 matchBlock 名称唯一，理解导入顺序
**Warning signs:** 配置未生效或被覆盖

### Pitfall 4: identityAgent 与 forwardAgent 交互
**What goes wrong:** 同时设置 identityAgent 和 forwardAgent 导致混淆
**Why it happens:** identityAgent 指定本地 agent socket，forwardAgent 控制是否转发到远程
**How to avoid:** 理解两者作用不同：identityAgent 用于本地认证，forwardAgent 用于远程转发
**Warning signs:** 认证失败或 agent 未正确转发

## Code Examples

### NixOS sshd.nix 完整配置
```nix
# Source: 现有配置 + 新增 AllowAgentForwarding
_: {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      ChallengeResponseAuthentication = false;
      PermitRootLogin = "no";
      PubkeyAuthentication = true;
      AuthorizedKeysFile = "%h/.ssh/authorized_keys";
      AllowAgentForwarding = true;  # 新增: 允许 SSH Agent Forwarding
    };
  };

  networking.firewall.allowedTCPPorts = [22];
}
```

### darwin/home/ssh.nix 完整配置
```nix
# Source: 现有配置 + 新增 nixos matchBlock
_: {
  # 现有配置: 1Password agent socket
  programs.ssh.matchBlocks."*".identityAgent =
    "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
  programs.ssh.matchBlocks."github.com".identityAgent =
    "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";

  # 新增: NixOS 主机 ForwardAgent 配置
  programs.ssh.matchBlocks."nixos" = {
    hostname = "172.24.2.76";
    user = "zhaochanglong";
    forwardAgent = true;
  };
}
```

### 验证 SSH Agent Forwarding
```bash
# 在 macOS 上连接到 NixOS
ssh nixos

# 在 NixOS 上验证 agent 转发
echo $SSH_AUTH_SOCK  # 应该显示 /tmp/ssh-XXXXXXXXXX/agent.XXXXX
ssh-add -L           # 应该列出本地 1Password 中的密钥
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| 手动编辑 sshd_config | services.openssh.settings | NixOS 23.05+ | 声明式，可重现 |
| 手动编辑 ~/.ssh/config | programs.ssh.matchBlocks | home-manager 一直 | 声明式，版本控制 |

**Deprecated/outdated:**
- 直接修改 `/etc/ssh/sshd_config`: 使用 NixOS settings 模块代替
- 使用 `services.openssh.extraConfig`: 优先使用 `settings` (freeform type)

## Open Questions

1. **matchBlock 中是否同时配置 user?**
   - What we know: `user` 选项可用，但用户名在连接时可覆盖
   - What's unclear: 是否需要在 matchBlock 中硬编码用户名
   - Recommendation: 配置 user 以确保一致性，避免每次连接时指定用户名

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | 无测试框架 (声明式配置验证) |
| Config file | N/A |
| Quick run command | `nix eval .#nixos` 或 `nix eval .#darwin` |
| Full suite command | `darwin-rebuild switch --flake .#darwin` / `nixos-rebuild switch --flake .#nixos` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SSHD-01 | AllowAgentForwarding 启用 | 配置验证 | `nix eval .#nixos --json` | N/A |
| SSHD-02 | 安全设置保留 | 配置验证 | `nix eval .#nixos --json` | N/A |
| MAC-01 | ForwardAgent 启用 | 配置验证 | `nix eval .#darwin --json` | N/A |
| MAC-02 | identityAgent 保留 | 配置验证 | `nix eval .#darwin --json` | N/A |

### Sampling Rate
- **Per task commit:** `nix eval .#darwin` / `nix eval .#nixos`
- **Per wave merge:** `darwin-rebuild switch` / `nixos-rebuild switch` (dry-run)
- **Phase gate:** 实际部署到目标机器并验证

### Wave 0 Gaps
- 无测试框架需求 — Nix 配置验证通过 `nix eval` 完成
- 功能验证需要实际部署到目标机器

**Note:** 声明式 Nix 配置的验证主要通过 `nix eval` 和 `nixos-rebuild/darwin-rebuild` 的构建过程完成。运行时验证需要实际 SSH 连接测试。

## Sources

### Primary (HIGH confidence)
- [NixOS sshd.nix module](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/ssh/sshd.nix) - settings freeform type
- [home-manager ssh.nix module](https://github.com/nix-community/home-manager/blob/master/modules/programs/ssh.nix) - matchBlocks options including forwardAgent
- [OpenBSD sshd_config(5)](https://man.openbsd.org/sshd_config) - AllowAgentForwarding documentation
- [OpenBSD ssh_config(5)](https://man.openbsd.org/ssh_config) - ForwardAgent documentation

### Secondary (MEDIUM confidence)
- Project files: `nixos/sshd.nix`, `darwin/home/ssh.nix`, `shared/home/ssh.nix` - existing configuration patterns

### Tertiary (LOW confidence)
- N/A

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - 使用已验证的 NixOS 和 home-manager 模块
- Architecture: HIGH - 项目已有成熟的配置结构
- Pitfalls: HIGH - 来自官方文档和项目经验

**Research date:** 2026-03-18
**Valid until:** 90 days (stable NixOS/home-manager APIs)