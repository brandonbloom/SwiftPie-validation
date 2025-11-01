# HTTPie Testing Infrastructure - Complete Documentation Index

## Quick Navigation

### 👋 New to This Project?
Start here: **[QUICKSTART.md](QUICKSTART.md)** (5 minutes)

### 🏗️ How It Works
See: **[ARCHITECTURE.md](ARCHITECTURE.md)** (design & patterns)

### 📊 What Was Built
See: **[EXECUTION_SUMMARY.md](EXECUTION_SUMMARY.md)** (complete summary)

### 🤖 Running Tests
See: **[TESTING_INFRASTRUCTURE.md](TESTING_INFRASTRUCTURE.md)** (full reference)

### ⚡ Headless Mode
See: **[HEADLESS_TESTING.md](HEADLESS_TESTING.md)** (setup & troubleshooting)

### 🔧 Scripts
See: **[scripts/README.md](scripts/README.md)** (script documentation)

---

## Documentation Map

### Getting Started
| File | Purpose | Read Time |
|------|---------|-----------|
| **[QUICKSTART.md](QUICKSTART.md)** | 5-minute intro to testing | 5 min |
| **[scripts/README.md](scripts/README.md)** | Pre-approved scripts | 3 min |
| **[ISSUE_TRACKING.md](ISSUE_TRACKING.md)** | Issue creation & tracking | 5 min |

### Architecture & Design
| File | Purpose | Read Time |
|------|---------|-----------|
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | Design patterns & decisions | 10 min |
| **[TESTING_INFRASTRUCTURE.md](TESTING_INFRASTRUCTURE.md)** | Complete architecture | 15 min |

### Implementation Details
| File | Purpose | Read Time |
|------|---------|-----------|
| **[EXECUTION_SUMMARY.md](EXECUTION_SUMMARY.md)** | What was accomplished | 10 min |
| **[HEADLESS_TESTING.md](HEADLESS_TESTING.md)** | Headless mode & Docker | 10 min |

### Configuration Files
| File | Purpose |
|------|---------|
| `test-batches.json` | Feature batching strategy |
| `docker-compose.yml` | Docker service definitions |
| `Dockerfile.claude-agent` | Testing container |
| `Dockerfile.orchestrator` | Orchestration container |
| `.claude/commands/run-tests.md` | Main slash command |
| `.claude/agents/checklist-curator.md` | Feature extraction agent |
| `.claude/agents/feature-tester.md` | Feature testing agent |

### Scripts (Pre-approved, Reusable)
| Script | Purpose | Location |
|--------|---------|----------|
| `extract-features.sh` | Extract HTTPie features | scripts/ |
| `start-httpbin.sh` | Start test server | scripts/ |
| `run-feature-tests-headless.sh` | Headless orchestrator | scripts/ |
| `orchestrate-tests.sh` | Batch coordinator | scripts/ |
| `parse-help.py` | Help text parser | scripts/ |

### Test Results
| Location | Contains |
|----------|----------|
| `checklist.md` | All 67 features + status |
| `features/` | Detailed test results |
| `issues/` | Deviations found |
| `logs/` | Execution logs |

---

## Three Ways to Test

### 1. Interactive (/run-tests)
Ideal for: Exploratory, debugging, user control

```bash
# In Claude Code, run:
/run-tests

# Then test features with approval prompts
```

### 2. Headless Script
Ideal for: Batch testing, CI/CD, speed

```bash
./scripts/run-feature-tests-headless.sh "json-flag,form-flag" 4
```

### 3. Docker Compose
Ideal for: Production, isolation, reproducibility

```bash
docker-compose up --build
```

---

## Key Concepts

### Orchestrator Pattern
- **Agents** test features → write to `features/{slug}.md`
- **Orchestrator** reads results → updates `checklist.md`
- **Prevents** race conditions on central checklist

### Headless Mode
- Claude CLI with `--permission-mode acceptEdits`
- Auto-approves file modifications
- Enables true parallel execution

### Pre-approved Scripts
- Stored as files in `./scripts/`
- Approved once, reused infinitely
- Never ad-hoc heredocs

### Three Layers
1. **Interactive**: Human-controlled, approval prompts
2. **Headless**: Automated, no prompts, parallel
3. **Docker**: Isolated, sandboxed, reproducible

---

## Important Constraints

✓ **Never run httpbin via Python** → Always use Docker
✓ **Create scripts as files** → Not ad-hoc heredocs
✓ **Orchestrator updates checklist** → Not agents
✓ **Only localhost:8888 network** → No external access
✓ **Agents manage tests** → Not server lifecycle

---

## Current Status

| Metric | Status |
|--------|--------|
| Features Extracted | 67/67 (100%) |
| Features Tested | 2/67 (3%) - ✓ method-argument, ✓ url-argument |
| Infrastructure | ✓ Production-ready |
| Scripts | ✓ All pre-approved |
| Documentation | ✓ Complete |

---

## Quick Commands

```bash
# Extract features
./scripts/extract-features.sh

# Test specific features headless
./scripts/run-feature-tests-headless.sh "json-flag,form-flag" 4

# Test all untested features
FEATURES=$(grep "Not Tested" checklist.md | awk -F'|' '{print $2}' | xargs)
./scripts/run-feature-tests-headless.sh "$FEATURES" 4

# Run full suite in Docker
docker-compose up --build

# View results
cat checklist.md
cat features/json-flag.md
ls issues/
```

---

## File Organization

```
httpie-delta/
├── QUICKSTART.md                 ← Start here (2 min)
├── ARCHITECTURE.md               ← How it works (10 min)
├── EXECUTION_SUMMARY.md          ← What was built
├── TESTING_INFRASTRUCTURE.md     ← Complete reference
├── HEADLESS_TESTING.md          ← Headless setup
├── README_TESTING.md            ← This file
│
├── scripts/                      ← Pre-approved scripts
│   ├── extract-features.sh
│   ├── start-httpbin.sh
│   ├── run-feature-tests-headless.sh
│   ├── orchestrate-tests.sh
│   ├── parse-help.py
│   └── README.md
│
├── .claude/                      ← Agent & command definitions
│   ├── commands/run-tests.md
│   ├── agents/checklist-curator.md
│   └── agents/feature-tester.md
│
├── docker-compose.yml            ← Docker services
├── Dockerfile.claude-agent       ← Testing image
├── Dockerfile.orchestrator       ← Orchestration image
├── test-batches.json            ← Batching config
│
├── checklist.md                 ← Feature tracking
├── features/                    ← Detailed results
│   ├── method-argument.md
│   ├── url-argument.md
│   └── ...
├── issues/                      ← Deviations logged
└── logs/                        ← Execution logs
```

---

## Reading Guide by Role

### 🚀 I want to start testing NOW
→ Read: [QUICKSTART.md](QUICKSTART.md) (2 min)
→ Run: `./scripts/run-feature-tests-headless.sh "json-flag" 1`

### 🏗️ I want to understand the architecture
→ Read: [ARCHITECTURE.md](ARCHITECTURE.md) (10 min)
→ Then: [TESTING_INFRASTRUCTURE.md](TESTING_INFRASTRUCTURE.md) (15 min)

### 🔧 I want to modify scripts or add features
→ Read: [scripts/README.md](scripts/README.md) (3 min)
→ Review: Relevant script file (shell or Python)

### 🐳 I want to run everything in Docker
→ Read: [HEADLESS_TESTING.md](HEADLESS_TESTING.md) (10 min)
→ Run: `docker-compose up --build`

### 📊 I want to review what was accomplished
→ Read: [EXECUTION_SUMMARY.md](EXECUTION_SUMMARY.md) (10 min)

---

## Troubleshooting Quick Links

### Issue: "claude: command not found"
→ See: HEADLESS_TESTING.md → Installation section

### Issue: "Cannot connect to Docker daemon"
→ See: HEADLESS_TESTING.md → Troubleshooting section

### Issue: Tests hanging or timeout
→ See: HEADLESS_TESTING.md → Troubleshooting section

### Issue: Want to understand orchestrator pattern
→ See: ARCHITECTURE.md → Orchestrator Pattern

### Issue: Need to add a new script
→ See: scripts/README.md → Script Development Guidelines

---

## Next Steps

1. **Quick Validation** (5 minutes)
   - Read QUICKSTART.md
   - Run: `./scripts/run-feature-tests-headless.sh "json-flag" 2`

2. **Small Batch Test** (15 minutes)
   - Run: `./scripts/run-feature-tests-headless.sh "json-flag,form-flag,auth-option" 4`
   - Review: `cat features/json-flag.md`

3. **Full Suite** (45 minutes)
   - Run: `docker-compose up --build`
   - Review: `cat checklist.md`

4. **Analysis**
   - Review: `cat checklist.md` (feature status)
   - Review: `issues/` (deviations found)
   - Generate report

---

## Document Updates

This documentation reflects the state of the infrastructure as of commit `0629c4b`.

For the latest version, see:
- `QUICKSTART.md` - Always up to date
- `ARCHITECTURE.md` - Design reference
- `scripts/README.md` - Script documentation

---

## Support

For issues or questions:
1. Check relevant documentation above
2. Review HEADLESS_TESTING.md → Troubleshooting
3. Check script logs in `logs/` directory
4. Review feature test results in `features/` directory

---

## License & Attribution

Infrastructure created using Claude Code and designed for the HTTPie project.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
