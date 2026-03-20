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

### 安装方式
- 通过 Nix 配置声明式安装 Podman
- 在 darwin/packages 或 homebrew 配置中添加 podman
- 符合项目的声明式原则，不手动执行 `brew install`

### Machine 资源配置
- 声明式固定配置：8GB RAM, 4 CPUs
- 配置在 Nix 表达式中定义，每次 rebuild 时自动应用
- 修改资源配置需要 rebuild 配置

### Machine 启动方式
- 配置 launchd agent 实现自动启动
- 系统启动后 Podman machine 自动运行
- 无需手动执行 `podman machine start`

### 网络配置
- 使用 macOS Podman 默认 NAT + gvproxy
- 端口映射通过 gvproxy 配置实现
- 不配置桥接模式

### 验证方式
- 创建验证脚本依次检查：
  - `podman --version`
  - `podman machine ls`
  - `podman run --rm hello-world`
  - `podman ps`

### Claude's Discretion
- 验证脚本的具体实现细节
- launchd plist 文件的具体配置参数
- gvproxy 的高级配置选项（如有需要）

</decisions>

<canonical_refs>
## Canonical References

### Podman 配置
- `nixos/podman.nix` — NixOS Podman 配置参考（已有）
- `darwin/packages/default.nix` — macOS packages 配置入口
- `darwin/default.nix` — Darwin 系统配置入口

### 外部参考
- 无外部 spec/ADR — 需求已在 REQUIREMENTS.md 中完整捕获

</canonical_refs>

<code_context>
## Existing Code Insights

### 现有配置模式
- darwin/ 目录存放 macOS 配置
- darwin/packages/default.nix 使用 Homebrew cask
- darwin/default.nix 是主配置入口

### 可复用模式
- Homebrew cask 配置已在 darwin/packages/default.nix 中建立
- launchd 服务配置可参考现有 agent 模式（如有）

### 集成点
- Podman package 需要添加到 darwin/packages 或 homebrew 配置
- launchd agent 需要集成到 darwin/default.nix 或独立模块

</code_context>

<specifics>
## Specific Ideas

- "符合项目的声明式原则" — 所有配置通过 Nix 管理
- 配置应可重复验证

</specifics>

<deferred>
## Deferred Ideas

- Podman machine 资源配置的手动调整方案 — 当前选择声明式，defer 手动方案
- 桥接网络模式 — 当前选择默认 NAT，defer 桥接模式

</deferred>

---

*Phase: 04-podman-install*
*Context gathered: 2026-03-20*
