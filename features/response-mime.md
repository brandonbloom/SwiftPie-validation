# HTTPie Feature Test: --response-mime

## Feature Description
The `--response-mime` option overrides the response MIME type for output formatting and coloring purposes. This allows HTTPie to format output according to a specified MIME type even if the server sends a different Content-Type header.

## Specification (from `http --help`)
```
--response-mime=MIME_TYPE
      Override response MIME type for formatting (defaults to auto-detection
      from Content-Type header). Useful when the server provides incorrect
      MIME type headers or when you want to force a specific format for display.
```

## Test Cases

### Test 1: Override HTML as JSON
**Scenario**: Server returns HTML but override with application/json to get JSON formatting

**HTTP Command**:
```bash
http --response-mime=application/json --print=b http://localhost:8888/html
```

**Expected Behavior (http baseline)**:
- Response body should be formatted as JSON (with colors and indentation if --pretty is enabled)
- HTML content will be attempted to parse/display with JSON formatting

**SPIE Command**:
```bash
spie --response-mime=application/json --print=b http://localhost:8888/html
```

**Expected Behavior (spie)**:
- Should produce identical output to http when --response-mime is used

### Test 2: Verify flag is recognized
**Scenario**: Check if spie recognizes the --response-mime flag

**HTTP Command**:
```bash
http --help | grep -i response-mime
```

**SPIE Command**:
```bash
spie --help | grep -i response-mime
```

## Test Results

### Test Execution

#### Test 1a: http with --response-mime=application/json
Command: `http --response-mime=application/json --print=b http://localhost:8888/html`

Output:
```
<html>
  <body>
    <h1>Herman Melville - Moby-Dick</h1>
    ...
  </body>
</html>
```

#### Test 1b: spie with --response-mime=application/json
Command: `spie --response-mime=application/json --print=b http://localhost:8888/html`

Output:
```
error: unknown option '--response-mime'
```

#### Test 2a: http help check
```bash
http --help | grep -i response-mime
```
Result: Shows `--response-mime=MIME_TYPE` in help text

#### Test 2b: spie help check
```bash
spie --help | grep -i response-mime
```
Result: No output (flag not found in help)

### Comparison Table

| Aspect | http | spie | Match |
|--------|------|------|-------|
| Flag recognized | ✓ Yes | ✗ No | ✗ FAILED |
| Can override MIME type | ✓ Yes | ✗ No | ✗ FAILED |
| Formats as specified type | ✓ Yes | N/A | ✗ FAILED |
| Functional parity | ✓ Full | ✗ Not implemented | ✗ FAILED |

## Deviations Found

### Critical Issue: --response-mime flag not implemented in spie
- **Severity**: FAILURE
- **Type**: Missing feature
- **Impact**: Users cannot override response MIME type for formatting and coloring
- **spie Behavior**: Rejects `--response-mime` flag with error: `error: unknown option '--response-mime'`
- **http Behavior**: Accepts `--response-mime` flag and applies the specified MIME type for output formatting

### Root Cause
The `--response-mime` option is completely absent from spie's command-line interface.

## Test Environment
- **HTTPie Version**: 3.2.4
- **spie Location**: /Users/bbloom/Projects/SwiftPie-validation/bin/spie
- **Test Server**: httpbin (localhost:8888)
- **Test Date**: 2025-11-01
- **OS**: macOS (Darwin 25.0.0)

## Summary
The `--response-mime` option is **NOT IMPLEMENTED** in spie. This feature is missing from both the CLI interface and the underlying implementation, preventing users from overriding response MIME types for formatting purposes.

**Status**: FAILED
