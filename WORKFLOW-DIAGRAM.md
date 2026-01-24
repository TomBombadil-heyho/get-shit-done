# Visual Workflow Diagram

## Branch Relationship Flow

```
┌─────────────────────────────────────────────────────────────┐
│          Upstream Repository (Original)                      │
│         glittercowboy/get-shit-done                          │
│                                                               │
│  • Maintained by original author                             │
│  • Receives updates and improvements                         │
│  • You have read-only access                                 │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      │ git fetch upstream
                      │ git merge upstream/main
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│          Your Fork - main branch                             │
│         TomBombadil-heyho/get-shit-done (main)               │
│                                                               │
│  • Mirror of upstream                                        │
│  • Never modified directly                                   │
│  • Updated via sync-upstream.sh                              │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      │ git merge main (optional)
                      │ or cherry-pick specific commits
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│          Your Fork - dev branch                              │
│         TomBombadil-heyho/get-shit-done (dev)                │
│                                                               │
│  • Your custom modifications                                 │
│  • Contains get-shit-done/ directory                         │
│  • Never touched by upstream sync                            │
│  • Where you do all your work                                │
└─────────────────────────────────────────────────────────────┘
```

## Daily Workflow Sequence

```
┌─────────────┐
│   Start     │
│   Day       │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│ git checkout    │
│      dev        │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐      ┌──────────────────┐
│  Make Changes   │──────▶│  git commit      │
│  to Files       │      │  git push        │
└─────────────────┘      └──────────────────┘
```

## Upstream Sync Workflow

```
┌──────────────────┐
│ ./sync-upstream  │
│      .sh         │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Save current     │
│ branch (dev)     │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ git checkout     │
│      main        │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ git fetch        │
│    upstream      │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ git merge        │
│ upstream/main    │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ git push         │
│  origin main     │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ git checkout     │
│      dev         │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ ✅ Done!         │
│ dev unchanged    │
└──────────────────┘
```

## Optional: Merge Upstream Into Dev

```
┌──────────────────┐
│ After syncing    │
│ main from        │
│ upstream...      │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ git checkout     │
│      dev         │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐      ┌──────────────────┐
│  git merge       │      │ Conflicts?       │
│     main         │─────▶│ Resolve them     │
└────────┬─────────┘      └────────┬─────────┘
         │                         │
         │◀────────────────────────┘
         │
         ▼
┌──────────────────┐
│  git push        │
│  origin dev      │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ ✅ Done!         │
│ dev has upstream │
│ updates merged   │
└──────────────────┘
```

## Repository Structure

```
TomBombadil-heyho/get-shit-done/
│
├── main branch (syncs with upstream)
│   ├── commands/
│   ├── agents/
│   ├── bin/
│   ├── scripts/
│   ├── README.md
│   ├── package.json
│   └── ... (all standard files)
│
└── dev branch (your custom work)
    ├── commands/              (same as main)
    ├── agents/                (same as main)
    ├── bin/                   (same as main)
    ├── scripts/               (same as main)
    │
    ├── get-shit-done/         ⭐ YOUR CUSTOM DIRECTORY
    │   ├── README.md
    │   ├── references/
    │   ├── workflows/
    │   └── templates/
    │
    ├── FORK-MANAGEMENT.md     ⭐ YOUR DOCUMENTATION
    ├── QUICK-REFERENCE.md     ⭐ YOUR DOCUMENTATION
    ├── sync-upstream.sh       ⭐ YOUR SCRIPT
    ├── README.md              (modified with fork notice)
    └── ... (all other files)
```

## Timeline Example

```
Day 1: Fork Repository
   └─▶ main branch created (mirrors upstream)
   └─▶ dev branch created (based on main)
   └─▶ Add custom content to get-shit-done/
   └─▶ Commit and push to dev

Day 7: Upstream has updates
   └─▶ Run ./sync-upstream.sh
   └─▶ main updated with upstream changes
   └─▶ dev still has your custom work (unchanged)

Day 7 (cont): Want upstream features?
   └─▶ git checkout dev
   └─▶ git merge main
   └─▶ Resolve any conflicts
   └─▶ git push origin dev

Day 14: More custom work
   └─▶ git checkout dev
   └─▶ Make changes in get-shit-done/
   └─▶ Commit and push to dev

Day 21: Sync again
   └─▶ Run ./sync-upstream.sh
   └─▶ main updated (dev untouched)
   └─▶ Continue working on dev
```

## Key Principles Visualized

### ❌ WRONG: Working on main

```
You: git checkout main
You: git add custom-file.md
You: git commit -m "Add custom content"
You: ./sync-upstream.sh
Result: CONFLICT! Your changes conflict with upstream
```

### ✅ CORRECT: Working on dev

```
You: git checkout dev
You: git add custom-file.md
You: git commit -m "Add custom content"
You: ./sync-upstream.sh
Result: ✅ main synced, dev unchanged, no conflicts!
```

## Summary

```
┌────────────────────────────────────────┐
│  Upstream          Your Fork           │
│  ─────────         ─────────           │
│                                         │
│  Updates    ══▶    main (mirror)       │
│                                         │
│                         │               │
│                         │ merge         │
│                         ▼               │
│                                         │
│                    dev (custom work)   │
│                    ⭐ get-shit-done/   │
│                                         │
└────────────────────────────────────────┘

Legend:
══▶  : Automatic sync (sync-upstream.sh)
│    : Optional manual merge (when you want upstream features)
⭐   : Your custom content (safe from upstream)
```

---

This visual guide helps understand how the three-way relationship works:
1. **Upstream** (original) → **main** (your mirror) → **dev** (your work)
2. Upstream → main is automatic and safe
3. main → dev is optional and controlled by you
4. Your custom work on dev is always protected
