# Phase 4: Colima 安装与初始化 - 上下文

**Gathered:** 2026-03-20
**Status:** Ready for planning

<domain>
## Phase Boundary

在 macOS 上使用 Nix 声明式配置安装 Colima，初始化并启动 Colima machine，使其能够运行 Docker 容器。这是 v1.3 的第一个 phase。

**Success Criteria:**
1. `colima --version` 返回已安装版本号
2. `colima status` 显示 VM 状态为 "Running"
3. VM 资源配置为 8GB+ RAM, 4+ CPUs
4. `docker run --rm hello-world` 成功执行并无错误退出 (Colima 提供 Docker 兼容 API)
5. `docker ps` 可正常列出容器

</domain>

<decisions>
## Implementation Decisions

### 安装方式
- 通过 Homebrew cask 在 darwin/packages/default.nix 中添加 Colima
- 系统级安装，符合项目现有的 Homebrew 模式
- 不单独创建 colima.nix 模块，直接在 packages 中配置

### VM 初始化方式
- 通过 home-manager 模块管理 Colima 配置
- 创建 darwin/home/colima.nix 模块
- 在 zhaochanglong.nix 中导入 colima 模块
- 配置自动处理 VM 初始化和启动

### VM 资源配置
- 8GB RAM, 4 CPUs, 100GB disk（OpenHands 推荐最低配置）
- 配置在 home-manager 模块中声明式定义

### 自动启动
- 使用 home-manager 的 autoStart 选项（如有）
- 或配置 launchd agent 作为备选方案
- 用户登录时自动启动 Colima machine

### 验证方式
- 手动执行验证命令
- 不创建专门的验证脚本
- 用户按 checklist 逐项验证

### Claude's Discretion
- home-manager colima 模块的具体实现细节
- 配置参数的具体命名和结构
- 错误处理和日志配置

</decisions>

<canonical_refs>
## Canonical References

### Colima 配置
- `docs/openhands-run.md` — Colima 安装和初始化详细步骤
- `darwin/packages/default.nix` — Homebrew packages 配置入口
- `darwin/home/zhaochanglong.nix` — home-manager 用户配置入口

### 外部参考
- [Colima GitHub](https://github.com/abiosoft/colima) — 官方文档和配置选项
- 无其他外部 spec/ADR — 需求已在 REQUIREMENTS.md 中完整捕获

</canonical_refs>

<code_context>
## Existing Code Insights

### 现有配置模式
- darwin/packages/default.nix 使用 Homebrew casks 安装应用
- darwin/home/zhaochanglong.nix 导入 git.nix, ssh.nix 等模块
- shared/home/openhands.nix 已引用 colima 包（作为依赖）

### 可复用模式
- Homebrew cask 配置已在 packages/default.nix 中建立
- home-manager 模块模式（git.nix, ssh.nix）可参考

### 集成点
- Colima package 需要添加到 darwin/packages/default.nix 或 home-manager 配置
- home-manager colima 模块需要创建并导入到 zhaochanglong.nix
- 可能需要配置 Docker socket 权限

</code_context>

<specifics>
## Specific Ideas

- "符合项目的声明式原则" — 所有配置通过 Nix 管理
- 配置应可重复验证
- 参考 docs/openhands-run.md 中的详细步骤

</specifics>

<deferred>
## Deferred Ideas

- 手动初始化脚本方案 — 当前选择 home-manager 模块，defer 脚本方案
- 高配 VM 资源（16GB/8CPU）— 当前选择默认配置，可后续调整
- Colima 高级配置（网络、镜像存储位置）— 当前选择默认值

</deferred>

---

*Phase: 04-colima-install*
*Context gathered: 2026-03-20*
