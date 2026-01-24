# Fork Management Guide

This document explains how to maintain a separate development branch (`dev` or `custom`) in your forked repository that won't be overwritten when syncing from the upstream repository.

## Overview

This repository is forked from `glittercowboy/get-shit-done`. The branch strategy allows you to:

- Keep `main` branch in sync with the upstream repository
- Maintain a separate `dev` branch with your custom modifications
- Safely pull updates from upstream without losing your work

## Branch Structure

```
main        - Syncs with upstream (glittercowboy/get-shit-done)
dev         - Your custom development branch (never synced from upstream)
```

## Initial Setup

### 1. Add Upstream Remote

If you haven't already, add the original repository as an upstream remote:

```bash
git remote add upstream https://github.com/glittercowboy/get-shit-done.git
```

Verify your remotes:

```bash
git remote -v
```

You should see:
```
origin    https://github.com/TomBombadil-heyho/get-shit-done (fetch)
origin    https://github.com/TomBombadil-heyho/get-shit-done (push)
upstream  https://github.com/glittercowboy/get-shit-done.git (fetch)
upstream  https://github.com/glittercowboy/get-shit-done.git (push)
```

### 2. Create Development Branch

Create a `dev` branch for your custom work:

```bash
# From your current working branch with custom content
git checkout -b dev

# Push to your fork
git push -u origin dev
```

## Daily Workflow

### Working on Custom Features

Always work on the `dev` branch for your custom modifications:

```bash
git checkout dev
# Make your changes
git add .
git commit -m "Your commit message"
git push origin dev
```

### Syncing from Upstream

When you want to update from the original repository:

```bash
# 1. Switch to main branch
git checkout main

# 2. Fetch latest changes from upstream
git fetch upstream

# 3. Merge upstream changes into main
git merge upstream/main

# 4. Push updated main to your fork
git push origin main

# 5. Switch back to dev for your work
git checkout dev
```

**Important:** Never merge `main` into `dev` unless you specifically want to incorporate upstream changes into your custom branch.

### Selectively Pulling Upstream Features

If you want specific features from upstream in your `dev` branch:

```bash
git checkout dev

# Option 1: Cherry-pick specific commits
git cherry-pick <commit-hash>

# Option 2: Merge main into dev (brings all upstream changes)
git merge main
```

## Protection Strategy

### Branch Protection Rules (GitHub Settings)

Consider setting up branch protection for your `dev` branch:

1. Go to GitHub repository → Settings → Branches
2. Add branch protection rule for `dev`
3. Enable:
   - Require pull request reviews before merging (optional)
   - Include administrators

This prevents accidental force pushes or deletions.

### .gitignore for Development

Add any development-specific files to `.gitignore` that shouldn't be committed:

```gitignore
# Development-specific
.planning/
*.local.md
tmp/
```

## Common Scenarios

### Scenario 1: Upstream Changed Same File You Modified

If there's a conflict between upstream and your changes:

```bash
git checkout main
git fetch upstream
git merge upstream/main
# Resolve any conflicts
git push origin main

# Your dev branch remains unchanged
git checkout dev
# Continue working without conflicts
```

### Scenario 2: Want to Incorporate Upstream Updates

To bring upstream changes into your dev branch:

```bash
# Update main first
git checkout main
git fetch upstream
git merge upstream/main
git push origin main

# Merge into dev
git checkout dev
git merge main
# Resolve any conflicts if they exist
git push origin dev
```

### Scenario 3: Reset Main to Upstream

If your `main` branch diverged accidentally:

```bash
git checkout main
git fetch upstream
git reset --hard upstream/main
git push origin main --force
```

**Warning:** This will discard any commits on `main` that aren't in upstream.

## Quick Reference

```bash
# Check which branch you're on
git branch

# View all branches (including remote)
git branch -a

# See remote repositories
git remote -v

# Update from upstream
git fetch upstream

# View differences between branches
git diff main..dev

# Switch branches
git checkout dev
git checkout main

# Push your custom branch
git push origin dev
```

## Automation Script

Create a script `sync-upstream.sh` to automate syncing:

```bash
#!/bin/bash
# sync-upstream.sh - Sync main branch with upstream repository

set -e

echo "🔄 Syncing from upstream repository..."

# Save current branch
CURRENT_BRANCH=$(git branch --show-current)

# Update main
echo "📥 Fetching upstream changes..."
git fetch upstream

echo "🔀 Updating main branch..."
git checkout main
git merge upstream/main

echo "📤 Pushing to origin..."
git push origin main

# Return to original branch
echo "↩️  Returning to $CURRENT_BRANCH..."
git checkout "$CURRENT_BRANCH"

echo "✅ Sync complete! Your $CURRENT_BRANCH branch is unchanged."
```

Make it executable:

```bash
chmod +x sync-upstream.sh
```

Run it:

```bash
./sync-upstream.sh
```

## Best Practices

1. **Never commit directly to `main`** - Keep it clean for upstream syncing
2. **Always work on `dev`** - This is your custom development branch
3. **Sync regularly** - Update from upstream frequently to stay current
4. **Document changes** - Keep notes on what you've customized
5. **Test after merging** - If you merge `main` into `dev`, test thoroughly
6. **Backup before force push** - Only force push when absolutely necessary

## Troubleshooting

### "Already up to date" when syncing

Your fork's `main` is already synced with upstream. This is good!

### Merge conflicts

If you get conflicts when merging:
1. Git will mark conflicted files
2. Edit files to resolve conflicts
3. `git add <resolved-files>`
4. `git commit`

### Lost changes after sync

If you accidentally worked on `main`:
1. Your commits are still in git history
2. Use `git reflog` to find them
3. Cherry-pick them to `dev`: `git cherry-pick <commit-hash>`

### Wrong branch

If you committed to the wrong branch:
```bash
# On wrong branch, before pushing
git log  # Note the commit hash
git reset --hard HEAD~1  # Undo commit

# Switch to correct branch
git checkout dev
git cherry-pick <commit-hash>
```

## Summary

- **`main`**: Syncs with upstream, never modify directly
- **`dev`**: Your custom work, completely separate from upstream
- **Workflow**: Work on `dev`, sync `main` from upstream independently
- **Protection**: Your `dev` branch will never be overwritten by upstream syncs

This setup gives you the best of both worlds: staying up to date with the original project while maintaining your own customizations safely.
