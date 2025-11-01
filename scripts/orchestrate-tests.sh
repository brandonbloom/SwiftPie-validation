#!/bin/bash
# Test orchestration script - manages feature test batches
# Runs in Docker orchestrator container, coordinates feature-tester agents

set -e

WORK_DIR="${WORK_DIR:-.}"
LOGS_DIR="${WORK_DIR}/logs"
BATCH_CONFIG="${WORK_DIR}/test-batches.json"
CHECKLIST="${WORK_DIR}/checklist.md"
FEATURES_DIR="${WORK_DIR}/features"
ISSUES_DIR="${WORK_DIR}/issues"

# Create required directories
mkdir -p "$LOGS_DIR" "$FEATURES_DIR" "$ISSUES_DIR"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== HTTPie Feature Test Orchestration ===${NC}"
echo "Checklist: $CHECKLIST"
echo "Features dir: $FEATURES_DIR"
echo "Issues dir: $ISSUES_DIR"
echo "Logs dir: $LOGS_DIR"
echo ""

# Function to extract untested/failed features from checklist
get_untested_features() {
    if [ ! -f "$CHECKLIST" ]; then
        echo "Error: $CHECKLIST not found" >&2
        return 1
    fi

    # Extract slugs from checklist where status is "Not Tested" or "Failed"
    grep -E '^\|' "$CHECKLIST" \
        | grep -E 'Not Tested|Failed' \
        | awk -F'|' '{print $2}' \
        | xargs -I {} basename {} \
        | tr -d ' '
}

# Function to update checklist with feature status
update_checklist_status() {
    local slug=$1
    local status=$2
    local notes=$3

    if [ ! -f "$CHECKLIST" ]; then
        echo "Error: Checklist not found" >&2
        return 1
    fi

    # Read feature file to get actual status if not provided
    local feature_file="${FEATURES_DIR}/${slug}.md"
    if [ -z "$status" ] && [ -f "$feature_file" ]; then
        if grep -q "PASSED\|Status: PASSED" "$feature_file" 2>/dev/null; then
            status="Passed"
        elif grep -q "FAILED\|Status: FAILED" "$feature_file" 2>/dev/null; then
            status="Failed"
        elif grep -q "BLOCKED\|Status: BLOCKED" "$feature_file" 2>/dev/null; then
            status="Blocked"
        fi
    fi

    if [ -z "$status" ]; then
        echo "Warning: Could not determine status for $slug" >&2
        return 1
    fi

    # Update checklist (simple string replacement)
    # Find the row for this slug and update status and notes
    local pattern="^\| ${slug} \|"
    if grep -q "$pattern" "$CHECKLIST"; then
        # Extract the full line and replace it
        local old_line=$(grep "$pattern" "$CHECKLIST" | head -1)
        local new_line=$(echo "$old_line" | sed "s/| [^|]* | [^|]* |$status.*|/ | $status | $notes |/")
        sed -i.bak "s|$old_line|$new_line|" "$CHECKLIST"
    fi
}

# Function to process a batch of features
process_batch() {
    local batch_number=$1
    shift
    local features=("$@")

    echo -e "${YELLOW}Processing Batch $batch_number (${#features[@]} features)${NC}"

    local batch_log="${LOGS_DIR}/batch-${batch_number}.log"
    {
        for slug in "${features[@]}"; do
            slug=$(echo "$slug" | xargs)
            echo "Testing: $slug"

            # Run feature test via claude headless CLI
            # This is a placeholder - actual implementation depends on claude CLI availability
            echo "  [Would run feature-tester for $slug]"
        done
    } | tee "$batch_log"
}

# Main orchestration flow
echo -e "${YELLOW}Step 1: Reading test batches configuration${NC}"
if [ -f "$BATCH_CONFIG" ]; then
    echo "Using batch configuration: $BATCH_CONFIG"
else
    echo "Batch configuration not found at $BATCH_CONFIG"
    echo "Will test features in default batches"
fi

echo ""
echo -e "${YELLOW}Step 2: Identifying untested features${NC}"
untested_features=$(get_untested_features)
untested_count=$(echo "$untested_features" | wc -w)
echo "Found $untested_count untested/failed features"

if [ $untested_count -eq 0 ]; then
    echo -e "${GREEN}All features tested!${NC}"
    exit 0
fi

echo ""
echo -e "${YELLOW}Step 3: Organizing features into batches${NC}"

# Simple batching strategy: divide features into groups of 4
batch_size=4
batch_number=1
current_batch=()

for slug in $untested_features; do
    current_batch+=("$slug")

    if [ ${#current_batch[@]} -ge $batch_size ]; then
        process_batch "$batch_number" "${current_batch[@]}"
        ((batch_number++))
        current_batch=()
    fi
done

# Process remaining features
if [ ${#current_batch[@]} -gt 0 ]; then
    process_batch "$batch_number" "${current_batch[@]}"
fi

echo ""
echo -e "${YELLOW}Step 4: Aggregating results${NC}"

# Read all feature files and update checklist
passed=0
failed=0
blocked=0

for feature_file in "$FEATURES_DIR"/*.md; do
    if [ ! -f "$feature_file" ]; then
        continue
    fi

    slug=$(basename "$feature_file" .md)

    if grep -q "PASSED\|Status: PASSED" "$feature_file" 2>/dev/null; then
        ((passed++))
        update_checklist_status "$slug" "Passed"
        echo -e "${GREEN}✓${NC} $slug - PASSED"
    elif grep -q "FAILED\|Status: FAILED" "$feature_file" 2>/dev/null; then
        ((failed++))
        update_checklist_status "$slug" "Failed"
        echo -e "${RED}✗${NC} $slug - FAILED"
    elif grep -q "BLOCKED\|Status: BLOCKED" "$feature_file" 2>/dev/null; then
        ((blocked++))
        update_checklist_status "$slug" "Blocked"
        echo -e "${YELLOW}⊘${NC} $slug - BLOCKED"
    fi
done

echo ""
echo -e "${BLUE}=== Final Summary ===${NC}"
echo "Passed:  $passed"
echo "Failed:  $failed"
echo "Blocked: $blocked"
echo ""
echo -e "${GREEN}Orchestration complete!${NC}"
echo "Review results in: $CHECKLIST"
