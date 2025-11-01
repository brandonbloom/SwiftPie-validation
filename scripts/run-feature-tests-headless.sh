#!/bin/bash
# Headless feature test orchestrator
# Runs feature tests in parallel using Claude CLI in headless mode
# Usage: ./run-feature-tests-headless.sh [feature-slug1,feature-slug2,...] [max-parallel]

set -e

FEATURES="${1:-}"
MAX_PARALLEL="${2:-4}"
WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOGS_DIR="${WORK_DIR}/logs"
mkdir -p "$LOGS_DIR"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

if [ -z "$FEATURES" ]; then
    echo "Usage: $0 <feature-slug1,feature-slug2,...> [max-parallel]"
    echo ""
    echo "Example: $0 'json-flag,form-flag,auth-option' 4"
    echo ""
    echo "To test all features from checklist, use:"
    echo "  $0 \"\$(grep '^|' checklist.md | grep 'Not Tested' | awk -F'|' '{print \$2}' | xargs -I {} basename {} | tr -d ' ' | paste -sd ',' -)\" 4"
    exit 1
fi

# Parse feature list
IFS=',' read -ra FEATURE_ARRAY <<< "$FEATURES"

echo -e "${YELLOW}=== HTTPie Headless Feature Testing ===${NC}"
echo "Features to test: ${#FEATURE_ARRAY[@]}"
echo "Max parallel: $MAX_PARALLEL"
echo "Log directory: $LOGS_DIR"
echo ""

# Function to test a single feature
test_feature() {
    local slug=$1
    local log_file="${LOGS_DIR}/test-${slug}.log"

    echo -e "${YELLOW}Testing feature: ${slug}${NC}" | tee -a "$log_file"

    # Run claude CLI in headless mode
    # Note: This requires claude CLI to be installed and configured
    claude -p "You are the feature-tester agent. Test the feature: $slug" \
        --allowedTools "Bash,Read,Write,Edit,Glob,Grep,SlashCommand" \
        --permission-mode acceptEdits \
        --append-system-prompt "HEADLESS_MODE=true\nFEATURE_SLUG=$slug\nHTTPBIN_URL=http://localhost:8888" \
        >> "$log_file" 2>&1

    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ $slug${NC}" | tee -a "$log_file"
        return 0
    else
        echo -e "${RED}✗ $slug (exit code: $exit_code)${NC}" | tee -a "$log_file"
        return 1
    fi
}

# Run tests in parallel with max concurrency
active_jobs=0
results=()

for slug in "${FEATURE_ARRAY[@]}"; do
    # Trim whitespace
    slug=$(echo "$slug" | xargs)

    # Wait if we've reached max parallel
    while [ $active_jobs -ge $MAX_PARALLEL ]; do
        sleep 1
        # Recount active jobs (simple approach)
        active_jobs=$(jobs -r | wc -l)
    done

    # Start test in background
    test_feature "$slug" &
    active_jobs=$((active_jobs + 1))
done

# Wait for all background jobs
echo ""
echo -e "${YELLOW}Waiting for all tests to complete...${NC}"
wait

echo ""
echo -e "${YELLOW}=== Test Summary ===${NC}"

# Aggregate results from feature files
passed=0
failed=0
blocked=0
not_tested=0

for slug in "${FEATURE_ARRAY[@]}"; do
    slug=$(echo "$slug" | xargs)
    feature_file="${WORK_DIR}/features/${slug}.md"

    if [ -f "$feature_file" ]; then
        # Extract status from feature file (simple grep for Status lines)
        if grep -q "Status: PASSED\|PASSED\|passed" "$feature_file" 2>/dev/null; then
            ((passed++))
            echo -e "${GREEN}✓${NC} $slug - PASSED"
        elif grep -q "Status: FAILED\|FAILED\|failed" "$feature_file" 2>/dev/null; then
            ((failed++))
            echo -e "${RED}✗${NC} $slug - FAILED"
        elif grep -q "Status: BLOCKED\|BLOCKED\|blocked" "$feature_file" 2>/dev/null; then
            ((blocked++))
            echo -e "${YELLOW}⊘${NC} $slug - BLOCKED"
        else
            ((not_tested++))
            echo -e "${YELLOW}?${NC} $slug - NOT TESTED"
        fi
    else
        ((not_tested++))
        echo -e "${YELLOW}?${NC} $slug - NO RESULTS FILE"
    fi
done

echo ""
echo "Results:"
echo "  Passed:     $passed"
echo "  Failed:     $failed"
echo "  Blocked:    $blocked"
echo "  Not Tested: $not_tested"
echo ""
echo "Logs saved to: $LOGS_DIR"
