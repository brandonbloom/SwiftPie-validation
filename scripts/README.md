# Reusable Scripts for HTTPie Testing Workflow

This directory contains pre-approved, reusable scripts that are used by agents and commands in the testing workflow.

## Important Notes

- **Never run httpbin via Python** - Always use Docker: `docker run -p 8888:80 kennethreitz/httpbin`
- All scripts in this directory are pre-approved and can be used without seeking approval on subsequent runs
- Scripts should be self-contained and idempotent where possible

## Available Scripts

### extract-features.sh
Extracts all HTTPie features from `http --help` output.
- Used by: `checklist-curator` agent
- Output: Full help text to stdout
- No arguments required

### parse-help.py
Parses HTTPie help text and converts to structured JSON format.
- Used by: `checklist-curator` agent
- Input: Help text via stdin
- Output: JSON objects (one per line) with keys: name, flag, description, section, slug
- Usage: `./extract-features.sh | ./parse-help.py`

### start-httpbin.sh
Starts httpbin server using Docker on port 8888.
- **Used by**: Orchestrator in `/run-tests` command
- **Output**: Status messages and exit code
- **Verifies**: Connectivity before returning

### run-feature-tests-headless.sh
Orchestrates headless feature testing with Claude CLI.
- **Used by**: Direct invocation for batch testing
- **Output**: Color-coded results + logs in logs/ directory
- **Arguments**:
  - `$1`: Comma-separated feature slugs (required)
  - `$2`: Max parallel jobs (default: 4)
- **Example**: `./run-feature-tests-headless.sh "json-flag,form-flag" 4`

### orchestrate-tests.sh
Manages feature test batches and result aggregation.
- **Used by**: Docker orchestrator service
- **Output**: Batch results and checklist updates
- **Environment**: `WORK_DIR`, `FEATURE_BATCH` (optional)

## Script Development Guidelines

1. **Idempotency**: All scripts should be safe to run multiple times
2. **Single Purpose**: Each script has one clear responsibility
3. **Documentation**: Add comments explaining what each script does
4. **Executable**: Always run `chmod +x script.sh` after creating
5. **Exit Codes**: Use 0 for success, non-zero for failure
6. **No Ad-hoc Code**: Never create scripts via heredoc
7. **File-based**: Store permanently in ./scripts/ for reuse

## Script Approval & Reuse

✓ **All scripts in this directory are pre-approved**
- Can be run directly without seeking additional approval
- Designed for reuse across multiple test runs
- Changes to scripts require only local editing
