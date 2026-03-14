---
phase: quick-2
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - darwin/home/default.nix
  - nixos/packages/flatpak.nix
  - flake.nix
  - nixos/home/nixvim/plugins/nix-lsp.nix
  - darwin/default.nix
  - nixos/default.nix
  - nixos/home/default.nix
  - nixos/hardware-configuration.nix
  - nixos/home/nixvim/plugins/treesitter.nix
  - shared/home/default.nix
  - shared/home/ssh.nix
  - nixos/home/ssh.nix
  - shared/home/opencode.nix
  - nixos/sshd.nix
  - nixos/home/kitty.nix
autonomous: true
must_haves:
  truths:
    - "statix linter reports 0 warnings"
    - "All W20 duplicate keys are merged into nested attribute sets"
    - "All W10 empty patterns use _ instead of {...}"
  artifacts:
    - path: "darwin/home/default.nix"
      provides: "Merged nested attributes"
    - path: "shared/home/ssh.nix"
      provides: "Fixed empty pattern"
  key_links: []
---

<objective>
Fix all 22 statix linter warnings in the Nix configuration files.

Purpose: Achieve clean linter output for CI workflow.
Output: Zero statix warnings.
</objective>

<execution_context>
@./.claude/get-shit-done/workflows/execute-plan.md
@./.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/STATE.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Fix W20 duplicate key warnings (16 instances)</name>
  <files>
    darwin/home/default.nix,
    nixos/packages/flatpak.nix,
    flake.nix,
    nixos/home/nixvim/plugins/nix-lsp.nix,
    darwin/default.nix,
    nixos/default.nix,
    nixos/home/default.nix,
    nixos/hardware-configuration.nix,
    nixos/home/nixvim/plugins/treesitter.nix,
    shared/home/default.nix
  </files>
  <action>
Fix W20 warnings by merging duplicate keys into nested attribute sets.

Pattern to fix:
```nix
# Before (W20 warning)
services.flatpak.enable = true;
services.flatpak.update.onActivation = true;

# After (merged)
services.flatpak = {
  enable = true;
  update.onActivation = true;
};
```

For each affected file:
1. Identify duplicate key prefixes (e.g., `services.flatpak.*`, `home-manager.users.*.*`)
2. Group all assignments to the same prefix
3. Replace individual assignments with a single nested attribute set
4. Maintain the same logical meaning and values

Files to fix:
- darwin/home/default.nix
- nixos/packages/flatpak.nix
- flake.nix
- nixos/home/nixvim/plugins/nix-lsp.nix
- darwin/default.nix
- nixos/default.nix
- nixos/home/default.nix
- nixos/hardware-configuration.nix
- nixos/home/nixvim/plugins/treesitter.nix
- shared/home/default.nix
  </action>
  <verify>
    <automated>statix check . 2>&1 | grep -c "W20" || echo "0"</automated>
    Expected output: 0
  </verify>
  <done>All W20 duplicate keys merged into nested attribute sets; statix reports 0 W20 warnings.</done>
</task>

<task type="auto">
  <name>Task 2: Fix W10 empty pattern warnings (6 instances)</name>
  <files>
    shared/home/ssh.nix,
    nixos/home/ssh.nix,
    shared/home/opencode.nix,
    nixos/sshd.nix,
    nixos/home/kitty.nix
  </files>
  <action>
Fix W10 warnings by replacing empty patterns with underscore.

Pattern to fix:
```nix
# Before (W10 warning)
{...}: {
  # content
}

# After (fixed)
_: {
  # content
}
```

For each affected file:
1. Find function definitions with `{...}:` pattern that don't use the argument
2. Replace `{...}:` with `_:` to indicate intentionally unused argument
3. Preserve all other content unchanged

Files to fix:
- shared/home/ssh.nix
- nixos/home/ssh.nix
- shared/home/opencode.nix
- nixos/sshd.nix
- nixos/home/kitty.nix
  </action>
  <verify>
    <automated>statix check . 2>&1 | grep -c "W10" || echo "0"</automated>
    Expected output: 0
  </verify>
  <done>All W10 empty patterns replaced with _; statix reports 0 W10 warnings.</done>
</task>

</tasks>

<verification>
Run statix check to confirm zero warnings:
```bash
statix check .
```
Expected: No output (clean) or only informational messages.
</verification>

<success_criteria>
- statix check reports 0 warnings (both W20 and W10 fixed)
- All 16 W20 duplicate keys merged into nested attribute sets
- All 6 W10 empty patterns replaced with underscore
- CI workflow passes statix linter check
</success_criteria>

<output>
After completion, create `.planning/quick/2-fix-statix-linter-warnings/2-SUMMARY.md`
</output>