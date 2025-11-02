# Issue: Timeout error uses exit code 1 instead of 2

**Issue ID:** #26
**Feature Slug:** timeout-option
**Status:** Open

## Summary

When a request times out, SpIE exits with code 1 while HTTPie exits with code 2. This breaks compatibility for scripts that check exit codes to distinguish timeout errors from other failures.

## Tested

**Command tested:**
```bash
spie --timeout 1 GET http://localhost:8888/delay/3
```

## Expected

HTTPie exits with code 2 on timeout:
```bash
http --timeout 1 GET http://localhost:8888/delay/3
```

Result:
```
http: error: Request timed out (1.0s).
Exit code: 2
```

## Actual

SpIE exits with code 1 on timeout:
```
transport error: request timed out after 1s
Exit code: 1
```

## The Problem

Exit codes are part of the CLI contract and are used by scripts to determine what went wrong:
- Exit code 0: Success
- Exit code 1: Generic error
- Exit code 2: Timeout error (in HTTPie)
- Other codes: Specific error types

By using exit code 1 for timeouts, SpIE makes it impossible for scripts to distinguish timeout errors from other generic failures. This is critical for retry logic and error handling.

## Impact

**Severity:** High

This affects automation and scripting:
- Scripts checking for timeout-specific errors will fail
- Retry logic that treats timeouts differently won't work
- Error handling code that depends on exit codes will malfunction

Example broken script:
```bash
http --timeout 5 "$URL" || {
  if [ $? -eq 2 ]; then
    echo "Timeout - retrying with longer timeout..."
    http --timeout 30 "$URL"
  fi
}
```

This pattern won't work with SpIE because timeouts don't produce exit code 2.

## Root Cause

SpIE uses a generic error exit code (1) for all request failures including timeouts. HTTPie distinguishes timeout errors with exit code 2.

## Recommendation

Update SpIE to exit with code 2 when a request times out, matching HTTPie's behavior. This requires:
1. Detecting timeout errors specifically (not just generic network errors)
2. Returning exit code 2 for timeout errors
3. Keeping exit code 1 for other errors

This maintains compatibility with existing HTTPie scripts and automation.
