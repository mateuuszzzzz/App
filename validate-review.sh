#!/bin/bash

# Usage: ./validate-review.sh <TEST_PR_NUMBER>
# Creates a validation report folder comparing AI reviewer output
# between your fork and original PR

set -e

if [ -z "$1" ]; then
    echo "Usage: ./validate-review.sh <TEST_PR_NUMBER>"
    echo "Example: ./validate-review.sh 13"
    exit 1
fi

TEST_PR_NUMBER=$1
FORK_REPO="mateuuszzzzz/App"
ORIGINAL_REPO="Expensify/App"
DEV_BRANCH="add-react-compiler-context-to-ai-reviewer"
REPORT_DIR="validation-report-$TEST_PR_NUMBER"

echo "=== Creating validation report for PR #$TEST_PR_NUMBER ==="

# Create report directory
rm -rf "$REPORT_DIR"
mkdir -p "$REPORT_DIR"

# Get test PR info and extract original PR number from body
echo "Fetching test PR info..."
PR_BODY=$(gh pr view "$TEST_PR_NUMBER" --repo "$FORK_REPO" --json body --jq '.body')
BASE_BRANCH=$(gh pr view "$TEST_PR_NUMBER" --repo "$FORK_REPO" --json baseRefName --jq '.baseRefName')

# Try new format first: "  PR: 76277", fallback to old format: "Expensify/App#76277"
ORIGINAL_PR_NUMBER=$(echo "$PR_BODY" | grep -E '^\s*PR: [0-9]+' | grep -oE '[0-9]+' | head -1)
if [ -z "$ORIGINAL_PR_NUMBER" ]; then
    ORIGINAL_PR_NUMBER=$(echo "$PR_BODY" | grep -oE 'Expensify/App#[0-9]+' | grep -oE '[0-9]+' | head -1)
fi

if [ -z "$ORIGINAL_PR_NUMBER" ]; then
    echo "ERROR: Could not extract original PR number from test PR body"
    exit 1
fi

echo "Test PR: $FORK_REPO#$TEST_PR_NUMBER"
echo "Original PR: $ORIGINAL_REPO#$ORIGINAL_PR_NUMBER"
echo "Base branch: $BASE_BRANCH"
echo "Report directory: $REPORT_DIR/"

# ============================================
# FILE 0: Instructions for Claude
# ============================================
echo "Writing instructions..."
cat > "$REPORT_DIR/00-instructions.md" << 'EOF'
# Validation Report Instructions

## Your Task
Analyze this report to validate if the AI reviewer changes in `add-react-compiler-context-to-ai-reviewer` branch work correctly.

## Key Things to Check

### 1. Did Claude use `checkReactCompilerOptimization.sh`?
- Search in `04-fork-report.json` for: `checkReactCompilerOptimization`
- If NOT found - this is a BUG. Claude should check React Compiler context before flagging PERF-4

### 2. PERF-4 Decision Flow - Was it followed correctly?
The correct flow is:
1. Is child memoized? (check `"optimized": true` or `memo(`)
   - If NO → Skip PERF-4 (memoizing props won't help)
2. Is parent optimized by React Compiler?
   - If YES (`"optimized": true`) → Skip PERF-4 (compiler auto-memoizes)
   - If NO → Flag PERF-4 (programmer must memoize manually)

### 3. Compare with Original Review
- Look at `05-original-comments.md` for original Claude comments
- Did original Claude incorrectly flag PERF-4?
- Did humans reject those comments? Look for responses like:
  - "React Compiler handles this"
  - "not needed"
  - "compiler optimizes this"
  - "unnecessary"
- Did the new version (in `03-fork-comments.md`) fix this problem?

### 4. False Positives / False Negatives
- **False Positive**: Claude flagged something that shouldn't be flagged
- **False Negative**: Claude missed something that should be flagged

## Report Files
- `01-rule-changes.diff` - Changes to .claude/ folder (the rules being tested)
- `02-pr-diff.diff` - The PR code being reviewed
- `03-fork-comments.md` - Review output from YOUR fork (new rules)
- `04-fork-report.json` - Full Claude execution report (check tool usage!)
- `05-original-comments.md` - Review from ORIGINAL PR (old rules + human responses)

## Expected Outcome
After your changes, Claude should:
1. Always call `checkReactCompilerOptimization.sh` before PERF-4 analysis
2. NOT flag PERF-4 when parent is optimized by React Compiler
3. Only flag PERF-4 when parent is NOT compiled AND child IS memoized
EOF

# ============================================
# FILE 1: Rule changes diff
# ============================================
echo "Generating rule changes diff..."
git fetch origin "$BASE_BRANCH" 2>/dev/null || true
git fetch origin "$DEV_BRANCH" 2>/dev/null || true

git diff "origin/$BASE_BRANCH".."origin/$DEV_BRANCH" -- .claude/ > "$REPORT_DIR/01-rule-changes.diff" 2>/dev/null || echo "(Could not generate diff)" > "$REPORT_DIR/01-rule-changes.diff"

# ============================================
# FILE 2: PR diff
# ============================================
echo "Fetching PR diff..."
gh pr diff "$TEST_PR_NUMBER" --repo "$FORK_REPO" > "$REPORT_DIR/02-pr-diff.diff" 2>/dev/null || echo "(Could not fetch PR diff)" > "$REPORT_DIR/02-pr-diff.diff"

# ============================================
# FILE 3: Fork comments (new rules)
# ============================================
echo "Fetching fork comments..."
{
    echo "# Review from Fork (New Rules)"
    echo "Repo: $FORK_REPO#$TEST_PR_NUMBER"
    echo ""
    echo "## PR Comments"
    echo ""
    gh pr view "$TEST_PR_NUMBER" --repo "$FORK_REPO" --json comments --jq '.comments[] | "### \(.author.login) at \(.createdAt)\n\(.body)\n"' 2>/dev/null || echo "(No comments)"
    echo ""
    echo "## Inline Review Comments"
    echo ""
    gh api "repos/$FORK_REPO/pulls/$TEST_PR_NUMBER/comments" --jq '.[] | "### \(.user.login) at \(.created_at)\nFile: \(.path):\(.line // .original_line)\n\n\(.body)\n"' 2>/dev/null || echo "(No inline comments)"
} > "$REPORT_DIR/03-fork-comments.md"

# ============================================
# FILE 4: Fork execution report (artifact)
# ============================================
echo "Fetching Claude execution report..."
# Get the head branch name from the PR itself
HEAD_BRANCH=$(gh pr view "$TEST_PR_NUMBER" --repo "$FORK_REPO" --json headRefName --jq '.headRefName')
echo "PR head branch: $HEAD_BRANCH"

RUN_ID=$(gh run list --repo "$FORK_REPO" --workflow "claude-review.yml" --json databaseId,headBranch --jq ".[] | select(.headBranch == \"$HEAD_BRANCH\") | .databaseId" | head -1)
if [ -n "$RUN_ID" ]; then
    echo "Downloading artifact from run $RUN_ID..."
    TEMP_DIR=$(mktemp -d)
    if gh run download "$RUN_ID" --repo "$FORK_REPO" -n "claude-report-$TEST_PR_NUMBER" -D "$TEMP_DIR" 2>/dev/null; then
        if [ -f "$TEMP_DIR/claude-execution-output.json" ]; then
            cp "$TEMP_DIR/claude-execution-output.json" "$REPORT_DIR/04-fork-report.json"
        else
            echo "(Artifact downloaded but JSON file not found)" > "$REPORT_DIR/04-fork-report.json"
        fi
    else
        echo "(Could not download artifact - may not exist yet)" > "$REPORT_DIR/04-fork-report.json"
    fi
    rm -rf "$TEMP_DIR"
else
    echo "(No workflow run found for this PR)" > "$REPORT_DIR/04-fork-report.json"
fi

# ============================================
# FILE 5: Original PR comments (old rules + human responses)
# ============================================
echo "Fetching original PR comments..."
{
    echo "# Review from Original PR (Old Rules)"
    echo "Repo: $ORIGINAL_REPO#$ORIGINAL_PR_NUMBER"
    echo ""
    echo "## PR Comments"
    echo ""
    gh pr view "$ORIGINAL_PR_NUMBER" --repo "$ORIGINAL_REPO" --json comments --jq '.comments[] | "### \(.author.login) at \(.createdAt)\n\(.body)\n"' 2>/dev/null || echo "(No comments)"
    echo ""
    echo "## Inline Review Comments (with reply threading)"
    echo ""
    gh api "repos/$ORIGINAL_REPO/pulls/$ORIGINAL_PR_NUMBER/comments" --jq '.[] | "### \(.user.login) at \(.created_at)\nFile: \(.path):\(.line // .original_line)\nIn-Reply-To-ID: \(.in_reply_to_id // "none (top-level)")\n\n\(.body)\n"' 2>/dev/null || echo "(No inline comments)"
} > "$REPORT_DIR/05-original-comments.md"

echo ""
echo "=== Report created in $REPORT_DIR/ ==="
echo ""
ls -la "$REPORT_DIR/"
echo ""
echo "Start by reading: $REPORT_DIR/00-instructions.md"
