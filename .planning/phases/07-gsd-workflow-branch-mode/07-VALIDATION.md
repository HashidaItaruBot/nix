# Phase 7: GSD Workflow Branch Mode - Validation

**Created:** 2026-03-15
**Based on:** RESEARCH.md Validation Architecture (lines 360-392)

---

## Test Framework

| Property | Value |
|----------|-------|
| Framework | Node.js built-in assert + manual testing |
| Config file | .planning/config.json |
| Quick run command | `node .claude/get-shit-done/bin/gsd-tools.cjs config-get branching_strategy` |
| Full suite command | Manual workflow testing |

---

## Phase Requirements -> Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|--------------|
| BRANCH-01 | pr strategy option accepted | unit | `node gsd-tools.cjs config-set branching_strategy pr && config-get branching_strategy` | New |
| BRANCH-02 | Branch created at discuss-phase | integration | Manual: run discuss-phase, check `git branch` | New |
| BRANCH-03 | Branch naming correct | unit | `node gsd-tools.cjs init phase-op 1 \| jq .branch_name` | Existing |
| BRANCH-04 | PR created after phase | e2e | Manual: complete phase, check `gh pr list` | New |
| BRANCH-05 | Main branch protection | e2e | Manual: on main, run discuss-phase | New |
| BRANCH-06 | Auto-create on main | e2e | Manual: on main, run discuss-phase | New |
| BRANCH-07 | Cleanup merged branches | unit | `git branch --merged main` | New |

---

## Sampling Rate

- **Per task commit:** Verify branch is correct (`git branch --show-current`)
- **Per wave merge:** No applicable (single branch per phase)
- **Phase gate:** Branch is correct, PR created (if pr strategy)

---

## Wave 0 Gaps

- [ ] `tests/branching.test.js` - unit tests for branch name generation
- [ ] `tests/pr-workflow.test.js` - integration tests for PR creation
- [ ] Mock gh CLI for testing without GitHub access

---

## Acceptance Criteria

### BRANCH-01: pr strategy option accepted
```bash
# Test: Set and verify pr strategy
node .claude/get-shit-done/bin/gsd-tools.cjs config-set branching_strategy pr
node .claude/get-shit-done/bin/gsd-tools.cjs config-get branching_strategy
# Expected output: pr
```

### BRANCH-02: Branch created at discuss-phase start
```bash
# Precondition: On main branch with pr strategy enabled
git checkout main
git pull

# Test: Run discuss-phase
# (Manual: invoke /gsd:discuss-phase with a phase number)

# Verify: Branch was created
git branch --show-current
# Expected: gsd/phase-{N}-{slug}
```

### BRANCH-03: Branch naming correct
```bash
# Test: init phase-op returns correct branch_name
node .claude/get-shit-done/bin/gsd-tools.cjs init phase-op 7
# Expected output includes: "branch_name": "gsd/phase-07-gsd-workflow-branch-mode"
```

### BRANCH-04: PR created after phase
```bash
# Precondition: Phase completed with pr strategy
# Test: Check PR exists
gh pr list --head $(git branch --show-current)
# Expected: PR listed with correct title
```

### BRANCH-05 & BRANCH-06: Main branch protection with auto-create
```bash
# Precondition: On main branch with pr strategy
git checkout main

# Test: Run discuss-phase
# Expected output: "⚡ 自动创建分支: gsd/phase-{N}-{slug}"

# Verify: Not on main anymore
git branch --show-current
# Expected: Not "main" or "master"
```

### BRANCH-07: Cleanup merged branches
```bash
# Precondition: Previous phase branch was merged
# Test: Start new phase
# Expected output: "Cleaned up merged branch: gsd/phase-{N}-{slug}"

# Verify: Branch no longer exists locally
git branch | grep "gsd/phase-{N}"
# Expected: No output
```

---

## Validation Checklist

Before marking phase complete:

- [ ] `config-set branching_strategy pr` works
- [ ] `config-get branching_strategy` returns `pr`
- [ ] `init phase-op N` returns correct `branch_name`
- [ ] On main branch, discuss-phase auto-creates branch
- [ ] Prompt "⚡ 自动创建分支: ..." shown
- [ ] After phase completion, PR is created
- [ ] PR title matches "Phase N: {name}"
- [ ] PR body contains content from SUMMARY.md
- [ ] Starting new phase cleans up merged branches

---

*Validation file created: 2026-03-15*