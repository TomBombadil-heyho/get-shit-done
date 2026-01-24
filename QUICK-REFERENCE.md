# Quick Reference: Separate Branch Workflow

## Current Setup

- **`main`** - Syncs with upstream (glittercowboy/get-shit-done)
- **`dev`** or **`custom`** - Your personal development branch

## Common Commands

### Setup (One-time)

```bash
# Add upstream remote
git remote add upstream https://github.com/glittercowboy/get-shit-done.git

# Create and switch to dev branch
git checkout -b dev
git push -u origin dev
```

### Daily Work

```bash
# Always work on dev
git checkout dev

# Make changes, commit, and push
git add .
git commit -m "Your changes"
git push origin dev
```

### Sync from Upstream (Automated)

```bash
# Run the sync script
./sync-upstream.sh
```

### Sync from Upstream (Manual)

```bash
# Update main from upstream
git checkout main
git fetch upstream
git merge upstream/main
git push origin main

# Switch back to dev
git checkout dev
```

### Merge Upstream Updates into Dev (Optional)

```bash
# After syncing main, optionally merge into dev
git checkout dev
git merge main
git push origin dev
```

## Key Principles

1. ✅ **Work on `dev`** - All your custom changes
2. ✅ **Keep `main` clean** - Only sync from upstream
3. ✅ **Sync regularly** - Stay up to date with upstream
4. ❌ **Never commit to `main`** - It should mirror upstream

## Remotes

- **origin** - Your fork (TomBombadil-heyho/get-shit-done)
- **upstream** - Original repo (glittercowboy/get-shit-done)

## Check Status

```bash
# See which branch you're on
git branch

# View all remotes
git remote -v

# Check for changes
git status
```
