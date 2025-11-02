# Unsorted Flag Feature Tests

**Feature Slug:** `unsorted-flag`
**HTTP Option:** `--unsorted`
**Description:** Disables all sorting in formatted output (headers and JSON keys)

## Feature Overview

The `--unsorted` flag disables sorting of headers and JSON keys in the formatted output. This is useful when:
- You want to preserve the original order of response headers and JSON keys
- You need to see the natural order in which the server sends data
- You want to override sorting behavior set in configuration files

The `--unsorted` flag is a shortcut for:
```
--format-options=headers.sort:false,json.sort_keys:false
```

## Test Design

Test the `--unsorted` flag to verify:
1. Parsing of the flag
2. Correct behavior in disabling sorting
3. Preserved original order of headers and JSON keys

### Test Environment
- **HTTPie Version:** 3.2.4
- **SpIE Version:** Swift-based implementation
- **HTTPBin Server:** http://localhost:8888 (running)
- **Test Date:** 2025-11-01

### Test Cases

#### Test 1: HTTPie with --unsorted flag
- **Command:** `http --unsorted --ignore-stdin http://localhost:8888/json`
- **Expected:** Response with headers and JSON keys in original (unsorted) order
- **Result:** ✓ PASS
- **Output:** JSON displayed with keys in their original order from the server response, headers not alphabetically sorted

#### Test 2: SpIE with --unsorted flag
- **Command:** `/Users/bbloom/Projects/SwiftPie-validation/bin/spie --unsorted --ignore-stdin http://localhost:8888/json`
- **Expected:** SpIE should support --unsorted flag (or fail gracefully if not supported)
- **Result:** ✗ FAIL
- **Error:** `error: unknown option '--unsorted'`

## Test Results

**Status: FAILED**

### Deviation Summary

**SpIE does NOT support the `--unsorted` flag.**

| Aspect | HTTPie | SpIE |
|--------|--------|------|
| Flag Support | ✓ Implemented | ✗ Not Implemented |
| Header Sorting Control | ✓ Works | ✗ Not available |
| JSON Key Sorting Control | ✓ Works | ✗ Not available |
| Order Preservation | ✓ Works (with flag) | N/A |

### Impact Analysis

- **Severity:** Medium
- **Category:** Feature Gap
- **User Impact:** Users cannot control header or JSON key sorting in SpIE. This is particularly problematic when:
  - Needing to preserve the original order of response headers
  - Debugging responses where order matters
  - Using HTTPie in scripts that rely on consistent ordering

### Related Features
- `sorted-flag`: The complementary flag that re-enables sorting
- `pretty-option`: Related output control feature

### Notes
- The `--unsorted` flag works as expected in HTTPie
- SpIE lacks the flag entirely (no sorting control options available)
- Unlike HTTPie, SpIE appears to have no sorting/formatting options whatsoever
