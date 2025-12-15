#!/bin/bash

# Usage: ./copy_pr.sh <PR_NUMBER>
# Copies a PR from Expensify/App to mateuuszzzzz/App for testing AI reviewer
# Works with open, closed, and merged PRs - always produces 1:1 identical diff

set -e

if [ -z "$1" ]; then
    echo "Usage: ./copy_pr.sh <PR_NUMBER>"
    exit 1
fi

PR_NUMBER=$1

echo "=== Copying PR #$PR_NUMBER from Expensify/App ==="

# Get PR info including state
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

# Branch names
BASE_BRANCH_NAME="test-pr-$PR_NUMBER-base"
HEAD_BRANCH_NAME="test-pr-$PR_NUMBER"

# Download the PR diff (this is the "true" diff, works for all PR states)
echo "Downloading PR diff..."
gh pr diff "$PR_NUMBER" --repo Expensify/App > /tmp/pr-$PR_NUMBER.diff
DIFF_STATS=$(cat /tmp/pr-$PR_NUMBER.diff | diffstat -s 2>/dev/null || echo "$(cat /tmp/pr-$PR_NUMBER.diff | wc -l) lines")
echo "Diff stats: $DIFF_STATS"

# Find the base commit depending on PR state
if [ "$PR_STATE" = "MERGED" ] && [ -n "$MERGE_COMMIT" ]; then
    echo "PR is merged. Finding base from merge commit..."

    # Fetch the merge commit
    git fetch https://github.com/Expensify/App.git "$MERGE_COMMIT" 2>/dev/null || \
        git fetch https://github.com/Expensify/App.git "$BASE_REF"

    # The first parent of merge commit is the base branch state at merge time
    BASE_COMMIT=$(git rev-parse "$MERGE_COMMIT^1" 2>/dev/null)

    if [ -z "$BASE_COMMIT" ]; then
        echo "Error: Could not find parent of merge commit"
        exit 1
    fi
    echo "Base commit (merge parent): $BASE_COMMIT"
else
    echo "PR is $PR_STATE. Finding base from merge-base..."

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

# Create base branch
echo "Creating base branch from $BASE_COMMIT..."
git checkout -B "$BASE_BRANCH_NAME" "$BASE_COMMIT"

# Create head branch by applying the diff
echo "Creating head branch by applying diff..."
git checkout -B "$HEAD_BRANCH_NAME" "$BASE_COMMIT"

# Apply the diff
if ! git apply /tmp/pr-$PR_NUMBER.diff; then
    echo "Error: Failed to apply diff cleanly"
    echo "This might happen if the PR has conflicts or unusual changes"
    git checkout main
    exit 1
fi

# Commit the changes
git add -A
git commit -m "Apply PR #$PR_NUMBER diff" --no-verify

# Verify the diff matches
echo "Verifying diff matches original..."
APPLIED_STATS=$(git diff "$BASE_BRANCH_NAME".."$HEAD_BRANCH_NAME" | diffstat -s 2>/dev/null || echo "unknown")
echo "Applied diff stats: $APPLIED_STATS"

# Push both branches to fork
echo "Pushing branches to mateuuszzzzz/App..."
git push -u origin "$BASE_BRANCH_NAME" --force
git push -u origin "$HEAD_BRANCH_NAME" --force

# Create PR
echo "Creating PR..."

# Sanitize PR body - replace GitHub issue/PR URLs with just the number
SANITIZED_BODY=$(echo "$PR_BODY" | perl -pe 's{https://github\.com/[^/]+/[^/]+/(issues|pull)/([0-9]+)}{$2}g')

gh pr create \
    --title "[Test] $PR_TITLE" \
    --body "Testing AI reviewer on copy:
  Repo: Expensify/App
  PR: $PR_NUMBER
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
