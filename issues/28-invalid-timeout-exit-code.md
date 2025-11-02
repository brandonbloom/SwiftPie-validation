# Issue: Invalid timeout value uses exit code 64 instead of 1

**Issue ID:** #28
**Feature Slug:** timeout-option
**Status:** Open

## Summary

When an invalid timeout value is provided (like -1), SpIE exits with code 64 while HTTPie exits with code 1. This inconsistency in error handling breaks compatibility with scripts that expect standard Unix exit codes.

## Tested

**Command tested:**
```bash
spie --timeout -1 GET http://localhost:8888/get
```

## Expected

HTTPie exits with code 1 for invalid timeout values:
```bash
http --timeout -1 GET http://localhost:8888/get
```

Result:
```
http: error: ValueError: Attempted to set connect timeout to -1.0, but the timeout cannot be set to a value less than or equal to 0.
Exit code: 1
```

## Actual

SpIE exits with code 64:
```
error: invalid timeout value '-1'
Exit code: 64
```

## The Problem

Exit code 64 is conventionally used for "command line usage error" (from BSD sysexits.h), which is technically correct but inconsistent with HTTPie. The issue is:

1. HTTPie uses exit code 1 for argument validation errors
2. SpIE uses exit code 64 for the same errors
3. Scripts expecting HTTPie's exit codes will misbehave

While exit code 64 is more semantically correct (it is a usage error), compatibility with HTTPie is more important for a drop-in replacement.

## Impact

**Severity:** Medium

This affects error handling in scripts:
- Generic error checking (`if [ $? -ne 0 ]`) still works
- Specific exit code checks (`if [ $? -eq 1 ]`) will fail
- Scripts that distinguish between error types may malfunction

The impact is less severe than issue #26 (timeout exit code) because:
- Invalid arguments typically fail fast during development/testing
- Most scripts use generic "non-zero = error" checks
- The error happens before any network request

However, it's still an incompatibility that should be fixed.

## Root Cause

SpIE uses a different error code convention than HTTPie for argument validation errors. This may be due to:
- Using a different CLI parsing library
- Following BSD sysexits conventions
- Not explicitly matching HTTPie's exit code behavior

## Recommendation

Update SpIE to use exit code 1 for invalid argument values, matching HTTPie:
1. Invalid timeout values should exit with code 1
2. Other argument validation errors should also use code 1
3. Reserve exit code 64 only if HTTPie also uses it

This improves compatibility while still being a reasonable exit code. If desired, SpIE could document specific exit codes in its own help text, but they should match HTTPie's actual behavior.

## Note

Exit code 64 is more "correct" by Unix conventions (EX_USAGE), but HTTPie compatibility is the priority. Consider documenting all exit codes to help users understand the difference between error types.
