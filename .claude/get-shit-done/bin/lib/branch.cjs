/**
 * Branch — Git branch utilities for GSD workflow
 */

const fs = require('fs');
const path = require('path');
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

/**
 * Create a PR for the current branch
 *
 * @param {string} cwd - Working directory
 * @param {object} options - PR options
 * @param {string} options.phase_number - Phase number (e.g., "07")
 * @param {string} options.phase_name - Phase name (e.g., "GSD Workflow Branch Mode")
 * @param {string} options.branch_name - Branch name (e.g., "gsd/phase-07-gsd-workflow-branch-mode")
 * @param {string} options.summary_path - Path to SUMMARY.md file
 * @param {string} options.base_branch - Base branch (default: 'main')
 * @param {boolean} raw - Raw JSON output flag
 */
function cmdCreatePR(cwd, options, raw) {
  const {
    phase_number,
    phase_name,
    branch_name,
    summary_path,
    base_branch = 'main'
  } = options;

  if (!branch_name) {
    output({ created: false, error: 'No branch name provided' }, raw);
    return;
  }

  // Generate PR title
  const prTitle = phase_number && phase_name
    ? `Phase ${phase_number}: ${phase_name}`
    : branch_name;

  // Extract PR body from SUMMARY.md
  let prBody = '';
  if (summary_path) {
    try {
      const summaryFullPath = path.join(cwd, summary_path);
      if (fs.existsSync(summaryFullPath)) {
        const content = fs.readFileSync(summaryFullPath, 'utf-8');
        // Extract key sections: one-liner, changes, and any issues
        const lines = content.split('\n');
        const relevantLines = [];
        let inSection = false;
        let captureDepth = 0;

        for (const line of lines) {
          // Start capturing at the first ## heading (after frontmatter)
          if (line.startsWith('## ') && !line.includes('Quick Tasks')) {
            inSection = true;
            captureDepth = 1;
          }
          // Track nested sections
          if (inSection && line.startsWith('##')) {
            const depth = (line.match(/^#+/) || [''])[0].length;
            if (depth < captureDepth && relevantLines.length > 20) {
              // Captured enough, stop at higher-level section
              break;
            }
          }
          if (inSection) {
            relevantLines.push(line);
          }
          // Limit to reasonable PR body size
          if (relevantLines.length > 100) break;
        }

        prBody = relevantLines.join('\n').trim();

        // Add reference to full SUMMARY
        if (prBody) {
          prBody += `\n\n---\n_Full details: ${summary_path}_`;
        }
      }
    } catch (err) {
      console.log(`Warning: Could not read SUMMARY.md: ${err.message}`);
    }
  }

  // Default body if no summary
  if (!prBody) {
    prBody = `## Summary\n\nImplements Phase ${phase_number}: ${phase_name}\n\nSee SUMMARY.md for details.`;
  }

  try {
    // Check if gh CLI is available
    execSync('gh --version', { cwd, stdio: 'pipe' });

    // Create the PR
    const prUrl = execSync(
      `gh pr create --title "${prTitle.replace(/"/g, '\\"')}" --body-file - --base "${base_branch}" --head "${branch_name}"`,
      {
        cwd,
        input: prBody,
        encoding: 'utf-8',
        stdio: ['pipe', 'pipe', 'pipe']
      }
    ).trim();

    console.log(`PR created: ${prUrl}`);
    output({
      created: true,
      url: prUrl,
      title: prTitle,
      branch: branch_name,
      base: base_branch
    }, raw);
  } catch (err) {
    // Non-blocking: PR creation failure should not block phase completion
    const errorMsg = err.message || String(err);
    console.log(`Note: Could not create PR automatically. You can create it manually.`);
    console.log(`  gh pr create --title "${prTitle}" --base ${base_branch}`);

    output({
      created: false,
      error: errorMsg,
      manual_command: `gh pr create --title "${prTitle}" --base ${base_branch}`,
      title: prTitle,
      branch: branch_name
    }, raw);
  }
}

/**
 * Clean up local branches that have been merged into main
 *
 * @param {string} cwd - Working directory
 * @param {object} options - Cleanup options
 * @param {string} options.prefix - Branch prefix to match (default: 'gsd/phase-')
 * @param {boolean} options.dry_run - If true, only list branches without deleting
 * @param {boolean} raw - Raw JSON output flag
 */
function cmdCleanupMergedBranches(cwd, options = {}, raw) {
  const {
    prefix = 'gsd/phase-',
    dry_run = false
  } = options;

  const mainBranch = getMainBranch(cwd);

  try {
    // Fetch and prune deleted remote branches
    console.log('Fetching and pruning remote branches...');
    execSync('git fetch --prune', { cwd, stdio: 'pipe' });
  } catch {
    // Non-fatal if fetch fails
    console.log('Note: Could not fetch from remote');
  }

  try {
    // Find branches merged into main
    const mergedOutput = execSync(
      `git branch --merged ${mainBranch}`,
      { cwd, encoding: 'utf-8', stdio: ['pipe', 'pipe', 'pipe'] }
    ).trim();

    // Filter to GSD phase branches only
    const mergedBranches = mergedOutput
      .split('\n')
      .map(b => b.replace(/^\*/, '').trim())
      .filter(b => b.startsWith(prefix) && b !== getCurrentBranch(cwd));

    const cleaned = [];

    for (const branch of mergedBranches) {
      if (dry_run) {
        console.log(`Would delete: ${branch}`);
        cleaned.push({ branch, deleted: false, dry_run: true });
      } else {
        try {
          execSync(`git branch -d "${branch}"`, { cwd, stdio: 'pipe' });
          console.log(`Cleaned up: ${branch}`);
          cleaned.push({ branch, deleted: true });
        } catch (err) {
          console.log(`Could not delete ${branch}: ${err.message}`);
          cleaned.push({ branch, deleted: false, error: err.message });
        }
      }
    }

    if (cleaned.length === 0) {
      console.log('No merged branches to clean up.');
    }

    output({
      cleaned: cleaned,
      count: cleaned.length,
      dry_run: dry_run,
      main_branch: mainBranch
    }, raw);
  } catch (err) {
    output({
      cleaned: [],
      count: 0,
      error: err.message
    }, raw);
  }
}

module.exports = {
  getMainBranch,
  getCurrentBranch,
  isOnMainBranch,
  cmdEnsureFeatureBranch,
  cmdBranchStatus,
  cmdCreatePR,
  cmdCleanupMergedBranches,
};