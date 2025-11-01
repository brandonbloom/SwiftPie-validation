# HTTPie vs SwiftPie White-Box Testing Workspace

Part of the https://github.com/brandonbloom/SwiftPie vibe-coding experiment.

## Overview

This workspace compares two HTTP client implementations:
- **`http`** - The official Python implementation of HTTPie (baseline)
- **`spie`** - A work-in-progress Swift clone of HTTPie

The testing workflow consists of three phases:

1. **Checklist Phase** - Extract and maintain a comprehensive list of HTTPie features from its `--help` output
2. **Testing Phase** - Execute test plans for individual features
3. **Orchestration** - Coordinate the full testing workflow

## How to Run

Start the testing workflow:
```bash
/run-tests
```

This slash command will orchestrate the entire process by spawning agents for checklist curation and feature testing.

The workflow uses dedicated agents to avoid context overload:
- **checklist-curator** - Extracts HTTPie features and maintains the checklist
- **feature-tester** - Tests individual features and documents deviations
- **run-tests** - Orchestrates the workflow (slash command)

## Design Principles

- **Re-runnable**: All agents detect existing outputs and update them appropriately, supporting iterative testing as `spie` evolves
- **Isolated Testing**: All tests execute against a local httpbin server; no external network access
- **Clear Attribution**: Each feature gets a slug identifier (valid filename component) for easy reference
- **Issue Tracking**: Any deviation between `http` and `spie` is documented as an issue
- **Context-Efficient**: Heavy lifting delegated to specialized agents to avoid context overload in the orchestrator

## Directory Structure

- `checklist.md` - Master list of HTTPie features with slugs (auto-updated by checklist-curator agent)
- `features/{slug}.md` - Test plan and results for each feature
- `issues/{issue-id}-{feature-slug}.md` - Detailed issue documentation (created by feature-tester agent)
- `.claude/agents/` - Agent definitions for checklist-curator and feature-tester
- `.claude/commands/run-tests.md` - Orchestration slash command

## Key Concepts

**Feature Slug**: A URL/filename-safe identifier derived from a feature name (e.g., `json-body` for JSON request bodies). Used as an anchor throughout the workflow.

**Issue**: Any deviation between `http` and `spie` behavior. Must document:
- What was tested
- What was expected
- What actually happened
- Why it is an issue

**Issue ID**: Generated with `python3 -c 'import random; print(random.randint(10000, 99999))'`

## Testing Environment

- **HTTP Server**: A local httpbin instance runs in the background during testing
- **Constraints**: Only test using `http` and `spie` CLIs against the local httpbin server
- **Server Documentation**: See `./context/httpbin-swagger.json` for the API specification

## Prerequisites

Both `http` and `spie` must be on your PATH before starting. Verify with:
```bash
which http && which spie
```
