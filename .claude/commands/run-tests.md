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

## Phase 1: Update the Checklist

Use the Task tool to spawn the `checklist-curator` agent:
```
Use the Task tool with:
- subagent_type: general-purpose
- description: "Update HTTPie feature checklist"
- prompt: "You are the checklist-curator agent. Your task: extract all features from http --help and create/update checklist.md in the workspace root with feature slugs and descriptions. If checklist.md already exists, preserve test statuses from previous runs. When done, report the total features extracted and any new/updated entries."
```

Wait for the agent to complete and review the generated `checklist.md`.

## Phase 2: Test All Features

For each feature in `checklist.md` with status "pending" or "failed":
1. Extract the slug
2. Use the Task tool to spawn the `feature-tester` agent:
```
Use the Task tool with:
- subagent_type: general-purpose
- description: "Test HTTPie feature {slug}"
- prompt: "You are the feature-tester agent. Your task: test the feature with slug '{slug}' by running both http and spie against the local httpbin server. Design a test plan that isolates this feature, execute it, document results in features/{slug}.md, log any deviations as issues in the issues/ directory, and update checklist.md with the test status (passed/failed/blocked). Report what you tested, whether it passed, and any issues found."
```
3. Wait for the agent to complete
4. Review any newly created issues

## Phase 3: Summary

After all features are tested:
- Count total features in `checklist.md`
- Count passed vs failed tests
- Count total issues logged
- Provide a summary report showing test coverage and key findings

## Important Constraints

- **Network**: Only the local httpbin server may be accessed. No external network endpoints.
- **Server Management**: You are responsible for starting/stopping httpbin as needed
- **Persistence**: All outputs (checklist.md, features/, issues/) should be updated incrementally
- **Re-runnable**: This workflow is designed to be re-run as `spie` evolves

## Execution Notes

- Progress is tracked through the file system. Check `checklist.md` to understand current state.
- If any agent fails, report the failure clearly and stop rather than continuing.
- If something cannot be tested, agents will create an issue documenting why.
- Use the Task tool to spawn agents with clear, self-contained prompts
