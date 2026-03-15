# Phase 7: GSD Workflow Branch Mode - Research

**Researched:** 2026-03-15
**Domain:** Git workflow automation, branch management, PR creation
**Confidence:** HIGH

## Summary

This research investigates the GSD (Get Shit Done) system's existing branching infrastructure to implement a PR-based development workflow. The current system supports `branching_strategy` with options `none`, `phase`, and `milestone`, but lacks PR creation capabilities and main branch protection.

Key findings:
1. The config system is already extensible for new branching strategies
2. Branch name generation is already implemented in `init.cjs`
3. The `execute-phase.md` workflow already has branch creation/switching logic
4. No `gh pr` CLI integration exists - this needs to be built fresh
5. The integration point for branch creation should be `discuss-phase.md` per the locked decisions

**Primary recommendation:** Extend the existing branching infrastructure by adding `pr` strategy and implementing branch protection checks across all GSD workflows.

<user_constraints>

## User Constraints (from CONTEXT.md)

### Locked Decisions
- New `pr` branching strategy option (`branching_strategy: "pr"`)
- Branch created at `discuss-phase` start
- Branch naming format: `gsd/phase-{phase}-{slug}` (consistent with existing phase strategy)
- PR created after phase completion
- PR title generated from phase name
- PR description extracted from SUMMARY.md
- Use `gh pr create` command
- All GSD commands check current branch
- Auto-create and switch to branch when on main
- Prompt: `⚡ 自动创建分支: {branch-name}`
- PR creation prompts user to review/merge on GitHub
- Wait for user manual merge, no auto-detection
- After merge, user runs next phase manually
- Next phase start auto-cleans merged local branches

### Claude's Discretion
- PR description format and content extraction logic
- Error handling: branch creation failure, PR creation failure
- Merged branch detection logic (git branch --merged)

### Deferred Ideas (OUT OF SCOPE)
None - discussion stayed within phase scope

</user_constraints>

<phase_requirements>

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| BRANCH-01 | Add `pr` branching strategy option | config.cjs lines 53-68 define branching_strategy with phase/milestone/none |
| BRANCH-02 | Create branch at discuss-phase start | discuss-phase.md workflow has initialize step that can be extended |
| BRANCH-03 | Branch naming format gsd/phase-{phase}-{slug} | init.cjs lines 55-63 already generates this exact format |
| BRANCH-04 | PR creation after phase completion | execute-phase.md update_roadmap step is integration point |
| BRANCH-05 | Main branch protection | New check needed in all workflow initialize steps |
| BRANCH-06 | Auto-create branch when on main | Similar pattern exists in execute-phase.md handle_branching step |
| BRANCH-07 | Merged branch cleanup | git branch --merged can be used; needs new utility |

</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Node.js | 18+ | Runtime | GSD is Node.js-based CLI |
| child_process.execSync | built-in | Git commands | Used throughout codebase |
| fs | built-in | File operations | Standard for config/phase manipulation |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| gh CLI | 2.x+ | GitHub PR operations | PR creation, branch operations |

### Integration Points
| File | Purpose | Modification Needed |
|------|---------|---------------------|
| `config.cjs` | Branching strategy config | Add `pr` option to defaults |
| `init.cjs` | Branch name generation | Extend to include `pr` strategy |
| `discuss-phase.md` | Phase discussion workflow | Add branch creation/protection check |
| `execute-phase.md` | Phase execution workflow | Add PR creation after completion |
| `complete-milestone.md` | Milestone completion | Branch cleanup integration |
| `gsd-tools.cjs` | CLI router | New branch/pr commands |

## Architecture Patterns

### Current Branch Handling Pattern

From `execute-phase.md` lines 39-49:

```bash
<step name="handle_branching">
Check `branching_strategy` from init:

**"none":** Skip, continue on current branch.

**"phase" or "milestone":** Use pre-computed `branch_name` from init:
```bash
git checkout -b "$BRANCH_NAME" 2>/dev/null || git checkout "$BRANCH_NAME"
```

All subsequent commits go to this branch. User handles merging.
</step>
```

**Pattern:** Branch creation happens in workflow, not in CLI. The CLI provides branch name via `init` command, workflow executes git operations.

### Branch Name Generation Pattern

From `init.cjs` lines 55-63:

```javascript
// Branch name (pre-computed)
branch_name: config.branching_strategy === 'phase' && phaseInfo
  ? config.phase_branch_template
      .replace('{phase}', phaseInfo.phase_number)
      .replace('{slug}', phaseInfo.phase_slug || 'phase')
  : config.branching_strategy === 'milestone'
    ? config.milestone_branch_template
        .replace('{milestone}', milestone.version)
        .replace('{slug}', generateSlugInternal(milestone.name) || 'milestone')
    : null,
```

**Pattern:** Branch names are pre-computed during `init` and passed to workflows. Templates use `{phase}`, `{slug}`, `{milestone}` variables.

### Config Pattern

From `config.cjs` lines 53-68:

```javascript
const hardcoded = {
  model_profile: 'balanced',
  commit_docs: true,
  search_gitignored: false,
  branching_strategy: 'none',
  phase_branch_template: 'gsd/phase-{phase}-{slug}',
  milestone_branch_template: 'gsd/{milestone}-{slug}',
  workflow: {
    research: true,
    plan_check: true,
    verifier: true,
    nyquist_validation: true,
  },
  parallelization: true,
  brave_search: hasBraveSearch,
};
```

**Pattern:** Config has sensible defaults, supports nested objects, and has a `workflow` section for workflow-specific settings.

### Anti-Patterns to Avoid

- **Duplicating branch logic in multiple workflows:** Centralize branch operations in `init.cjs` and shared functions
- **Inline git commands without error handling:** Wrap git operations with try/catch and provide meaningful errors
- **Hardcoding main branch name:** Use `git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'` to detect main branch dynamically

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Branch name generation | Custom template engine | Existing init.cjs logic | Already handles phase/milestone templates |
| Config management | New config fields | Existing config.cjs | Already has branching_strategy field |
| PR creation | Raw HTTP API calls | `gh pr create` CLI | Official tool, handles auth, better UX |
| Branch detection | Complex git parsing | `git branch --show-current` | Single command, reliable output |

**Key insight:** The existing infrastructure is well-designed for extension. Most work is integration, not new development.

## Common Pitfalls

### Pitfall 1: Branch Creation Timing
**What goes wrong:** Creating branch too early (before phase directory exists) or too late (after commits are made)
**Why it happens:** Workflow steps execute in sequence, and branch creation must happen before any commits
**How to avoid:** Create branch in `discuss-phase.md` initialize step, before any file writes
**Warning signs:** Commits going to main branch, branch not found errors

### Pitfall 2: PR Description Extraction
**What goes wrong:** SUMMARY.md may have incomplete or missing content at PR creation time
**Why it happens:** Phase execution might fail partway, leaving incomplete SUMMARY.md
**How to avoid:** Check for SUMMARY.md existence and validity before PR creation; provide fallback description
**Warning signs:** Empty PR body, missing key changes

### Pitfall 3: Branch Cleanup Race Condition
**What goes wrong:** Deleting a branch that was just merged but git hasn't synced yet
**Why it happens:** Local git state may not immediately reflect remote merge
**How to avoid:** Run `git fetch --prune` before branch cleanup; use `git branch --merged main` to verify
**Warning signs:** Branch deletion fails, "branch not fully merged" errors

### Pitfall 4: Multiple GSD Sessions
**What goes wrong:** User runs multiple GSD phases simultaneously in different terminals
**Why it happens:** No lock mechanism prevents concurrent GSD operations
**How to avoid:** Check for existing GSD branches before creating new ones; warn user
**Warning signs:** Branch name conflicts, unexpected branch switches

## Code Examples

### Extending Branching Strategy in init.cjs

```javascript
// Source: Derived from init.cjs lines 55-63
// Add 'pr' strategy alongside 'phase' and 'milestone'

branch_name: (config.branching_strategy === 'phase' || config.branching_strategy === 'pr') && phaseInfo
  ? config.phase_branch_template
      .replace('{phase}', phaseInfo.phase_number)
      .replace('{slug}', phaseInfo.phase_slug || 'phase')
  : config.branching_strategy === 'milestone'
    ? config.milestone_branch_template
        .replace('{milestone}', milestone.version)
        .replace('{slug}', generateSlugInternal(milestone.name) || 'milestone')
    : null,

// New field for PR workflow
requires_pr: config.branching_strategy === 'pr',
```

### Branch Protection Check Pattern

```javascript
// Source: New pattern for main branch protection
// To be added to workflow initialize steps

function checkMainBranchProtection(cwd, branchName) {
  const currentBranch = execSync('git branch --show-current', { cwd, encoding: 'utf-8' }).trim();
  const mainBranch = execSync('git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed "s@^refs/remotes/origin/@@" || echo "main"', { cwd, encoding: 'utf-8' }).trim();

  if (currentBranch === mainBranch) {
    // Auto-create and switch to branch
    console.log(`⚡ 自动创建分支: ${branchName}`);
    execSync(`git checkout -b "${branchName}"`, { cwd, stdio: 'inherit' });
    return { created: true, branch: branchName };
  }
  return { created: false, branch: currentBranch };
}
```

### PR Creation Pattern

```bash
# Source: New pattern for PR creation
# To be added after phase completion

PR_TITLE="Phase ${PHASE_NUMBER}: ${PHASE_NAME}"
PR_BODY=$(cat "${PHASE_DIR}/*-SUMMARY.md" | grep -A 50 "^## " | head -100)

gh pr create \
  --title "${PR_TITLE}" \
  --body "${PR_BODY}" \
  --base main \
  --head "${BRANCH_NAME}"
```

### Merged Branch Cleanup Pattern

```bash
# Source: New pattern for branch cleanup
# To be run at next phase start

# Fetch and prune deleted remote branches
git fetch --prune

# Find and delete local branches merged into main
MERGED_BRANCHES=$(git branch --merged main | grep 'gsd/phase-' | sed 's/^\*//' | tr -d ' ')

for branch in $MERGED_BRANCHES; do
  git branch -d "$branch" 2>/dev/null || echo "Could not delete $branch"
done
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| No branching strategy | branching_strategy: none/phase/milestone | Pre-existing | Foundation exists for extension |
| Manual branch creation | Auto-create in execute-phase | Pre-existing | Pattern to follow |
| No PR workflow | (This phase) | 2026-03-15 | Adding pr strategy |

**Deprecated/outdated:**
- None identified - this is a new feature addition

## Implementation Approach

### Phase 1: Config Extension
**Files to modify:**
- `config.cjs`: Add `pr` to branching_strategy validation
- `init.cjs`: Extend branch_name generation to include `pr` strategy

**Code changes:**
```javascript
// config.cjs line 57 - add 'pr' option
branching_strategy: 'none', // valid: 'none', 'phase', 'milestone', 'pr'
```

### Phase 2: Branch Protection
**Files to modify:**
- `discuss-phase.md`: Add main branch check in initialize step
- `execute-phase.md`: Add main branch check in initialize step
- `plan-phase.md`: Add main branch check (if exists)
- All workflow entry points

**Pattern:**
```bash
# Get current branch
CURRENT_BRANCH=$(git branch --show-current)

# Detect main branch
MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

# If on main and strategy is 'pr', create branch
if [[ "$CURRENT_BRANCH" == "$MAIN_BRANCH" && "$BRANCHING_STRATEGY" == "pr" ]]; then
  echo "⚡ 自动创建分支: $BRANCH_NAME"
  git checkout -b "$BRANCH_NAME"
fi
```

### Phase 3: PR Creation
**Files to modify:**
- `execute-phase.md`: Add PR creation step after update_roadmap
- New utility function in `commands.cjs` for PR creation

**Location:** After `verify_phase_goal` step passes, before `offer_next` step

### Phase 4: Branch Cleanup
**Files to modify:**
- `discuss-phase.md`: Add cleanup check in initialize step
- `complete-milestone.md`: Enhance existing handle_branches step

**Pattern:**
```bash
# At discuss-phase start, clean up merged branches
git fetch --prune 2>/dev/null
MERGED=$(git branch --merged main | grep 'gsd/phase-' | sed 's/^\*//' | tr -d ' ')
for b in $MERGED; do
  git branch -d "$b" 2>/dev/null && echo "Cleaned up merged branch: $b"
done
```

## Open Questions

1. **PR Description Format**
   - What we know: SUMMARY.md has structured content with one-liner, changes, issues
   - What's unclear: How much detail to include in PR body; whether to include verification status
   - Recommendation: Extract one-liner and key changes section; include link to full SUMMARY.md

2. **Error Recovery When PR Creation Fails**
   - What we know: `gh pr create` can fail due to auth, network, or existing PR
   - What's unclear: Whether to block phase completion or allow manual PR creation
   - Recommendation: Non-blocking - warn user and provide manual command to run

3. **Multiple Phase PRs**
   - What we know: User may run multiple phases before merging
   - What's unclear: Whether to create one PR per phase or aggregate
   - Recommendation: One PR per phase - each phase is a logical unit of work

## Validation Architecture

> nyquist_validation is enabled in config.json

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Node.js built-in assert + manual testing |
| Config file | .planning/config.json |
| Quick run command | `node .claude/get-shit-done/bin/gsd-tools.cjs config-get branching_strategy` |
| Full suite command | Manual workflow testing |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| BRANCH-01 | pr strategy option accepted | unit | `node gsd-tools.cjs config-set branching_strategy pr && config-get branching_strategy` | New |
| BRANCH-02 | Branch created at discuss-phase | integration | Manual: run discuss-phase, check `git branch` | New |
| BRANCH-03 | Branch naming correct | unit | `node gsd-tools.cjs init phase-op 1 | jq .branch_name` | Existing |
| BRANCH-04 | PR created after phase | e2e | Manual: complete phase, check `gh pr list` | New |
| BRANCH-05 | Main branch protection | e2e | Manual: on main, run discuss-phase | New |
| BRANCH-06 | Auto-create on main | e2e | Manual: on main, run discuss-phase | New |
| BRANCH-07 | Cleanup merged branches | unit | `git branch --merged main` | New |

### Sampling Rate
- **Per task commit:** Verify branch is correct (`git branch --show-current`)
- **Per wave merge:** No applicable (single branch per phase)
- **Phase gate:** Branch is correct, PR created (if pr strategy)

### Wave 0 Gaps
- [ ] `tests/branching.test.js` - unit tests for branch name generation
- [ ] `tests/pr-workflow.test.js` - integration tests for PR creation
- [ ] Mock gh CLI for testing without GitHub access

## Sources

### Primary (HIGH confidence)
- `.claude/get-shit-done/bin/lib/config.cjs` - config management, branching_strategy field
- `.claude/get-shit-done/bin/lib/init.cjs` - branch name generation logic
- `.claude/get-shit-done/workflows/execute-phase.md` - existing branch handling pattern
- `.claude/get-shit-done/workflows/discuss-phase.md` - workflow entry point for branch creation

### Secondary (MEDIUM confidence)
- `.claude/get-shit-done/workflows/complete-milestone.md` - existing merge logic patterns
- `.claude/get-shit-done/bin/lib/core.cjs` - git utilities (execGit function)
- `.claude/get-shit-done/bin/lib/phase.cjs` - phase completion logic

### Tertiary (LOW confidence)
- GitHub CLI documentation for `gh pr create` - standard CLI usage

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - existing codebase patterns well documented
- Architecture: HIGH - clear integration points identified
- Pitfalls: MEDIUM - some edge cases may emerge during implementation

**Research date:** 2026-03-15
**Valid until:** 6 months - git workflow patterns are stable