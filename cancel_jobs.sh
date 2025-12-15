#!/bin/bash

# Usage: ./cancel_jobs.sh
# Cancels all running workflow jobs on mateuuszzzzz/App

set -e

REPO="mateuuszzzzz/App"

echo "=== Cancelling running jobs on $REPO ==="

# Get all in-progress workflow runs
echo "Fetching running workflows..."
RUNNING_RUNS=$(gh run list --repo "$REPO" --status in_progress --json databaseId,workflowName,headBranch --jq '.[] | "\(.databaseId) \(.workflowName) \(.headBranch)"')

if [ -z "$RUNNING_RUNS" ]; then
    echo "No running workflows found."
    exit 0
fi

echo "Found running workflows:"
echo "$RUNNING_RUNS"
echo ""

# Cancel each run
while IFS= read -r line; do
    RUN_ID=$(echo "$line" | awk '{print $1}')
    WORKFLOW_NAME=$(echo "$line" | awk '{print $2}')
    BRANCH=$(echo "$line" | awk '{print $NF}')

    echo "Cancelling run #$RUN_ID ($WORKFLOW_NAME on $BRANCH)..."
    gh run cancel "$RUN_ID" --repo "$REPO" 2>/dev/null || echo "  Failed to cancel (may already be completed)"
done <<< "$RUNNING_RUNS"

echo ""
echo "=== Done ==="
