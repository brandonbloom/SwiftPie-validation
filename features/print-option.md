# HTTPie Feature Test: --print Option

## Feature Description
The `--print` option (short form `-p`) specifies which parts of the HTTP request and response to display in the output. This allows fine-grained control over what information is shown.

## Specification (from `http --help`)
```
--print=WHAT, -p WHAT
      String specifying what the output should contain:
      - 'H' = request headers
      - 'B' = request body
      - 'h' = response headers
      - 'b' = response body
      - 'm' = response metadata (status line, etc.)

      The default is 'HhBb' (all parts). You can combine characters
      to get different combinations (e.g., 'h' for response headers only,
      'Hh' for request and response headers).
```

## Test Cases

### Test 1: Print only response body (--print=b)
**Scenario**: Show only the response body, no headers

**HTTP Command**:
```bash
http --print=b GET http://localhost:8888/json
```

**Expected Behavior (http baseline)**:
- Output should contain ONLY the response body (JSON in this case)
- NO request headers, response headers, or status line

**SPIE Command**:
```bash
spie --print=b GET http://localhost:8888/json
```

### Test 2: Print request and response headers (--print=Hh)
**Scenario**: Show both request and response headers, no bodies

**HTTP Command**:
```bash
http --print=Hh GET http://localhost:8888/json
```

**Expected Behavior (http baseline)**:
- Output should contain request headers and response headers
- NO request body or response body

**SPIE Command**:
```bash
spie --print=Hh GET http://localhost:8888/json
```

### Test 3: Print only request headers (--print=H)
**Scenario**: Show only request headers

**HTTP Command**:
```bash
http --print=H GET http://localhost:8888/json
```

**Expected Behavior (http baseline)**:
- Output should contain only request headers
- NO response headers, bodies, or metadata

**SPIE Command**:
```bash
spie --print=H GET http://localhost:8888/json
```

## Test Results

### Test Execution

#### Test 1: --print=b (response body only)
**http Output**:
```json
{
  "slideshow": {
    "author": "Yours Truly",
    "date": "date of publication",
    "slides": [
      {
        "title": "Wake up to WonderWidgets!",
        "type": "all"
      },
      ...
    ],
    "title": "Sample Slide Show"
  }
}
```

Status: http shows response body only ✓

**spie Output**:
```
error: unknown option '--print=b'
```

Status: spie does not recognize the flag ✗

#### Test 2: Verify flag is available in http help
**http help output**:
```
--print=WHAT, -p WHAT
      String specifying what the output should contain:
      'H' = request headers
      'B' = request body
      'h' = response headers
      'b' = response body
      'm' = response metadata
```

Status: Flag documented in http help ✓

**spie help output**:
No mention of --print option in spie help. Help text shows:
```
Help
  -h, --help                        Show this help message and exit.
```

Status: Flag not in spie help ✗

### Comparison Table

| Aspect | http | spie | Match |
|--------|------|------|-------|
| --print flag recognized | ✓ Yes | ✗ No | ✗ FAILED |
| -p short form recognized | ✓ Yes | ✗ No | ✗ FAILED |
| Output filtering capability | ✓ Yes | ✗ No | ✗ FAILED |
| Functional parity | ✓ Full | ✗ Not implemented | ✗ FAILED |

## Test Environment
- **HTTPie Version**: 3.2.4
- **spie Location**: /Users/bbloom/Projects/SwiftPie-validation/bin/spie
- **Test Server**: httpbin (localhost:8888)
- **Test Date**: 2025-11-01
- **OS**: macOS (Darwin 25.0.0)

## Deviations Found

### Critical Issue: --print flag not implemented in spie
- **Severity**: FAILURE
- **Type**: Missing feature
- **Impact**: Users cannot selectively display request/response parts (headers only, body only, etc.)
- **spie Behavior**: Rejects `--print` flag with error: `error: unknown option '--print=b'`
- **http Behavior**: Accepts `--print` flag with various filters (H, B, h, b, m) and correctly outputs only the requested parts

### Root Cause
The `--print` option (and its short form `-p`) is completely absent from spie's command-line interface. While spie may always output all parts by default, there is no way to filter the output like HTTPie does.

## Summary
The `--print` option is **NOT IMPLEMENTED** in spie. This is a critical missing feature that prevents users from controlling what parts of the HTTP request/response are displayed. HTTPie allows fine-grained control (headers only, body only, metadata, etc.), but spie has no equivalent capability.

**Status**: FAILED
