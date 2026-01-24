# Optional: Automated Upstream Sync with GitHub Actions

This is an **optional** GitHub Actions workflow that can automatically sync your `main` branch with the upstream repository on a schedule.

## Benefits

- Automatic daily syncs from upstream
- No manual intervention needed
- Main branch stays up-to-date automatically
- Dev branch remains completely separate

## Setup

### 1. Create Workflow File

Create `.github/workflows/sync-upstream.yml`:

```yaml
name: Sync with Upstream

on:
  schedule:
    # Run daily at 2 AM UTC
    - cron: '0 2 * * *'
  workflow_dispatch: # Allows manual trigger

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          ref: main
          fetch-depth: 0
          
      - name: Configure Git
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          
      - name: Add upstream remote
        run: |
          git remote add upstream https://github.com/glittercowboy/get-shit-done.git || true
          
      - name: Sync with upstream
        run: |
          git fetch upstream
          git merge upstream/main --no-edit
          git push origin main
```

### 2. Enable Workflow

1. Commit the workflow file to your repository
2. Push to GitHub
3. Go to Actions tab in your repository
4. Verify the workflow appears

### 3. Manual Trigger (Optional)

You can manually trigger the sync:
1. Go to Actions tab
2. Select "Sync with Upstream" workflow
3. Click "Run workflow"

## Configuration Options

### Change Sync Frequency

Edit the `cron` schedule:

```yaml
# Every 6 hours
- cron: '0 */6 * * *'

# Weekly (Monday at 2 AM)
- cron: '0 2 * * 1'

# Daily at 2 AM (default)
- cron: '0 2 * * *'
```

### Add Notifications

Add Slack/Discord webhook notification on sync:

```yaml
- name: Notify on sync
  if: success()
  run: |
    curl -X POST -H 'Content-type: application/json' \
    --data '{"text":"✅ Upstream sync completed for main branch"}' \
    ${{ secrets.SLACK_WEBHOOK_URL }}
```

### Handle Conflicts

If conflicts occur, the workflow will fail and you'll need to resolve manually:

```yaml
- name: Sync with upstream
  run: |
    git fetch upstream
    if git merge upstream/main --no-edit; then
      git push origin main
      echo "✅ Sync successful"
    else
      echo "❌ Merge conflict detected"
      git merge --abort
      exit 1
    fi
```

## Important Notes

- **Dev branch is never affected** - The workflow only touches `main`
- **Conflicts stop the workflow** - You'll get notified if manual resolution needed
- **Can be disabled anytime** - Simply delete the workflow file
- **Manual sync still available** - You can use `sync-upstream.sh` script

## When NOT to Use This

Don't use automated syncing if:
- You want full control over when to sync
- You frequently need to resolve conflicts
- You prefer manual review of upstream changes
- You sync infrequently (monthly or less)

## Troubleshooting

### Workflow not running

- Check Actions tab for errors
- Verify cron syntax
- Ensure workflow file is in correct location

### Merge conflicts

1. Workflow will fail (expected)
2. Run sync manually: `./sync-upstream.sh`
3. Resolve conflicts
4. Push fixed main branch
5. Workflow will work again on next run

### Authentication errors

GitHub Actions has automatic authentication for pushing to your own repository. No additional setup needed.

## Alternative: Upstream Sync Action

You can also use a pre-built action:

```yaml
name: Sync with Upstream

on:
  schedule:
    - cron: '0 2 * * *'
  workflow_dispatch:

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        
      - uses: aormsby/Fork-Sync-With-Upstream-action@v3.4
        with:
          target_sync_branch: main
          target_repo_token: ${{ secrets.GITHUB_TOKEN }}
          upstream_sync_branch: main
          upstream_sync_repo: glittercowboy/get-shit-done
```

## Summary

Automated syncing is:
- ✅ Convenient for staying current
- ✅ Completely optional
- ✅ Won't affect your dev branch
- ❌ May fail on conflicts (requires manual fix)

Choose based on your workflow preferences!
