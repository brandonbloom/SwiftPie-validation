---
description: Orchestrate comprehensive HTTPie feature testing workflow
---

# /run-tests - Orchestrate Full HTTPie Testing Workflow

You are orchestrating a comprehensive white-box comparison test between two HTTP client implementations: `http` (Python/HTTPie baseline) and `spie` (Swift implementation).

## Your Role

You will coordinate the complete testing workflow by:
1. Starting an httpbin server in the background
2. Spawning the checklist-curator agent to ensure all HTTPie features are documented
3. Spawning the feature-tester agent for each feature systematically
4. Coordinating issue logging and final reporting

## Prerequisites Check

Before beginning, verify that both clients are on PATH:
```bash
which http && which spie
```

If either is missing, stop and report the error clearly.

## Starting httpbin Server

Start the httpbin server using the provided script:
```bash
./scripts/start-httpbin.sh
```

The server will be available at `http://localhost:8888`. The script waits for startup and verifies connectivity.

## Phase 1: Update the Checklist

Invoke the `checklist-curator` agent to extract and maintain the feature list.

This agent will:
1. Run `./scripts/extract-features.sh` to extract all features from `http --help`
2. Create or update `checklist.md` with feature slugs and descriptions
3. Preserve test statuses from previous runs if the file exists
4. Report total features extracted and any new/updated entries

Wait for the agent to complete and review the generated `checklist.md`.

## Phase 2: Test All Features

For each feature in `checklist.md` with status "Not Tested" or "Failed":
1. Extract the slug from the table
2. Invoke the `feature-tester` agent with the slug as context

The agent will:
- Design a test plan isolating the feature
- Execute tests comparing `http` vs `spie` behavior
- Document results in `features/{slug}.md`
- Log any deviations to `issues/` directory
- **NOT update checklist.md** (orchestrator does this to prevent race conditions)

After the agent completes:
3. **Read `features/{slug}.md`** to extract the test status (passed/failed/blocked)
4. **Update `checklist.md`** with:
   - Test Status column: the status from the feature file
   - Notes column: brief summary (issue found, blocker reason, etc.)
5. Review any newly created issues in `issues/` directory

## Phase 3: Summary

After all features are tested:
- Count total features in `checklist.md`
- Count passed vs failed tests
- Count total issues logged
- Provide a summary report showing test coverage and key findings

## Phase 4: Synchronize Issues to GitHub (Optional)

After all testing is complete, you may optionally synchronize local issues to the upstream GitHub repository using the `gh` CLI tool.

**When to synchronize:**
- New issues were created during testing
- Existing issues have updates (regressions, new test findings)
- Previously reported issues are now resolved

**GitHub synchronization workflow:**

### For New Issues

Create GitHub issues for newly discovered problems:

```bash
gh issue create --repo brandonbloom/SwiftPie \
  --title "{Feature}: {brief description}" \
  --label bug \
  --body "$(cat <<'EOF'
## Summary
{Brief description of the problem}

## Tested
{Commands and test details}

## Expected vs Actual
- **Expected (http)**: {baseline behavior}
- **Actual (spie)**: {deviant behavior}

## Impact
**Severity**: {critical/high/medium/low}

{Impact description}

## Test Details
Full results: [features/{slug}.md](https://github.com/brandonbloom/SwiftPie-validation/blob/main/features/{slug}.md)

Related local issue: [issues/{id}-{slug}.md](https://github.com/brandonbloom/SwiftPie-validation/blob/main/issues/{id}-{slug}.md)
EOF
)"
```

### For Updated Issues

Add comments to existing GitHub issues when re-testing reveals new information:

```bash
gh issue comment {github-issue-number} --repo brandonbloom/SwiftPie \
  --body "$(cat <<'EOF'
## Update: {date}

{New findings, progress, or regression details}

### Status
{Current status of the issue}

### Test Details
Full results: [features/{slug}.md](link to validation repo)
EOF
)"
```

### For Resolved Issues

When a previously failing feature now passes:

```bash
gh issue close {github-issue-number} --repo brandonbloom/SwiftPie \
  --comment "Feature now passes all tests. Confirmed in validation run on {date}."
```

### For Reopening Regressed Issues

If a previously fixed feature regresses:

```bash
gh issue reopen {github-issue-number} --repo brandonbloom/SwiftPie
gh issue comment {github-issue-number} --repo brandonbloom/SwiftPie \
  --body "Regression detected in latest build. Feature that previously passed now fails. See updated test results."
```

**Important notes:**
- GitHub sync is optional and performed by the orchestrator after testing
- Use `gh issue list --repo brandonbloom/SwiftPie --search "{slug}"` to check if issue already exists
- Link back to the validation repo for detailed test logs
- Include test date in updates to track when issues were verified

## Important Constraints

- **Network**: Only the local httpbin server (localhost:8888) may be accessed. No external network endpoints.
- **Server Management**: httpbin runs in Docker on port 8888. Ensure Docker is running and the container is started before testing begins.
- **Persistence**: All outputs (checklist.md, features/, issues/) should be updated incrementally
- **Re-runnable**: This workflow is designed to be re-run as `spie` evolves

## Checklist Update Protocol

After each feature-tester agent completes:
1. Read the generated `features/{slug}.md` file
2. Extract the test status (passed/failed/blocked) from that file
3. Update the corresponding row in `checklist.md`:
   - Set **Test Status** column to the status from the feature file
   - Set **Notes** column to a brief summary (e.g., key issue found, blocker reason, etc.)
4. This keeps the checklist as a single source of truth, updated only by the orchestrator

This protocol prevents race conditions when multiple agents test features in parallel.

## Reusable Scripts

The following scripts are available in `./scripts/` for this workflow:
- `extract-features.sh` - Extract HTTPie features from help output
- `start-httpbin.sh` - Start httpbin server via Docker on port 8888 (orchestrator responsibility)

## Execution Notes

- Progress is tracked through the file system. Check `checklist.md` to understand current state.
- Feature test results live in `features/{slug}.md` - agents write there, orchestrator reads and syncs to checklist
- If any agent fails, report the failure clearly and stop rather than continuing.
- If something cannot be tested, agents will create an issue documenting why.
- Use the Task tool to spawn agents with clear, self-contained prompts
- Reusable scripts are pre-approved and available in `./scripts/` for agent use
