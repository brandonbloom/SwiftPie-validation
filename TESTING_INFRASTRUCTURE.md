# HTTPie Testing Infrastructure

## Summary

This document describes the complete testing infrastructure for comparing HTTPie (`http`) and Swift implementation (`spie`) behavior across all features.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                  /run-tests Command                      │
│  (Orchestrator for comprehensive HTTPie feature testing)  │
└─────────────────────────────────────────────────────────┘
                            ↓
    ┌───────────────────────────────────────┐
    │  Start httpbin server (Docker)         │
    │  on http://localhost:8888              │
    └───────────────────────────────────────┘
                            ↓
    ┌───────────────────────────────────────┐
    │  checklist-curator Agent               │
    │  Extract all HTTPie features           │
    │  from http --help output               │
    └───────────────────────────────────────┘
                            ↓
    ┌───────────────────────────────────────┐
    │  feature-tester Agent (Per Feature)    │
    │  Test http vs spie behavior            │
    │  Document deviations                   │
    └───────────────────────────────────────┘
                            ↓
    ┌───────────────────────────────────────┐
    │  Orchestrator Updates Checklist        │
    │  Syncs feature results to central      │
    │  checklist.md                          │
    └───────────────────────────────────────┘
```

## Key Components

### 1. Slash Command: `/run-tests`

**File**: `.claude/commands/run-tests.md`

Orchestrates the complete testing workflow:

1. **Phase 1**: Start httpbin server via Docker
2. **Phase 2**: Run checklist-curator agent to extract all features
3. **Phase 3**: Run feature-tester agent for each feature systematically
4. **Phase 4**: Aggregate results and generate summary report

**Key Features**:
- Network isolation (only localhost:8888 accessed)
- Pre-approved scripts in `./scripts/` directory
- Prevents race conditions with orchestrator-controlled checklist updates
- Re-runnable workflow as spie evolves

### 2. Agents

#### checklist-curator Agent
**File**: `.claude/agents/checklist-curator.md`

**Responsibilities**:
- Extract features from `http --help` output
- Create/update `checklist.md` with feature descriptions
- Preserve test status from previous runs
- Validate feature slugs and descriptions

**Reusable Scripts**:
- `./scripts/extract-features.sh` - Gets http --help output

#### feature-tester Agent
**File**: `.claude/agents/feature-tester.md`

**Responsibilities**:
- Design isolated test plans for individual features
- Compare http vs spie behavior
- Document test results in `features/{slug}.md`
- Create issues for any deviations using `/new-issue` command
- Update feature file status (passed/failed/blocked)

**Key Protocol**:
- Do NOT update checklist.md (orchestrator does this)
- Create issues for all deviations
- Document blockers if testing is impossible

### 3. Reusable Scripts

**Location**: `./scripts/`

All scripts are pre-approved for future runs without requiring user approval.

#### extract-features.sh
- Extracts all HTTPie features from `http --help`
- Used by checklist-curator agent
- No dependencies on external tools

#### start-httpbin.sh
- Starts httpbin server via Docker on port 8888
- Verifies connectivity before returning
- Idempotent (safe to run multiple times)

#### run-feature-tests-headless.sh
- Orchestrates headless testing with Claude CLI
- Runs feature tests in parallel (configurable max parallelism)
- Auto-approves file modifications via `--permission-mode acceptEdits`
- Aggregates results from feature files

#### orchestrate-tests.sh
- Runs in Docker orchestrator container
- Reads test-batches.json configuration
- Manages feature batches and parallel execution
- Updates checklist.md with results

### 4. Test Artifacts

**Directory Structure**:

```
httpie-delta/
├── checklist.md              # Central source of truth for feature status
├── features/                 # Detailed test results per feature
│   ├── method-argument.md
│   ├── url-argument.md
│   └── ...
├── issues/                   # Tracked deviations between http and spie
│   ├── 47293-json-body.md
│   └── ...
├── logs/                     # Test execution logs
│   ├── test-json-flag.log
│   └── ...
└── HEADLESS_TESTING.md       # Documentation for headless mode
```

### 5. Configuration Files

#### test-batches.json
Defines feature test batches for parallel execution:
- 12 logical batches organizing 67 features
- Specifies max parallelism per batch
- Includes timeout and retry policies
- Example: Batch 1 (Core Request Features) = 4 features × 4 parallel agents

#### docker-compose.yml
Defines sandboxed test environment:
- **httpbin**: Test server service
- **claude-agent**: Feature testing container
- **orchestrator**: Test coordination container
- Network isolation between services

#### Dockerfiles
- `Dockerfile.claude-agent`: Claude CLI + testing tools
- `Dockerfile.orchestrator`: Test orchestration container

## Testing Flow

### Interactive Mode (Current)

1. User runs `/run-tests` command
2. Orchestrator starts httpbin
3. checklist-curator extracts features → checklist.md created
4. For each feature:
   - User approves feature-tester agent spawn
   - Agent designs test plan
   - Agent executes tests (http vs spie)
   - Agent creates issues for deviations
   - Orchestrator reads feature file and updates checklist
5. Orchestrator generates summary report

### Headless Mode (Automated)

1. Run: `./scripts/run-feature-tests-headless.sh "feature1,feature2,..." 4`
2. Claude CLI spawns in headless mode with `--permission-mode acceptEdits`
3. Tests run in parallel (4 agents default)
4. Results automatically aggregated
5. Checklist updated without user interaction

### Docker Compose Mode (Full Isolation)

```bash
docker-compose up --build
```

Runs complete test suite in sandboxed environment with:
- Fresh httpbin instance per run
- Isolated Claude agent containers
- Orchestrator managing batch execution
- No external network access

## Test Status Tracking

**checklist.md** contains all feature states:

| Test Status | Meaning | Action |
|------------|---------|--------|
| Not Tested | Not yet tested | Pending test execution |
| Passed | http and spie behave identically | Feature working correctly |
| Failed | Deviations found between implementations | Issues logged in issues/ |
| Blocked | Cannot test due to environmental constraints | Blocker issue logged |

## Important Constraints

### Network
- **Only** http://localhost:8888 can be accessed
- No external network endpoints
- httpbin server managed by orchestrator

### Server Management
- Orchestrator starts/stops httpbin
- Each agent reuses the shared httpbin instance
- Agents do NOT manage server lifecycle

### Persistence
- All outputs (checklist.md, features/, issues/) are incremental
- Previous test statuses are preserved
- Workflow is re-runnable as spie evolves

### Race Conditions
- Orchestrator updates checklist.md (not individual agents)
- Agents write to features/{slug}.md only
- Prevents concurrent checklist modifications

## Important Notes

### Never Run httpbin Via Python
Always use Docker: `docker run -p 8888:80 kennethreitz/httpbin`

### Pre-approved Scripts
All scripts in `./scripts/` are pre-approved for reuse:
- No temporary ad-hoc scripts via heredoc
- Create permanent script files instead
- Documented in scripts/README.md

### Feature Testing Best Practices
1. Test one feature at a time (isolation)
2. Document exact commands used (reproducibility)
3. Any difference = issue (even minor ones)
4. If something cannot be tested, document why (blocker)

## Usage Examples

### Extract all features
```bash
./scripts/extract-features.sh
```

### Test specific features headless
```bash
./scripts/run-feature-tests-headless.sh "json-flag,form-flag,auth-option" 4
```

### Run full test suite in Docker
```bash
docker-compose up --build
```

### Test a single feature manually
```bash
# Start httpbin
docker run -p 8888:80 kennethreitz/httpbin &

# Test json-flag feature
http --json POST http://localhost:8888/post name=John
spie --json POST http://localhost:8888/post name=John

# Compare outputs
```

## Current Status

**Features Tested**: 2 / 67
- method-argument: ✓ PASSED
- url-argument: ✓ PASSED

**Features Remaining**: 65
- Not Tested: 64
- Failed (already tracked): 1 (version-flag)

**Infrastructure Ready**: ✓ Complete
- Reusable scripts: Ready
- Docker infrastructure: Ready
- Headless mode setup: Ready
- Test batching: Configured
- Orchestration framework: Implemented

## Next Steps

1. **Quick Test**: Run first batch via headless mode
   ```bash
   ./scripts/run-feature-tests-headless.sh "request-item-headers,request-item-url-params,request-item-data-fields,request-item-json-fields" 4
   ```

2. **Full Test Suite**: Run all remaining features
   ```bash
   docker-compose up --build
   ```

3. **Review Results**: Check checklist.md and issues/ directory

4. **Report Generation**: Create final summary of compatibility

## References

- HTTPie Documentation: https://httpie.io/docs
- httpbin API: http://httpbin.org/
- Claude Code Headless: https://docs.claude.com/en/docs/claude-code/headless
- Slash Commands: https://docs.claude.com/en/docs/claude-code/slash-commands
- Sub-Agents: https://docs.claude.com/en/docs/claude-code/sub-agents
