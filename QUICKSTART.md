# Quick Start Guide - HTTPie Testing Infrastructure

## 5-Minute Overview

This project contains a complete testing framework for comparing HTTPie (`http`) with its Swift implementation (`spie`).

### The Problem
Need to verify that `spie` works identically to `http` across all 67 documented features.

### The Solution
Automated testing infrastructure with:
- Headless mode for unattended testing
- Docker sandbox for isolation
- Parallel execution for speed
- Comprehensive result tracking

## Get Started in 3 Steps

### Step 1: Start the Test Server
```bash
# Ensure Docker is running, then:
docker run -p 8888:80 kennethreitz/httpbin &
```

### Step 2: Test a Few Features (Headless)
```bash
./scripts/run-feature-tests-headless.sh "json-flag,form-flag,auth-option" 4
```

### Step 3: Check Results
```bash
# View feature status
cat checklist.md

# View detailed results for json-flag
cat features/json-flag.md

# View any logged issues
ls -la issues/
```

## Three Ways to Run Tests

### Method 1: Interactive (Human-Approved)
Great for exploratory testing and debugging individual features.

```bash
# In Claude Code, run:
/run-tests

# This will:
# 1. Start httpbin server
# 2. Extract all features to checklist.md
# 3. Test each feature (you approve each test)
# 4. Update results as tests complete
```

### Method 2: Headless Script (Fast)
Great for testing specific feature sets without approval prompts.

```bash
# Test a batch of features
./scripts/run-feature-tests-headless.sh \
  "method-argument,url-argument,json-flag,form-flag" 4

# Or test many features in parallel
FEATURES=$(grep "Not Tested" checklist.md | awk -F'|' '{print $2}' | xargs)
./scripts/run-feature-tests-headless.sh "$FEATURES" 8
```

### Method 3: Docker Compose (Full Isolation)
Great for CI/CD and production test runs.

```bash
# Run everything in Docker
docker-compose up --build

# Or with specific features
FEATURE_BATCH="json-flag,form-flag,auth-option" docker-compose up --build
```

## Key Files

### Main Documentation
- **EXECUTION_SUMMARY.md** - What was built and how to use it
- **TESTING_INFRASTRUCTURE.md** - Complete architecture reference
- **HEADLESS_TESTING.md** - Headless mode details and troubleshooting

### Test Configuration
- **checklist.md** - Central feature tracking (created automatically)
- **test-batches.json** - How features are batched for testing
- **docker-compose.yml** - Docker service definitions

### Reusable Scripts
- `scripts/extract-features.sh` - Extract HTTPie features
- `scripts/run-feature-tests-headless.sh` - Run tests headless
- `scripts/orchestrate-tests.sh` - Coordinate test batches
- `scripts/start-httpbin.sh` - Start test server
- See `scripts/README.md` for details

### Test Results
- `features/` - Detailed results per feature
- `issues/` - Deviations between http and spie
- `logs/` - Test execution logs

## Common Tasks

### Extract All Features
```bash
./scripts/extract-features.sh | less
```

### Test All Untested Features
```bash
FEATURES=$(grep "^| " checklist.md | grep "Not Tested" | awk -F'|' '{print $2}' | xargs)
echo "Testing: $FEATURES"
./scripts/run-feature-tests-headless.sh "$FEATURES" 4
```

### Check Test Results
```bash
# Summary
tail -20 checklist.md

# Specific feature details
cat features/json-flag.md

# All issues found
ls -la issues/
```

### Test a Single Feature Manually
```bash
# Terminal 1: Start server
docker run -p 8888:80 kennethreitz/httpbin

# Terminal 2: Test the feature
http GET http://localhost:8888/get
spie GET http://localhost:8888/get
```

### Review Test Batches
```bash
# See how tests are organized
cat test-batches.json | jq '.batches[].name'

# Batch 1 features
cat test-batches.json | jq '.batches[0].features'
```

## Understanding the Results

### Checklist Status Values

| Status | Meaning | Issues |
|--------|---------|--------|
| **Passed** | http and spie behave identically | None |
| **Failed** | Deviations found between implementations | In `issues/` directory |
| **Blocked** | Cannot test (environment constraint) | Blocker issue in `issues/` |
| **Not Tested** | Waiting to be tested | N/A |

### Issue Files

When a feature test fails or is blocked, one or more issues are created in `issues/`:

**Filename format**: `{issue-id}-{slug}.md`
**Example**: `issues/47293-json-body.md`

Each issue contains:
- **Feature**: Which feature the issue affects
- **Issue ID**: Unique 5-digit identifier (10000-99999)
- **Severity**: critical/high/medium/low/blocker
- **What Was Tested**: Exact command used
- **Expected Behavior**: What `http` does (baseline)
- **Actual Behavior**: What `spie` does (deviation)
- **The Problem**: Why this matters
- **Impact**: How serious (functional break, usability, etc.)

See [ISSUE_TRACKING.md](ISSUE_TRACKING.md) for full details on issue format.

### Feature File Structure

Each feature gets a test document at `features/{slug}.md`:

```markdown
# Feature: {name}
## Test Plan
... how we tested it ...

## Results
### http
... actual output ...

### spie
... actual output ...

## Comparison
... what was the same, what differed ...

## Status
PASSED / FAILED / BLOCKED
```

### Issue Files

Deviations are logged at `issues/{issue-id}-{slug}.md`:

```markdown
## Feature
{slug}: {description}

## Tested
... exact command that revealed the issue ...

## Expected
... what http does (baseline) ...

## Actual
... what spie does (deviation) ...

## The Problem
... why this matters ...

## Impact
... how serious (critical/high/medium/low) ...
```

## Infrastructure Components

```
Your Computer
  ├── localhost:8888 ← httpbin test server (Docker)
  ├── scripts/ ← Pre-approved test scripts
  ├── checklist.md ← Feature tracking
  ├── features/ ← Detailed test results
  ├── issues/ ← Deviations logged
  └── logs/ ← Test execution logs

Docker (Optional)
  ├── httpbin ← Test server
  ├── claude-agent ← Test runner
  └── orchestrator ← Result aggregator
```

## Troubleshooting

### "claude: command not found"
Install Claude CLI:
```bash
pip install anthropic-claude-cli
claude auth login
```

### "Cannot connect to Docker daemon"
Start Docker:
```bash
# macOS
open -a Docker

# Linux
sudo systemctl start docker
```

### Tests hanging or timeout
Check httpbin:
```bash
curl http://localhost:8888/get
```

If not responding, restart:
```bash
docker ps | grep httpbin | awk '{print $1}' | xargs docker stop
docker run -p 8888:80 kennethreitz/httpbin &
```

### Permission denied on scripts
Make executable:
```bash
chmod +x scripts/*.sh
```

## Next: Full Test Suite

Once you've validated the setup with a few features:

```bash
# Run all remaining features in Docker
docker-compose up --build

# Or headless
FEATURES=$(grep "^| " checklist.md | grep "Not Tested" | awk -F'|' '{print $2}' | xargs -I {} echo -n "{}, " | sed 's/,$//')
./scripts/run-feature-tests-headless.sh "$FEATURES" 8
```

## Key Principles

✓ **Reusable Scripts**: Stored in `./scripts/`, pre-approved for unlimited reuse
✓ **No Ad-hoc Code**: Never pipe scripts via heredoc
✓ **No httpbin via Python**: Always use Docker
✓ **Orchestrator Updates**: Only orchestrator modifies checklist.md
✓ **Headless Auto-Approval**: Tests run unattended via `--permission-mode acceptEdits`

## Learn More

- See **README_TESTING.md** for documentation index
- See **EXECUTION_SUMMARY.md** for what was built
- See **TESTING_INFRASTRUCTURE.md** for architecture details
- See **HEADLESS_TESTING.md** for headless mode specifics
- See **ISSUE_TRACKING.md** for issue format and handling
- See **scripts/README.md** for script documentation

## Summary

You have a complete testing framework ready to:
- Test any HTTPie feature against httpbin
- Compare http vs spie behavior
- Run tests interactively or automatically
- Track results and deviations
- Generate compatibility reports

**Start testing in 30 seconds**:
```bash
./scripts/run-feature-tests-headless.sh "json-flag,form-flag" 2
```
