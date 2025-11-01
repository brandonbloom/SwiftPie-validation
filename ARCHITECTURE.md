# HTTPie Testing Infrastructure - Architecture

## Overview

This document describes the architectural decisions, design patterns, and system design of the HTTPie testing infrastructure.

## Design Goals

1. **Zero Permission Friction**: Headless mode eliminates interactive approval prompts
2. **Massive Parallelization**: 4-8 agents test features simultaneously
3. **Result Consistency**: Single source of truth (checklist.md) prevents data corruption
4. **Reproducibility**: Docker sandbox enables identical test environments
5. **Extensibility**: Easy to add new scripts, batches, or test strategies
6. **Debuggability**: Comprehensive logging and result documentation

## Architectural Patterns

### 1. Orchestrator Pattern

**Problem**: Multiple agents need to coordinate without conflicts

**Solution**: Single orchestrator updates central checklist.md

```
feature-tester agents (isolated)
  ↓ writes to
features/{slug}.md (each agent)
  ↓ read by
orchestrator (single controller)
  ↓ writes to
checklist.md (central coordination point)
```

**Benefits**:
- No race conditions on checklist updates
- Clear separation of concerns
- Easy to debug and audit
- Agents work independently

### 2. Headless Mode Pattern

**Problem**: Interactive approvals block parallelization

**Solution**: Claude CLI with `--permission-mode acceptEdits`

```
User Action
  ↓
claude -p "prompt" --permission-mode acceptEdits
  ↓
Agent runs headless (no prompts)
  ↓
File modifications auto-approved
  ↓
Results written directly
```

**Benefits**:
- True parallel execution
- No blocking on user interaction
- Scriptable/automatable
- Integration with CI/CD

### 3. Pre-approved Scripts Pattern

**Problem**: Need to run helper scripts without re-approval each time

**Solution**: Store scripts as files in ./scripts/ (not ad-hoc heredocs)

```
First run:./script.sh (user approves)
Future runs: ./script.sh (pre-approved, no prompt)
```

**Benefits**:
- Scripts reusable without re-approval
- Version controlled
- Easy to update
- Clear accountability

### 4. Three-Layer Execution Pattern

**Interactive**: User has full control, sees each step
```
/run-tests → Approval prompts → Feature tests → Updates checklist
```

**Headless**: Fast automated testing
```
./run-feature-tests-headless.sh → Auto-approval → Parallel tests → Aggregation
```

**Docker**: Complete isolation
```
docker-compose up → Sandboxed httpbin → Parallel agents → Result sync
```

**Benefits**:
- Choose execution mode per use case
- Flexible deployment options
- Clear progression from simple to complex

## System Components

### Slash Command: /run-tests
**Type**: Orchestration entry point
**Responsible for**: Workflow coordination
**Does NOT do**: Test individual features
**Calls**: checklist-curator and feature-tester agents

### Agent: checklist-curator
**Type**: Feature extraction worker
**Input**: http --help output
**Output**: checklist.md
**Idempotent**: Yes (preserves previous test status)

### Agent: feature-tester
**Type**: Feature testing worker
**Input**: feature slug from checklist
**Outputs**:
- features/{slug}.md (test results)
- issues/{id}-{slug}.md (deviations)
**Key constraint**: Does NOT update checklist.md

### Scripts (./scripts/)
**Type**: Pre-approved helpers
**Reusable**: Yes (approve once, use infinitely)
**Examples**:
- extract-features.sh (feature list)
- start-httpbin.sh (server management)
- run-feature-tests-headless.sh (batch orchestration)
- orchestrate-tests.sh (result coordination)

### Configuration Files
**test-batches.json**: Feature batching strategy
**docker-compose.yml**: Service definitions
**Dockerfiles**: Container images

## Data Flow

### Feature Extraction Flow
```
http --help
  ↓ extract-features.sh
  ↓ parse-help.py
  ↓ checklist-curator agent
  ↓
checklist.md (67 features with metadata)
```

### Feature Testing Flow
```
checklist.md (select untested feature)
  ↓ feature-tester agent
  ↓ test http vs spie
  ↓
features/{slug}.md (detailed results + status)
  ↓ detected deviations
  ↓
issues/{id}-{slug}.md (deviation documentation)
  ↓ orchestrator reads feature file
  ↓
checklist.md (status updated)
```

### Headless Execution Flow
```
run-feature-tests-headless.sh "feat1,feat2,feat3" 4
  ↓ spawns 4 agents in parallel
  ↓ claude CLI headless mode (auto-approves)
  ↓ each agent: tests feature, writes results
  ↓
features/{slug}.md × 3 (results from parallel agents)
  ↓ aggregate results
  ↓
checklist.md (all statuses updated)
```

### Docker Flow
```
docker-compose up
  ↓ httpbin service starts (port 8888)
  ↓ orchestrator service starts
  ↓ reads test-batches.json
  ↓ spawns feature-tester agents per batch
  ↓ agents test features (parallel)
  ↓
features/ + issues/ + logs/
  ↓ orchestrator aggregates results
  ↓
checklist.md (final sync)
```

## Design Decisions & Tradeoffs

### Decision 1: Orchestrator-Controlled Checklist
**Alternative**: Each agent updates checklist directly
**Why not**: Race conditions, data corruption with parallelism
**Chosen approach**: Single orchestrator updates checklist
**Tradeoff**: Slightly more complex workflow, but guaranteed consistency

### Decision 2: Headless Mode via Claude CLI
**Alternative**: Custom test runner script
**Why not**: Losing Claude's reasoning and test design capabilities
**Chosen approach**: Use Claude CLI in headless mode
**Benefit**: Full AI reasoning power without interactive friction

### Decision 3: Pre-approved Scripts vs Ad-hoc
**Alternative**: Generate scripts via heredoc as needed
**Why not**: Can't be approved once and reused
**Chosen approach**: Store permanent scripts in ./scripts/
**Benefit**: Scripts pre-approved, reusable unlimited times

### Decision 4: Feature Files + Issues Separate
**Alternative**: Log everything to a single results file
**Why not**: Hard to navigate, maintain, diff
**Chosen approach**: features/{slug}.md for tests, issues/ for deviations
**Benefit**: Clear separation, easy to review, scannable

### Decision 5: Docker Compose (not custom orchestration)
**Alternative**: Write custom orchestration in Python/Shell
**Why not**: Reinventing container orchestration
**Chosen approach**: Standard docker-compose.yml
**Benefit**: Standard tool, easy to understand, CI/CD friendly

## Performance Characteristics

### Parallelism
- **Per-agent parallelism**: 1 (each agent tests 1 feature sequentially)
- **Batch parallelism**: 4-8 agents simultaneously (configurable)
- **Total throughput**: 4 features tested in parallel = 4x speedup

### Timing
- Per feature test: 30-60 seconds
- Full suite (67 features):
  - 4 parallel agents: ~45 minutes
  - 2 parallel agents: ~90 minutes
  - 1 agent (sequential): ~45 hours

### Resource Usage
- **Memory per agent**: ~200-300 MB (Claude CLI + test tools)
- **Network**: Only localhost:8888 (no external)
- **Disk**: ~10 MB per feature file + logs

## Extensibility Points

### Add New Script
1. Create `scripts/new-script.sh` (permanent file)
2. Update `scripts/README.md`
3. Reference in agent definitions or commands
4. Script is automatically pre-approved for future use

### Add New Test Batch
1. Update `test-batches.json` with new batch definition
2. Specify features, parallelism, timeouts
3. Reference in orchestration workflow

### Add New Feature Test
1. Feature automatically included once added to checklist.md
2. feature-tester agent can test any slug
3. Results follow established pattern: features/{slug}.md

### Add New Output Mode
1. Create new Dockerfile or docker-compose service
2. Script the orchestration logic
3. Integrate with result aggregation

## Security Considerations

### Network Isolation (Docker)
- Services only communicate internally
- No external network access
- httpbin only on localhost:8888

### File Permissions
- Scripts executable (chmod +x)
- Test results readable by orchestrator
- No sensitive data in test artifacts

### API Keys
- Claude API key via environment variable
- Not stored in configs or scripts
- Only visible to authenticated services

## Testing the Infrastructure

### Unit Tests
- Individual script functionality
- Agent behavior in headless mode
- Result parsing from feature files

### Integration Tests
- Full workflow: extract → test → aggregate
- Headless mode functionality
- Docker compose orchestration

### Performance Tests
- Parallel agent execution
- Result aggregation time
- Checklist update performance

## Monitoring & Observability

### Logs
- `logs/test-{slug}.log` - Per-feature execution logs
- `logs/batch-{n}.log` - Per-batch logs (headless mode)

### Metrics
- Feature test count (in checklist.md)
- Pass/fail/blocked rates
- Test execution time
- Error frequencies

### Debugging
- Feature files document exact commands run
- Issue files explain deviations found
- Logs capture full execution output

## Future Enhancements

### Short Term
- [ ] Implement actual headless feature-tester invocation
- [ ] Add test result caching
- [ ] Create GitHub Actions workflow

### Medium Term
- [ ] Automatic issue creation and assignment
- [ ] Performance regression detection
- [ ] Test coverage metrics dashboard
- [ ] Parallel orchestrator instances

### Long Term
- [ ] Machine learning for test prioritization
- [ ] Automated spie improvement suggestions
- [ ] Bi-directional HTTP/HTTPS testing
- [ ] Feature compatibility matrix visualization

## References

- Claude Code Headless: https://docs.claude.com/en/docs/claude-code/headless
- Slash Commands: https://docs.claude.com/en/docs/claude-code/slash-commands
- Sub-Agents: https://docs.claude.com/en/docs/claude-code/sub-agents
- Docker Compose: https://docs.docker.com/compose/
