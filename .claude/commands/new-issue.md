# /new-issue - Create a New Issue with Unique ID

This command creates a properly formatted issue file with a unique ID for any testing deviations, blockers, or problems found during testing.

## How to Use

Call this command with a feature slug when you need to log an issue:

```
/new-issue json-body
```

This will:
1. Generate a unique 5-digit issue ID (10000-99999)
2. Create the file: `issues/{issue-id}-{slug}.md`
3. Provide a template for documenting the issue
4. Return the issue ID and file path for reference

## Issue File Format

The command creates a file with this structure:

```markdown
# Issue: {issue-id}-{slug}

**Feature**: {slug} - {feature-name}
**Issue ID**: {issue-id}
**Severity**: [critical/high/medium/low]

## What Was Tested

[Exact command and inputs used]

## Expected Behavior

[What the baseline (http) implementation does]

## Actual Behavior

[What the current implementation (spie) does]

## The Problem

[Why this is an issue - functional difference, incorrect output, etc.]

## Impact

[How serious this is - does it break functionality, affect usability, etc.]

## Notes

[Any additional context or observations]
```

## For Agents

If you're an agent and need to create an issue:
1. Determine the feature slug (e.g., "json-body", "verify-option")
2. Invoke `/new-issue {slug}` to get a unique ID and template
3. Use the returned file path to create your issue documentation
4. Fill in all sections of the template with detailed information

Example usage in an agent:
```
I need to log an issue for the json-body feature.
/new-issue json-body
Returns: Issue file created at issues/47293-json-body.md
Now I'll edit this file with the actual issue details...
```
