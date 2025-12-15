#!/bin/bash

# Usage: ./copy_pr.sh <PR_NUMBER>
# Copies a PR from Expensify/App to mateuuszzzzz/App for testing AI reviewer
# Always produces 1:1 identical diff, never has conflicts

set -e

if [ -z "$1" ]; then
    echo "Usage: ./copy_pr.sh <PR_NUMBER>"
    exit 1
fi

PR_NUMBER=$1

echo "=== Copying PR #$PR_NUMBER from Expensify/App ==="

# Get PR info including merge status
echo "Fetching PR info..."
PR_INFO=$(gh pr view "$PR_NUMBER" --repo Expensify/App --json title,body,baseRefName,state,mergeCommit)
PR_TITLE=$(echo "$PR_INFO" | jq -r '.title')
PR_BODY=$(echo "$PR_INFO" | jq -r '.body')
BASE_REF=$(echo "$PR_INFO" | jq -r '.baseRefName')
PR_STATE=$(echo "$PR_INFO" | jq -r '.state')
MERGE_COMMIT=$(echo "$PR_INFO" | jq -r '.mergeCommit.oid // empty')

echo "Title: $PR_TITLE"
echo "Base ref: $BASE_REF"
echo "State: $PR_STATE"

# Download the PR diff (this is the "true" diff, always correct)
echo "Downloading PR diff..."
gh pr diff "$PR_NUMBER" --repo Expensify/App > /tmp/pr-$PR_NUMBER.diff
echo "Diff size: $(wc -l < /tmp/pr-$PR_NUMBER.diff) lines"

# Find the correct base commit depending on PR state
if [ "$PR_STATE" = "MERGED" ] && [ -n "$MERGE_COMMIT" ]; then
    echo "PR is merged. Using merge commit parent as base..."
    echo "Merge commit: $MERGE_COMMIT"

    # Get first parent SHA via GitHub API (can't use git rev-parse on unfetched commit)
    BASE_COMMIT=$(gh api "repos/Expensify/App/commits/$MERGE_COMMIT" --jq '.parents[0].sha')
    echo "Base commit (from API): $BASE_COMMIT"

    # Fetch the base commit
    git fetch https://github.com/Expensify/App.git "$BASE_COMMIT" 2>/dev/null || true
else
    echo "PR is $PR_STATE. Using merge-base..."

    # Fetch PR head
    git fetch https://github.com/Expensify/App.git "pull/$PR_NUMBER/head"
    PR_HEAD=$(git rev-parse FETCH_HEAD)
    echo "PR head: $PR_HEAD"

    # Fetch base branch
    git fetch https://github.com/Expensify/App.git "$BASE_REF"
    BASE_HEAD=$(git rev-parse FETCH_HEAD)

    # Find merge-base
    BASE_COMMIT=$(git merge-base "$PR_HEAD" "$BASE_HEAD")
    echo "Base commit (merge-base): $BASE_COMMIT"
fi

if [ -z "$BASE_COMMIT" ]; then
    echo "Error: Could not determine base commit"
    exit 1
fi

# Branch names
BASE_BRANCH_NAME="test-pr-$PR_NUMBER-base"
HEAD_BRANCH_NAME="test-pr-$PR_NUMBER"

# Create base branch
echo "Creating base branch from $BASE_COMMIT..."
git checkout -B "$BASE_BRANCH_NAME" "$BASE_COMMIT"

# Create head branch and apply diff
echo "Creating head branch and applying diff..."
git checkout -B "$HEAD_BRANCH_NAME" "$BASE_COMMIT"

if ! git apply /tmp/pr-$PR_NUMBER.diff; then
    echo "Error: Failed to apply diff"
    echo "This should not happen - please report this issue"
    git checkout main
    rm -f /tmp/pr-$PR_NUMBER.diff
    exit 1
fi

# Commit the changes
git add -A
git commit -m "PR #$PR_NUMBER: $PR_TITLE" --no-verify

# Verify diff matches
echo ""
echo "=== Verifying diff ==="
ORIGINAL_FILES=$(grep -c "^diff --git" /tmp/pr-$PR_NUMBER.diff || echo "0")
APPLIED_FILES=$(git diff "$BASE_BRANCH_NAME".."$HEAD_BRANCH_NAME" | grep -c "^diff --git" || echo "0")
echo "Original PR: $ORIGINAL_FILES files changed"
echo "Applied diff: $APPLIED_FILES files changed"

if [ "$ORIGINAL_FILES" != "$APPLIED_FILES" ]; then
    echo "Warning: File count mismatch!"
fi

# Push both branches to fork
echo ""
echo "Pushing branches to mateuuszzzzz/App..."
git push -u origin "$BASE_BRANCH_NAME" --force
git push -u origin "$HEAD_BRANCH_NAME" --force

# Create PR
echo "Creating PR..."

# Sanitize PR body
SANITIZED_BODY=$(echo "$PR_BODY" | perl -pe 's{https://github\.com/[^/]+/[^/]+/(issues|pull)/([0-9]+)}{$2}g' 2>/dev/null || echo "$PR_BODY")

gh pr create \
    --title "[Test] $PR_TITLE" \
    --body "Testing AI reviewer on copy of Expensify/App#$PR_NUMBER
Original state: $PR_STATE

---
$SANITIZED_BODY" \
    --base "$BASE_BRANCH_NAME" \
    --head "$HEAD_BRANCH_NAME"

# Return to main branch
echo "Switching back to main..."
git checkout main

# Cleanup
rm -f /tmp/pr-$PR_NUMBER.diff

echo "Done!"
