# Phase 7: GSD Workflow Branch Mode - Context

**Gathered:** 2026-03-15
**Status:** Ready for planning

<domain>
## Phase Boundary

修改 GSD 工作流，强制实现分支开发模式。要求：基于 main 创建开发分支、在开发分支实现需求、创建 PR、用户在 GitHub 审查、手动合并到 main。禁止直接在 main 分支修改。

</domain>

<decisions>
## Implementation Decisions

### 分支策略选项
- 新增 `pr` 分支策略选项（`branching_strategy: "pr"`）
- 分支在 `discuss-phase` 开始时创建
- 分支命名格式：`gsd/phase-{phase}-{slug}`（与现有 phase 策略一致）

### PR 创建流程
- PR 在阶段完成后自动创建
- PR 标题从阶段名称生成
- PR 描述从 SUMMARY.md 提取变更摘要
- 使用 `gh pr create` 命令创建 PR

### main 分支保护
- 所有 gsd 命令都检查当前分支
- 当用户在 main 分支执行 gsd 命令时，自动创建分支并切换
- 提示信息：`⚡ 自动创建分支: {branch-name}`

### 工作流衔接
- PR 创建后提示用户去 GitHub 审查合并
- 等待用户手动合并，不自动检测
- 合并后用户手动运行下一阶段
- 下一个阶段开始时自动清理已合并的本地分支

### Claude's Discretion
- PR 描述的具体格式和内容提取逻辑
- 错误处理：分支创建失败、PR 创建失败的情况
- 已合并分支的检测逻辑（git branch --merged）

</decisions>

<specifics>
## Specific Ideas

- "整个工作流程都应该在分支上进行，包括讨论和规划"
- "PR 创建后用户需要在 GitHub 上审查，这是人工把关的环节"
- "分支命名与现有 phase 策略保持一致，便于理解"

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- `.claude/get-shit-done/bin/lib/config.cjs`: 现有分支策略配置（none/phase/milestone）
- `.claude/get-shit-done/bin/lib/init.cjs`: 分支名生成逻辑
- `.claude/get-shit-done/workflows/execute-phase.md`: 现有分支处理逻辑
- `.claude/get-shit-done/workflows/complete-milestone.md`: 分支合并逻辑

### Established Patterns
- 分支策略通过 `git.branching_strategy` 配置项控制
- 分支名模板支持 `{phase}`、`{slug}`、`{milestone}` 变量
- `gsd-tools.cjs` 提供 config-get/config-set 命令

### Integration Points
- 修改 `config.cjs` 添加 `pr` 策略选项
- 修改 `init.cjs` 在 init 时检查分支并自动创建
- 新增 PR 创建逻辑（可能需要新的 workflow 或扩展现有 workflow）
- 扩展 discuss-phase.md 添加分支检查逻辑

### Current State
- 已有 phase/milestone 策略但不强制 PR
- 没有 main 分支保护机制
- 没有 PR 自动创建功能

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 07-gsd-workflow-branch-mode*
*Context gathered: 2026-03-15*