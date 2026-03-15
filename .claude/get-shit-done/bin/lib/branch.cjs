/**
 * Branch — Git branch utilities for GSD workflow
 */

const { execSync } = require('child_process');
const { output, error } = require('./core.cjs');

/**
 * Detect the main branch name (main, master, or from remote HEAD)
 */
function getMainBranch(cwd) {
  try {
    // Try to detect from remote HEAD
    const result = execSync(
      'git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed "s@^refs/remotes/origin/@@"',
      { cwd, encoding: 'utf-8', stdio: ['pipe', 'pipe', 'pipe'] }
    ).trim();
    return result || 'main';
  } catch {
    // Fallback to 'main'
    return 'main';
  }
}

/**
 * Get current git branch name
 */
function getCurrentBranch(cwd) {
  try {
    return execSync('git branch --show-current', { cwd, encoding: 'utf-8' }).trim();
  } catch {
    return null;
  }
}

/**
 * Check if current branch is the main branch
 */
function isOnMainBranch(cwd) {
  const current = getCurrentBranch(cwd);
  const main = getMainBranch(cwd);
  return current === main;
}

/**
 * Ensure we're on a feature branch, creating one if on main.
 * Used by discuss-phase to enforce branch-based development.
 *
 * @param {string} cwd - Working directory
 * @param {string} branchName - Desired branch name (e.g., gsd/phase-07-slug)
 * @param {string} strategy - Branching strategy ('pr', 'phase', 'milestone', 'none')
 * @param {boolean} raw - Raw JSON output flag
 * @returns {object} - { switched: boolean, branch: string, created: boolean }
 */
function cmdEnsureFeatureBranch(cwd, branchName, strategy, raw) {
  if (!branchName || strategy === 'none') {
    const current = getCurrentBranch(cwd);
    output({ switched: false, branch: current, created: false, reason: 'no_branch_needed' }, raw);
    return;
  }

  const current = getCurrentBranch(cwd);
  const main = getMainBranch(cwd);

  if (current === main) {
    // On main branch - need to create/switch to feature branch
    console.log(`⚡ Creating branch: ${branchName}`);

    try {
      // Try to create new branch, or switch if exists
      execSync(`git checkout -b "${branchName}" 2>/dev/null || git checkout "${branchName}"`, {
        cwd,
        stdio: 'inherit'
      });

      output({
        switched: true,
        branch: branchName,
        created: true,
        message: `Created and switched to ${branchName}`
      }, raw);
    } catch (err) {
      error(`Failed to create branch ${branchName}: ${err.message}`);
    }
  } else {
    // Already on a feature branch
    output({
      switched: false,
      branch: current,
      created: false,
      message: `Already on branch ${current}`
    }, raw);
  }
}

/**
 * Get branch status info
 */
function cmdBranchStatus(cwd, raw) {
  const current = getCurrentBranch(cwd);
  const main = getMainBranch(cwd);
  const isMain = current === main;

  output({
    current_branch: current,
    main_branch: main,
    is_main: isMain,
    needs_branch: isMain
  }, raw);
}

module.exports = {
  getMainBranch,
  getCurrentBranch,
  isOnMainBranch,
  cmdEnsureFeatureBranch,
  cmdBranchStatus,
};