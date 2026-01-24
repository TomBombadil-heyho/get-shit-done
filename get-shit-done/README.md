# Custom GSD Extensions

This directory contains custom extensions, workflows, and references for the Get-Shit-Done (GSD) system.

## Purpose

This content is maintained on a separate development branch (`dev`) that remains independent from the upstream repository. When the main branch is synced with the upstream fork (glittercowboy/get-shit-done), these customizations are preserved on the `dev` branch.

## Contents

### References

Custom reference documents and implementation specs for GSD workflows:

- Evaluation methodologies
- Implementation patterns
- Model profiles
- Project planning configurations
- Verification patterns
- And more...

### Workflows

Extended workflow definitions that complement the core GSD commands.

### Templates

Custom templates for various GSD operations.

## Branch Strategy

- **`main`** - Stays in sync with upstream (glittercowboy/get-shit-done)
- **`dev`** - Contains this directory and all custom modifications
- **Syncing** - Use `../sync-upstream.sh` to update main without affecting dev

See `../FORK-MANAGEMENT.md` for complete documentation on managing this fork.

## Usage

Work on this branch for custom GSD modifications:

```bash
# Switch to dev branch
git checkout dev

# Make your changes
git add .
git commit -m "Add custom workflow"
git push origin dev
```

To incorporate upstream updates:

```bash
# Sync main from upstream
./sync-upstream.sh

# Optionally merge into dev
git merge main
```

## Notes

- This content is specific to this fork and not present in the upstream repository
- Changes here won't conflict with upstream updates
- You can selectively merge upstream improvements while maintaining custom content
