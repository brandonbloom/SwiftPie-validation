# Issue 25235: quiet-flag (--quiet/-q/-qq) not implemented

## Feature
quiet-flag: The `--quiet` (or `-q`, `-qq`) flag for suppressing stdout and stderr output

## Problem
spie does not support the `--quiet`, `-q`, or `-qq` flags. These flags are essential for silent operation, especially in scripting and automation.

## Tested
```bash
spie -q POST http://localhost:8888/post foo=bar --ignore-stdin
spie -qq POST http://localhost:8888/post foo=bar --ignore-stdin
spie --quiet POST http://localhost:8888/post foo=bar --ignore-stdin
```

## Expected
Commands should:
1. Execute the HTTP request successfully
2. Suppress stdout output (response body and headers)
3. Still show errors and critical messages
4. Exit with code 0 on success

For `-qq`: Even more aggressive suppression (suppress warnings too)

## Actual
All commands fail with:
```
error: unknown option '-q'
error: unknown option '-qq'
error: unknown option '--quiet'
```

Exit code: 64 (error)

## The Problem
The quiet flag is critical for scripting and automation:
- Allows silent HTTP requests without terminal output pollution
- Essential for server-side scripts and cron jobs
- Enables cleaner output in automated workflows
- Multiple levels (-q, -qq) provide fine-grained control

Without this feature, users cannot silently execute HTTP requests in scripts.

## Impact
High - Users cannot silence output for scripting and automation

## Notes
- http command properly supports all three forms: --quiet, -q, and -qq
- This is listed as feature "quiet-flag" in the checklist (line 40)
- This is a completely unimplemented feature in spie
- Essential for server automation and CI/CD pipelines
