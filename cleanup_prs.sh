#!/bin/bash

# Usage: ./cleanup_prs.sh
# Removes all test-pr-* branches (local and remote) on mateuuszzzzz/App

set -e

REPO="mateuuszzzzz/App"

echo "=== Cleaning up test-pr-* branches on $REPO ==="

# Switch to main first to avoid being on a branch we're about to delete
echo "Switching to main branch..."
git checkout main

# Find and delete remote branches matching test-pr-*
echo ""
echo "=== Deleting remote branches ==="
REMOTE_BRANCHES=$(git ls-remote --heads origin | grep -E 'refs/heads/test-pr-[0-9]+(-base)?$' | awk '{print $2}' | sed 's|refs/heads/||' || true)

if [ -z "$REMOTE_BRANCHES" ]; then
    echo "No remote test-pr-* branches found."
else
    echo "Found remote branches:"
    echo "$REMOTE_BRANCHES"
    echo ""
    for branch in $REMOTE_BRANCHES; do
        echo "Deleting remote: $branch"
        git push origin --delete "$branch" 2>/dev/null || echo "  Failed to delete $branch"
    done
fi

# Find and delete local branches matching test-pr-*
echo ""
echo "=== Deleting local branches ==="
LOCAL_BRANCHES=$(git branch --list 'test-pr-*' | sed 's/^[* ]*//' || true)

if [ -z "$LOCAL_BRANCHES" ]; then
    echo "No local test-pr-* branches found."
else
    echo "Found local branches:"
    echo "$LOCAL_BRANCHES"
    echo ""
    for branch in $LOCAL_BRANCHES; do
        echo "Deleting local: $branch"
        git branch -D "$branch" 2>/dev/null || echo "  Failed to delete $branch"
    done
fi

echo ""
echo "=== Cleanup complete ==="
