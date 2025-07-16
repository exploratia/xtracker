const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Get GitHub repo URL from git config
function getGithubRepoUrl() {
  try {
    const remoteUrl = execSync('git config --get remote.origin.url', {
      encoding: 'utf8'
    }).trim();

    let httpsUrl;

    if (remoteUrl.startsWith('git@')) {
      // Convert SSH to HTTPS
      httpsUrl = remoteUrl
        .replace(/^git@([^:]+):/, 'https://$1/')
        .replace(/\.git$/, '');
    } else if (remoteUrl.startsWith('http')) {
      httpsUrl = remoteUrl.replace(/\.git$/, '');
    } else {
      throw new Error('Unsupported remote URL format.');
    }

    return httpsUrl;
  } catch (err) {
    console.error('Could not determine GitHub repo URL:', err.message);
    return null;
  }
}

// Find the date of the most recent tag entry in CHANGELOG.md
function getLastTagDate(changelogFilePath) {
  try {
    const changelogContent = fs.readFileSync(changelogFilePath, 'utf8');
    const regex = /^## \[[^\]]+\] - (\d{4}-\d{2}-\d{2})/gm;

    const dates = [];
    let match;
    while ((match = regex.exec(changelogContent)) !== null) {
      dates.push(match[1]);
    }

    return dates.length > 0 ? dates.sort().reverse()[0] : null;
  } catch (err) {
    console.error('Error reading CHANGELOG.md:', err.message);
    return null;
  }
}

// Get commit messages since a date (or all if date is null)
function getGitCommitsSince(date = null) {
  try {
    const sinceArg = date ? `--since="${date}"` : '';
    const cmd = `git log ${sinceArg} --pretty=format:%s`;
    const result = execSync(cmd, { encoding: 'utf8' });

    return result
      .split('\n')
      .map(line => line.trim())
      .filter(line => line.length > 0);
  } catch (err) {
    console.error('Error executing git log:', err.message);
    return [];
  }
}

// Parse and group commits into Features and Fixes, with issue links
function groupCommits(commits, githubRepoUrl) {
  const features = [];
  const fixes = [];

  // Matches: feat #5 (scope): message OR fix #10: message OR feat: message
  // Capture groups:
  // 1 = type (feat|fix)
  // 2 = issue number (optional)
  // 3 = scope (optional)
  // 4 = message (mandatory)
  const commitRegex = /^(feat|fix)(?:\s+#(\d+))?(?:\s*\(([^)]+)\))?:\s*(.+)$/i;

  for (const commit of commits) {
    const match = commitRegex.exec(commit);
    if (!match) continue;

    const [, type, issueNum, scope, message] = match;
    const issueLink = issueNum ? ` ([#${issueNum}](${githubRepoUrl}/issues/${issueNum}))` : '';
    // Scope is not included in output, only message + issue link
    const formatted = message.trim();

    if (type.toLowerCase() === 'feat') {
      features.push(`${formatted}${issueLink}`);
    } else if (type.toLowerCase() === 'fix') {
      fixes.push(`${formatted}${issueLink}`);
    }
  }

  return { features, fixes };
}

// Generate the changelog section in markdown format
function generateChangelogSection({ features, fixes }, version = 'Unreleased', date = new Date().toISOString().slice(0, 10)) {
  let output = `## [${version}] - ${date}\n`;

  if (features.length > 0) {
    output += `\n### Features\n`;
    for (const feat of features) {
      output += `- ${feat}\n`;
    }
  }

  if (fixes.length > 0) {
    output += `\n### Fixes\n`;
    for (const fix of fixes) {
      output += `- ${fix}\n`;
    }
  }

  return output.trim() + '\n';
}

// Insert the generated section at the top before the first existing tag
function prependToChangelog(filePath, newSection) {
  const original = fs.readFileSync(filePath, 'utf8');

  const insertionIndex = original.search(/^## \[/m);
  const updated =
    insertionIndex !== -1
      ? original.slice(0, insertionIndex) + newSection + '\n\n' + original.slice(insertionIndex)
      : original + '\n\n' + newSection;

  fs.writeFileSync(filePath, updated, 'utf8');
  console.log('CHANGELOG.md updated successfully.');
}

// ---------- Main ----------
const changelogPath = path.join(__dirname, 'CHANGELOG.md');

// Create CHANGELOG.md if it doesn't exist
if (!fs.existsSync(changelogPath)) {
  fs.writeFileSync(
    changelogPath,
    '# Changelog\n\nAll notable changes to this project will be documented in this file.\n',
    'utf8'
  );
  console.log('CHANGELOG.md created.');
}

const latestDate = getLastTagDate(changelogPath);
const githubRepoUrl = getGithubRepoUrl();

if (!githubRepoUrl) {
  console.error('❌ GitHub repository URL not found. Aborting.');
  process.exit(1);
}

if (latestDate) {
  console.log(`Most recent tag date: ${latestDate}`);
} else {
  console.log('No date found in changelog. Fetching full git history.');
}

const commits = getGitCommitsSince(latestDate);
const grouped = groupCommits(commits, githubRepoUrl);

if (grouped.features.length === 0 && grouped.fixes.length === 0) {
  console.log('No feat/fix commits found since last release. Nothing to update.');
  process.exit(0);
}

const newChangelogSection = generateChangelogSection(grouped);
prependToChangelog(changelogPath, newChangelogSection);
