#!/bin/bash
# sync-upstream.sh - Sync main branch with upstream repository
# This script safely updates your main branch from the upstream repository
# while keeping your development branch (dev) completely unchanged.

set -euo pipefail  # Exit on any error, treat unset variables as errors, fail on pipe errors

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Syncing from upstream repository...${NC}"
echo ""

# Check if upstream remote exists
if ! git remote | grep -q "^upstream$"; then
    echo -e "${YELLOW}⚠️  Upstream remote not found.${NC}"
    echo "Adding upstream remote: https://github.com/glittercowboy/get-shit-done.git"
    git remote add upstream https://github.com/glittercowboy/get-shit-done.git
    echo -e "${GREEN}✅ Upstream remote added${NC}"
    echo ""
fi

# Save current branch
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${BLUE}📍 Current branch: ${CURRENT_BRANCH}${NC}"

# Check for uncommitted or staged changes
if ! git diff-index --quiet HEAD -- || ! git diff-index --quiet --cached HEAD --; then
    echo -e "${RED}❌ Error: You have uncommitted or staged changes${NC}"
    echo "Please commit or stash your changes before syncing."
    echo ""
    echo "To stash changes temporarily:"
    echo "  git stash"
    echo ""
    echo "To commit changes:"
    echo "  git add ."
    echo "  git commit -m 'Your message'"
    exit 1
fi

# Fetch from upstream
echo ""
echo -e "${BLUE}📥 Fetching upstream changes...${NC}"
git fetch upstream

# Check if main branch exists locally
if ! git show-ref --verify --quiet refs/heads/main; then
    echo -e "${YELLOW}⚠️  Local main branch doesn't exist, creating it...${NC}"
    git checkout -b main upstream/main
    git push -u origin main
    echo -e "${GREEN}✅ Main branch created and pushed${NC}"
else
    # Switch to main branch
    echo ""
    echo -e "${BLUE}🔀 Switching to main branch...${NC}"
    git checkout main

    # Update main from upstream
    echo -e "${BLUE}🔀 Merging upstream changes into main...${NC}"
    git merge upstream/main

    # Push to origin
    echo ""
    echo -e "${BLUE}📤 Pushing updated main to your fork...${NC}"
    git push origin main
fi

# Return to original branch
echo ""
echo -e "${BLUE}↩️  Returning to ${CURRENT_BRANCH}...${NC}"
git checkout "$CURRENT_BRANCH"

echo ""
echo -e "${GREEN}✅ Sync complete!${NC}"
echo ""
echo -e "${GREEN}Summary:${NC}"
echo "  • Main branch updated from upstream"
echo "  • Your ${CURRENT_BRANCH} branch is unchanged"
echo "  • You can continue working on ${CURRENT_BRANCH}"
echo ""
echo -e "${YELLOW}Next steps (optional):${NC}"
echo "  • To merge upstream changes from main into ${CURRENT_BRANCH}:"
echo "    ${BLUE}git merge main${NC}"
echo ""
echo "  • To cherry-pick specific commits from main:"
echo "    ${BLUE}git cherry-pick <commit-hash>${NC}"
echo ""
