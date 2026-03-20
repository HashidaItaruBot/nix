# Phase 4: Podman 安装与初始化 - 上下文

**Gathered:** 2026-03-20
**Status:** Ready for planning

<domain>
## Phase Boundary

在 macOS 上使用 Nix 声明式配置安装 Podman，初始化并启动 Podman machine，使其能够运行容器。这是 v1.3 的第一个 phase。

**Success Criteria:**
1. `podman --version` 返回已安装版本号
2. `podman machine ls` 显示至少一个 machine 状态为 "Running"
3. Machine 资源配置为 8GB+ RAM, 4+ CPUs
4. `podman run --rm hello-world` 成功执行并无错误退出
5. `podman ps` 可正常列出容器

</domain>

<decisions>
## Implementation Decisions

### Shell 脚本处理
- **删除 `scripts/init-podman-machine.sh`** — 不再使用 shell 脚本管理 Podman machine 初始化
- **删除 `scripts/validate-podman.sh`** — 不再需要专用验证脚本，手动执行 podman 命令验证
- **删除 `launchd.user.agents.podman-start`** — 移除对 init-podman-machine.sh 的依赖

### Machine 初始化
- 首次安装时手动执行 `podman machine init` 一次
- 后续不需要通过 Nix 自动初始化

### Machine 资源配置
- 不通过 Nix 声明式管理 machine 配置（8GB RAM, 4 CPUs 等）
- 用户手动配置 `podman machine set` 按需调整

### 自动启动
- 暂时接受失去开机自动启动功能
- 后续探索 Podman 原生自动启动方案或手动启动

### 验证方式
- 删除验证脚本
- 需要时手动执行 `podman machine ls`、`podman ps` 等命令

### Claude's Discretion
- Podman 原生自动启动方案的研究和实现
- 未来声明式配置的具体实现方式

</decisions>

<canonical_refs>
## Canonical References

### Podman 配置参考
- `nixos/podman.nix` — NixOS Podman 声明式配置参考
- `darwin/packages/default.nix` — macOS Podman package 配置（Homebrew cask）
- `darwin/default.nix` — Darwin 系统配置入口

### 外部参考
- https://mynixos.com/search?q=podman — Nix/NixOS Podman 配置选项参考

</canonical_refs>

<code_context>
## Existing Code Insights

### 现有配置模式
- Podman 通过 Homebrew cask 安装在 `darwin/packages/default.nix`
- launchd agent 配置在 `darwin/default.nix` 中管理
- NixOS Podman 配置参考：`nixos/podman.nix`

### 可删除的配置
- `launchd.user.agents.podman-start` — 依赖外部脚本，需删除

### 可删除的文件
- `scripts/init-podman-machine.sh` — machine 初始化脚本
- `scripts/validate-podman.sh` — 验证脚本

</code_context>

<specifics>
## Specific Ideas

- "先删除脚本，后续再配置替代方案"
- "手动执行脚本" — 用户接受手动初始化和管理 Podman machine

</specifics>

<deferred>
## Deferred Ideas

- Podman 原生自动启动方案 — 后续探索
- 完全声明式 Podman machine 配置 — 后续探索
- Machine 配置的声明式管理 — 当前选择不管理

</deferred>

---

*Phase: 04-podman-install*
*Context gathered: 2026-03-20*
