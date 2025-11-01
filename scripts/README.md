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
- Used by: Orchestrator in `/run-tests` command
- Output: Status messages and exit code
- Verifies connectivity before returning

## Script Development Guidelines

1. All scripts should be idempotent (safe to run multiple times)
2. Scripts should be focused and single-purpose
3. Add clear comments explaining what each script does
4. Always make scripts executable: `chmod +x script.sh`
5. Exit with appropriate codes (0 for success, non-zero for failure)
