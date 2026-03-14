---
phase: quick-1
plan: 01
type: execute
wave: 1
depends_on: []
files_modified: [*.nix (71 files)]
autonomous: true
requirements: [FMT-01]
user_setup: []

must_haves:
  truths:
    - "All Nix files pass alejandra format check"
    - "GitHub workflow `check nix formatting` step succeeds"
  artifacts:
    - path: "*.nix"
      provides: "Formatted Nix files"
  key_links:
    - from: "alejandra"
      to: "*.nix files"
      via: "nix run command"
      pattern: "formatted with alejandra"
---

<objective>
Format all 71 Nix files using alejandra to pass the GitHub workflow formatting check.

Purpose: Fix CI failure in `check nix formatting` step
Output: All Nix files properly formatted, CI passes
</objective>

<execution_context>
@./.claude/get-shit-done/workflows/execute-plan.md
@./.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/STATE.md

## Problem

GitHub workflow `check nix formatting` step failed with:
```
error: The following files need formatting:
[71 Nix files listed]
```

## Solution

Run alejandra formatter on all Nix files:
```bash
nix run nixpkgs#alejandra -- .
```

This will format all .nix files in place.
</context>

<tasks>

<task type="auto">
  <name>Format all Nix files with alejandra</name>
  <files>All *.nix files in repository (71 files)</files>
  <action>
    Run the alejandra formatter to fix all Nix file formatting:

    ```bash
    nix run nixpkgs#alejandra -- .
    ```

    This command:
    - Downloads alejandra from nixpkgs (if not cached)
    - Formats all .nix files in place
    - Handles the 71 files identified by the CI check

    After formatting, commit the changes:
    ```bash
    git add -A
    git commit -m "style: format all Nix files with alejandra"
    ```
  </action>
  <verify>
    <automated>nix run nixpkgs#alejandra -- --check . 2>&1 | grep -c "needs formatting" || echo "All files formatted"</automated>
  </verify>
  <done>All 71 Nix files formatted, commit created, CI formatting check will pass</done>
</task>

</tasks>

<verification>
1. Run `nix run nixpkgs#alejandra -- --check .` locally - should exit 0
2. Push to trigger CI - `check nix formatting` step should pass
</verification>

<success_criteria>
- All Nix files pass alejandra format check
- GitHub workflow `check nix formatting` step succeeds
- Changes committed with descriptive message
</success_criteria>

<output>
After completion, create `.planning/quick/1-fix-nix-formatting/1-SUMMARY.md`
</output>