# HTTPie Feature Test: --format-options

## Feature Description
The `--format-options` option controls fine-grained formatting behavior for the output. It allows customization of specific formatting aspects like header sorting, JSON indentation, and other output style details.

## Specification (from `http --help`)
```
--format-options=OPTION=VALUE
      Comma-separated list of options to control output formatting:

      Available options:
      - headers.sort=true/false (sort response headers alphabetically)
      - json.indent=N (JSON indentation level, default 2)
      - json.ensure_ascii=true/false (escape non-ASCII characters in JSON)

      Example: --format-options=headers.sort:false,json.indent:4
```

## Test Cases

### Test 1: Control JSON indentation
**Scenario**: Use --format-options to set JSON indentation to 4 spaces

**HTTP Command**:
```bash
http --format-options=json.indent:4 GET http://localhost:8888/json
```

**Expected Behavior (http baseline)**:
- JSON output should be indented with 4 spaces per level (vs default 2 spaces)

**SPIE Command**:
```bash
spie --format-options=json.indent:4 GET http://localhost:8888/json
```

### Test 2: Disable header sorting
**Scenario**: Use --format-options to disable automatic header sorting

**HTTP Command**:
```bash
http --format-options=headers.sort:false --print=h GET http://localhost:8888/get
```

**Expected Behavior (http baseline)**:
- Response headers should appear in server-provided order, not alphabetically sorted

**SPIE Command**:
```bash
spie --format-options=headers.sort:false --print=h GET http://localhost:8888/get
```

### Test 3: Verify flag is recognized
**Scenario**: Check if spie recognizes the --format-options flag in help

**HTTP Command**:
```bash
http --help | grep -i format-options
```

**SPIE Command**:
```bash
spie --help | grep -i format-options
```

## Test Results

### Test Execution

#### Test 1: http with --format-options=json.indent:4
Command: `http --format-options=json.indent:4 GET http://localhost:8888/json`

Status: http accepts the flag and processes it ✓

Output shows 4-space indentation:
```json
{
    "slideshow": {
        "author": "Yours Truly",
        "date": "date of publication",
        "slides": [
            ...
        ],
        "title": "Sample Slide Show"
    }
}
```

#### Test 2: spie with --format-options=json.indent:4
Command: `spie --format-options=json.indent:4 GET http://localhost:8888/json`

Output:
```
error: unknown option '--format-options=json.indent:4'
```

Status: spie does not recognize the flag ✗

#### Test 3: http help check
```bash
http --help | grep -i format-options
```
Result: Shows `--format-options=OPTION=VALUE` in help text ✓

#### Test 4: spie help check
```bash
spie --help | grep -i format-options
```
Result: No output (flag not found in help) ✗

### Comparison Table

| Aspect | http | spie | Match |
|--------|------|------|-------|
| Flag recognized | ✓ Yes | ✗ No | ✗ FAILED |
| json.indent option | ✓ Yes | ✗ No | ✗ FAILED |
| headers.sort option | ✓ Yes | ✗ No | ✗ FAILED |
| Formatting control | ✓ Yes | ✗ No | ✗ FAILED |
| Functional parity | ✓ Full | ✗ Not implemented | ✗ FAILED |

## Deviations Found

### Critical Issue: --format-options flag not implemented in spie
- **Severity**: FAILURE
- **Type**: Missing feature
- **Impact**: Users cannot customize output formatting (JSON indentation, header sorting, etc.)
- **spie Behavior**: Rejects `--format-options` flag with error: `error: unknown option '--format-options=json.indent:4'`
- **http Behavior**: Accepts `--format-options` flag with multiple format control options and correctly applies the formatting

### Root Cause
The `--format-options` option is completely absent from spie's command-line interface. While spie may have default formatting, there is no way to customize format options like HTTPie does.

## Test Environment
- **HTTPie Version**: 3.2.4
- **spie Location**: /Users/bbloom/Projects/SwiftPie-validation/bin/spie
- **Test Server**: httpbin (localhost:8888)
- **Test Date**: 2025-11-01
- **OS**: macOS (Darwin 25.0.0)

## Summary
The `--format-options` option is **NOT IMPLEMENTED** in spie. This is a missing feature that prevents users from customizing output formatting. HTTPie allows control over JSON indentation, header sorting, and other format details, but spie has no equivalent capability.

**Status**: FAILED
