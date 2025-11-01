# Sorted Flag Feature Tests

**Feature Slug:** `sorted-flag`
**HTTP Option:** `--sorted`
**Description:** Re-enable all sorting options while formatting output (shortcut for `--format-options=headers.sort:true,json.sort_keys:true`)

## Feature Overview

The `--sorted` flag re-enables sorting of headers and JSON keys in the formatted output. This is useful when:
- A previous request used `--unsorted` and you want to revert to sorted output
- You want to explicitly ensure consistent, alphabetically sorted output
- You need to override unsorted behavior set in configuration files

The `--sorted` flag is a shortcut for:
```
--format-options=headers.sort:true,json.sort_keys:true
```

This flag can be used to counteract the `--unsorted` flag or to ensure output sorting is enabled.

## Test Results

**Status: FAILED** ✗

### Test Environment
- **HTTPie Version:** 3.2.4
- **SpIE Version:** Swift-based implementation
- **HTTPBin Server:** http://localhost:8888 (running)
- **Test Date:** 2025-11-01

### Tests Performed

#### Test 1: HTTPie with --sorted flag
- **Command:** `http --sorted --ignore-stdin http://localhost:8888/json`
- **Expected:** Response with headers sorted alphabetically
- **Result:** ✓ PASS
- **Details:** HTTPie outputs headers in sorted order (Access-Control-Allow-Credentials, Access-Control-Allow-Origin, Connection, Content-Length, Content-Type, Date, Server)

#### Test 2: HTTPie with --unsorted flag then --sorted
- **Command:** `http --unsorted --sorted --ignore-stdin http://localhost:8888/json`
- **Expected:** --sorted should override --unsorted, resulting in sorted output
- **Result:** ✓ PASS
- **Details:** HTTPie correctly interprets the last flag, showing sorted headers

#### Test 3: SpIE with --sorted flag
- **Command:** `/Users/bbloom/Projects/httpie-delta/bin/spie --sorted --ignore-stdin http://localhost:8888/json`
- **Expected:** SpIE should support --sorted flag (or fail gracefully if not supported)
- **Result:** ✗ FAIL
- **Details:** SpIE does not recognize the `--sorted` flag. Error: `error: unknown option '--sorted'`

#### Test 4: Header Sorting Behavior - HTTPie
- **Command:** `http --print=h --sorted --ignore-stdin http://localhost:8888/json`
- **Result:** Headers are sorted alphabetically:
  ```
  Access-Control-Allow-Credentials
  Access-Control-Allow-Origin
  Connection
  Content-Length
  Content-Type
  Date
  Server
  ```

#### Test 5: Header Sorting Behavior - SpIE
- **Result:** Not tested - SpIE does not support the flag

### Deviation Summary

**SpIE does NOT support the `--sorted` flag.**

| Aspect | HTTPie | SpIE |
|--------|--------|------|
| Flag Support | ✓ Implemented | ✗ Not Implemented |
| Header Sorting | ✓ Works (alphabetical) | N/A |
| JSON Key Sorting | ✓ Works (alphabetical) | N/A |
| Flag Override | ✓ Works (--unsorted + --sorted = sorted) | N/A |

### Impact Analysis

- **Severity:** High
- **Category:** Feature Gap
- **User Impact:** Users cannot explicitly enable sorted output in SpIE. This is particularly problematic when:
  - Using configuration files or scripts that disable sorting
  - Wanting consistent, reproducible output format
  - Comparing HTTPie and SpIE output programmatically

### Related Features
- `unsorted-flag`: The complementary flag that disables sorting

### Notes
- The `--sorted` flag works as expected in HTTPie
- SpIE lacks the flag entirely (no sorting control options available)
- Unlike HTTPie, SpIE appears to have no sorting/formatting options whatsoever
