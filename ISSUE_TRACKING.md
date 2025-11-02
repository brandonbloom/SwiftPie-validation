# Issue Tracking for HTTPie Testing

This document explains how deviations and blockers are tracked during feature testing.

## Overview

When testing finds a deviation between `http` and `spie`, it must be logged as an issue with a unique ID. Issues are stored in the `issues/` directory with standardized formatting.

## Issue Types

### 1. Deviation Issues
A functional difference between `http` and `spie` implementations.

**Example**: JSON formatting differs, authentication headers missing, etc.

**Severity**: critical/high/medium/low

### 2. Blocker Issues
A testing constraint that prevents a feature from being tested.

**Example**: Requires elevated privileges, needs external network, missing dependencies

**Severity**: blocker

## Creating an Issue

### For Agents
Use the `/new-issue` slash command:

```bash
/new-issue json-body
```

This will:
1. Generate unique 5-digit issue ID (10000-99999)
2. Create file: `issues/{issue-id}-{slug}.md`
3. Provide template for documentation
4. Return file path for editing

### Example Workflow

```
Feature-tester agent tests json-body feature
  ↓ Finds deviation: JSON formatting differs
  ↓ Invokes: /new-issue json-body
  ↓ Returns: Issue ID 47293, file issues/47293-json-body.md
  ↓ Edits file with detailed findings
  ↓ Updates feature file with status: failed
```

## Issue File Format

Each issue file follows this standard template:

```markdown
# Issue: {issue-id}-{slug}

**Feature**: {slug} - {feature-name}
**Issue ID**: {issue-id}
**Severity**: [critical/high/medium/low]

## What Was Tested

[Exact command and inputs used]
Example: http --json POST http://localhost:8888/post name=John

## Expected Behavior

[What the baseline (http) implementation does]
Example: Sends Content-Type: application/json header

## Actual Behavior

[What the current implementation (spie) does]
Example: Missing Content-Type header

## The Problem

[Why this is an issue - functional difference, incorrect output, etc.]
Example: Server cannot parse request body without proper Content-Type

## Impact

[How serious this is - does it break functionality, affect usability, etc.]
Example: HIGH - Breaks JSON request functionality in spie

## Notes

[Any additional context or observations]
Example: Works fine with --form flag
```

## Severity Levels

| Level | Description | When to Use |
|-------|-------------|------------|
| **critical** | Breaks core functionality | Feature completely non-functional |
| **high** | Major deviation affecting use | Wrong headers, missing fields |
| **medium** | Noticeable but workaround exists | Output formatting differs |
| **low** | Minor issue with minimal impact | User-Agent string different |
| **blocker** | Cannot test due to constraints | Elevated privileges required |

## Issue Organization

Issues are stored in `issues/` with naming pattern: `{issue-id}-{slug}.md`

### Example Structure
```
issues/
├── 47293-json-body.md          # JSON formatting deviation
├── 47294-auth-option.md        # Authentication header missing
├── 47295-ssl-certificate.md    # Cannot test (blocker - no certs)
├── 47296-verify-option.md      # SSL verification differs
└── 47297-compress-flag.md      # Deflate compression not implemented
```

## Linking Issues to Features

Feature files reference related issues:

**In `features/{slug}.md`:**
```markdown
## Issues Found

- Issue 47293: JSON formatting differs
- Issue 47294: Content-Type header missing
```

**In `checklist.md`:**
```markdown
| json-body | JSON Body | ... | Failed | Issues: 47293, 47294 |
```

## Querying Issues

### Find all issues for a feature
```bash
grep -l "{slug}" issues/*.md
```

### Find all critical issues
```bash
grep -l "critical" issues/*.md
```

### Find all blockers
```bash
grep -l "blocker" issues/*.md
```

### Generate issue summary
```bash
wc -l issues/*.md | tail -1
grep "^**Severity**:" issues/*.md | cut -d: -f2 | sort | uniq -c
```

## Issue Lifecycle

### Created
Feature-tester finds deviation → invokes `/new-issue {slug}`
File: `issues/{issue-id}-{slug}.md`
Status: Documented

### Reviewed
Orchestrator reads issue files
Updates checklist with issue references
Status: Tracked

### Analyzed
Review all issues for a feature
Prioritize fixes
Status: Analyzed

### Fixed (Optional)
spie implementation updated to fix deviation
Re-test feature
Update issue status or close
Status: Resolved/Closed

## Examples

### Example 1: JSON Formatting Deviation

```markdown
# Issue: 47293-json-body

**Feature**: json-body - JSON Body Serialization
**Issue ID**: 47293
**Severity**: high

## What Was Tested

```bash
http --json POST http://localhost:8888/post name=John age:=30
```

## Expected Behavior

JSON body formatted with proper indentation:
```json
{
  "name": "John",
  "age": 30
}
```

## Actual Behavior

JSON body formatted without indentation:
```json
{"name":"John","age":30}
```

## The Problem

spie does not format JSON with standard indentation, making output hard to read
and differs from http's pretty-printing behavior.

## Impact

HIGH - Affects user experience and readability of API responses
```

### Example 2: SSL Certificate Blocker

```markdown
# Issue: 47295-ssl-certificate

**Feature**: verify-option - SSL Certificate Verification
**Issue ID**: 47295
**Severity**: blocker

## What Was Tested

Attempted to test SSL certificate verification with self-signed cert

## Expected Behavior

Test with both valid and invalid certificates to verify behavior

## Actual Behavior

Cannot create self-signed certificates in test environment

## The Problem

Testing SSL verification requires certificate management tools (openssl)
that are not available in the test environment.

## Impact

BLOCKER - Cannot test SSL feature in current environment.
Would require pre-generated test certificates or elevated privileges.

## Notes

This is a testing constraint, not a functional issue with spie.
Could be resolved by pre-generating test certificates.
```

## Synchronizing Issues with GitHub

Issues documented locally in `issues/` can be synchronized to the upstream SwiftPie GitHub repository using the `gh` CLI tool.

### Prerequisites

Install and authenticate the GitHub CLI:
```bash
# Install gh (if not already installed)
brew install gh  # macOS
# or: sudo apt install gh  # Linux

# Authenticate
gh auth login
```

### Creating GitHub Issues from Local Issues

When a new issue is discovered during testing:

1. **Create the local issue** using `/new-issue {slug}` command
2. **Document the issue** with all test details in `issues/{id}-{slug}.md`
3. **Create GitHub issue** with the `gh` tool:

```bash
# Create new GitHub issue from local issue file
gh issue create --repo brandonbloom/SwiftPie \
  --title "Feature: {feature-name} - {brief description}" \
  --label bug \
  --body "$(cat issues/{id}-{slug}.md)"
```

### Updating Existing GitHub Issues

When re-testing a feature reveals new information:

```bash
# Add comment to existing GitHub issue
gh issue comment {github-issue-number} --repo brandonbloom/SwiftPie \
  --body "$(cat <<'EOF'
## Update: {date}

{New findings or status update}

See detailed test results: [features/{slug}.md](link)
EOF
)"
```

### Reopening Closed Issues

If a previously fixed feature regresses:

```bash
# Reopen issue and add update
gh issue reopen {github-issue-number} --repo brandonbloom/SwiftPie
gh issue comment {github-issue-number} --repo brandonbloom/SwiftPie \
  --body "Regression detected in latest build. See updated test results."
```

### GitHub Issue Workflow Example

Complete workflow for synchronizing issues:

```bash
#!/bin/bash
# Sync all local issues to GitHub

REPO="brandonbloom/SwiftPie"

for issue_file in issues/*.md; do
  slug=$(basename "$issue_file" .md | cut -d'-' -f2-)
  issue_id=$(basename "$issue_file" .md | cut -d'-' -f1)

  # Extract title and severity from issue file
  title=$(grep "^# Issue:" "$issue_file" | sed 's/# Issue: //')
  severity=$(grep "^\*\*Severity\*\*:" "$issue_file" | cut -d: -f2 | tr -d ' ')

  # Check if issue already exists on GitHub
  existing=$(gh issue list --repo "$REPO" --search "$slug" --json number --jq '.[0].number')

  if [ -z "$existing" ]; then
    # Create new issue
    echo "Creating GitHub issue for $slug..."
    gh issue create --repo "$REPO" \
      --title "$title" \
      --label "bug" \
      --label "severity:$severity" \
      --body-file "$issue_file"
  else
    echo "Issue already exists: #$existing for $slug"
  fi
done
```

### Listing GitHub Issues

View current issues on GitHub:

```bash
# List all open issues
gh issue list --repo brandonbloom/SwiftPie

# List issues by label
gh issue list --repo brandonbloom/SwiftPie --label bug

# Search for specific feature
gh issue list --repo brandonbloom/SwiftPie --search "timeout"

# View specific issue details
gh issue view {issue-number} --repo brandonbloom/SwiftPie
```

### Bulk Operations

Update multiple issues at once:

```bash
# Close all issues for features that now pass
for slug in json-body auth-basic; do
  issue_num=$(gh issue list --repo brandonbloom/SwiftPie --search "$slug" --json number --jq '.[0].number')
  if [ -n "$issue_num" ]; then
    gh issue close "$issue_num" --repo brandonbloom/SwiftPie \
      --comment "Feature now passes all tests. Confirmed in latest validation run."
  fi
done
```

### Integration with Testing Workflow

Add to the `/run-tests` orchestrator or feature-tester agent:

```markdown
## Phase 4: Synchronize Issues to GitHub (Optional)

After testing completes, optionally sync issues to GitHub:

1. For each newly created issue in `issues/`:
   - Create corresponding GitHub issue with `gh issue create`
   - Include link back to validation repo for detailed test logs

2. For existing issues that have updates:
   - Add comment with `gh issue comment`
   - Link to updated test results

3. For issues that are now resolved:
   - Close with `gh issue close`
   - Document which changes fixed the issue
```

## Integrating with CI/CD

### GitHub Actions Example
```yaml
- name: Run HTTPie tests
  run: ./scripts/run-feature-tests-headless.sh "..." 4

- name: Check for critical issues
  run: grep -l "critical" issues/*.md && exit 1 || echo "No critical issues"

- name: Sync issues to GitHub
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: |
    for issue_file in issues/*.md; do
      slug=$(basename "$issue_file" .md | cut -d'-' -f2-)
      existing=$(gh issue list --search "$slug" --json number --jq '.[0].number')
      [ -z "$existing" ] && gh issue create --title "$(head -1 $issue_file)" --body-file "$issue_file"
    done

- name: Report
  run: cat checklist.md
```

## Best Practices

1. **Create issues immediately** when deviation found
   - Don't wait until end of feature test
   - Document while details are fresh

2. **Be specific** in issue details
   - Exact commands used
   - Actual vs expected output
   - Reproducible steps

3. **Include severity** for prioritization
   - Critical issues first
   - Blockers noted separately

4. **Reference related issues**
   - Link to other deviations in same feature
   - Group related problems

5. **Keep notes** for context
   - Workarounds if any exist
   - Related features affected
   - Investigation notes

## Reporting

### Generate Issue Summary
```bash
echo "# HTTPie Testing Issues Summary"
echo ""
echo "Total Issues: $(ls issues/*.md 2>/dev/null | wc -l)"
echo ""
echo "By Severity:"
for severity in critical high medium low blocker; do
  count=$(grep -l "**Severity**: $severity" issues/*.md 2>/dev/null | wc -l)
  echo "  $severity: $count"
done
```

### Generate Detailed Report
```bash
for issue in issues/*.md; do
  echo "## $(basename $issue)"
  grep -A 1 "^## " "$issue"
  echo ""
done
```

## Files Involved

| File | Role |
|------|------|
| `issues/{id}-{slug}.md` | Detailed issue documentation |
| `features/{slug}.md` | References related issues |
| `checklist.md` | Summary with issue counts |
| `.claude/commands/new-issue.md` | Issue creation command |

## Related Documentation

- **ARCHITECTURE.md** - Design patterns including issue tracking
- **feature-tester.md** - Agent that creates issues
- **TESTING_INFRASTRUCTURE.md** - Full system reference
