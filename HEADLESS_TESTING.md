# Headless Testing Infrastructure

This document describes the headless testing setup for running HTTPie feature tests without interactive approval prompts.

## Overview

The headless testing infrastructure allows feature tests to run in parallel using Claude CLI in headless mode with automatic approval (`--permission-mode acceptEdits`). This eliminates the need for manual permission approvals.

## Components

### 1. Scripts

Located in `./scripts/`:

- **`run-feature-tests-headless.sh`** - Main orchestrator for running feature tests in headless mode
  - Takes comma-separated list of feature slugs
  - Spawns multiple claude CLI processes in parallel
  - Monitors test completion and aggregates results
  - Usage: `./scripts/run-feature-tests-headless.sh "json-flag,form-flag,auth-option" 4`

- **`orchestrate-tests.sh`** - Runs inside Docker orchestrator container
  - Reads test-batches.json configuration
  - Batches untested features appropriately
  - Updates checklist.md with results from feature files
  - Coordinates parallel test runs

### 2. Docker Infrastructure

#### docker-compose.yml
Defines three services:
- **httpbin**: Test server on port 8888
- **claude-agent**: Runs feature-tester agents in headless mode
- **orchestrator**: Coordinates test batches and updates results

#### Dockerfile.claude-agent
- Installs Claude CLI, HTTPie, and spie
- Provides entrypoint for headless feature testing
- Mounts workspace volume for reading/writing test results

#### Dockerfile.orchestrator
- Lightweight orchestration container
- Runs the orchestrate-tests.sh script
- Handles batch management and checklist updates

### 3. Configuration

#### test-batches.json
Defines feature batches for parallel execution:
- Organizes 67 features into 12 logical batches
- Specifies max parallelism per batch (typically 4)
- Includes timeout and retry policies
- Batch 11 (SSL/TLS) uses reduced parallelism due to certificate handling

## Usage

### Option 1: Direct headless mode (requires Claude CLI installed)

```bash
# Test a few features
./scripts/run-feature-tests-headless.sh "json-flag,form-flag,auth-option" 4

# Test all untested features
FEATURES=$(grep -E '^\|' checklist.md | grep 'Not Tested' | awk -F'|' '{print $2}' | xargs)
./scripts/run-feature-tests-headless.sh "$FEATURES" 4
```

### Option 2: Docker Compose (recommended for full isolation)

```bash
# Start all services (httpbin + orchestrator)
docker-compose up --build

# Or run specific service
docker-compose run --rm claude-agent "json-flag,form-flag" 4

# View logs
docker-compose logs -f orchestrator
```

### Option 3: Docker Compose with specific batch

```bash
# Set FEATURE_BATCH environment variable
FEATURE_BATCH="json-flag,form-flag,auth-option" docker-compose up --build
```

## Headless Mode Details

Claude CLI in headless mode is invoked with:

```bash
claude -p "prompt" \
    --allowedTools "Bash,Read,Write,Edit,Glob,Grep,SlashCommand" \
    --permission-mode acceptEdits \
    --append-system-prompt "HEADLESS_MODE=true"
```

Key parameters:
- `-p` / `--print`: Non-interactive mode
- `--allowedTools`: Restricts to safe tools for testing
- `--permission-mode acceptEdits`: Auto-approves file modifications
- `--append-system-prompt`: Provides context variables

## Test Results

All test results are captured in:

- **Feature files**: `features/{slug}.md` - Detailed test plan, results, and status
- **Issue files**: `issues/{issue-id}-{slug}.md` - Deviations between http and spie
- **Logs**: `logs/test-{slug}.log` - Execution logs for each feature
- **Checklist**: `checklist.md` - Summary of all feature statuses

## Example Run

```bash
# Start httpbin in background
docker run -p 8888:80 kennethreitz/httpbin &

# Test first batch
./scripts/run-feature-tests-headless.sh \
  "method-argument,url-argument,request-item-headers,request-item-url-params" 4

# Results appear in:
# - features/method-argument.md
# - features/url-argument.md
# - logs/test-method-argument.log
# - logs/test-url-argument.log
# - checklist.md (updated with status)
```

## Important Notes

1. **Claude CLI Required**: Headless mode requires Claude CLI to be installed and authenticated
   - Install: `pip install anthropic-claude-cli`
   - Authenticate: `claude auth login`

2. **API Key**: Docker containers need CLAUDE_API_KEY environment variable set
   - Set via: `export CLAUDE_API_KEY="your-key"` before running docker-compose

3. **Parallelism**: The optimal parallelism depends on:
   - Available CPU and memory
   - Claude API rate limits
   - Test complexity (SSL/TLS tests take longer)

4. **Timeouts**: Each feature test defaults to 5 minutes timeout
   - Can be configured per batch in test-batches.json

5. **Retry Logic**: Failed tests automatically retry once
   - Configure in test-batches.json `retry_policy`

## Troubleshooting

### Claude CLI not found
```bash
pip install anthropic-claude-cli
claude auth login
```

### Permission denied errors
```bash
chmod +x scripts/*.sh
```

### Docker image build fails
```bash
docker-compose down --volumes  # Clean slate
docker-compose up --build
```

### Tests hang or timeout
- Check httpbin is healthy: `curl http://localhost:8888/get`
- Reduce max_parallel in test-batches.json
- Increase timeout_seconds in retry_policy

## Future Enhancements

- [ ] Implement actual feature-tester agent integration in headless mode
- [ ] Add test result caching to avoid re-testing unchanged features
- [ ] Implement failure analysis and automatic issue creation
- [ ] Add test coverage metrics and reporting
- [ ] Create GitHub Actions workflow for CI/CD integration
