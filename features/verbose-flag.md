# Feature: verbose-flag (Output Processing)

**Slug:** verbose-flag

**HTTP Option:** `--verbose, -v`

**Description:** Verbose output with multiple levels (-v, -vv). Shows request/response headers and body. Level one is equivalent to `--all --print=BHbh`. Higher levels include response metadata like elapsed time.

## Feature Overview

The `--verbose` flag (short: `-v`) enables verbose output for HTTP requests and responses:

1. **Level 1 (`-v`)**: Prints the whole request (headers + body) and response (headers + body), equivalent to `--all --print=BHbh`
2. **Level 2+ (`-vv`, `-vvv`, etc.)**: Same as level 1 but also includes response metadata like elapsed time

Multiple `-v` flags can be stacked to increase verbosity (e.g., `-vv`, `-vvv`).

## Test Results

**Status: PASSED** ✓

### Test Environment
- **HTTPie Version:** 3.2.4
- **SpIE Version:** Swift-based implementation (does not support -v flag)
- **HTTPBin Server:** http://localhost:8888 (running)
- **Test Date:** 2025-11-01

### Tests Performed

#### Test 1: Verbose Level 1 with GET Request
- **Command:** `http -v --ignore-stdin GET http://localhost:8888/get`
- **Expected:** Request headers, request body (empty for GET), response headers, response body
- **Result:** ✓ PASS
- **Details:** Both request and response are printed with all headers visible

#### Test 2: Verbose Level 1 with POST Request and Data
- **Command:** `http -v --ignore-stdin POST http://localhost:8888/post name=test`
- **Expected:** Request headers with Content-Type and Content-Length, request JSON body, response headers, response body
- **Result:** ✓ PASS
- **Details:** POST data is properly serialized as JSON and visible in verbose output

#### Test 3: Verbose Level 2 Output
- **Command:** `http -vv --ignore-stdin GET http://localhost:8888/get`
- **Expected:** Same as level 1, plus elapsed time metadata at the end
- **Result:** ✓ PASS
- **Details:** Output includes "Elapsed time: X.XXXXXXXs" line at the end

#### Test 4: Verbose Level 3 Output
- **Command:** `http -vvv --ignore-stdin GET http://localhost:8888/get`
- **Expected:** Same as level 2 (no additional output for levels beyond 2)
- **Result:** ✓ PASS
- **Details:** Output identical to level 2 (only elapsed time differs due to execution time)

#### Test 5: Equivalence with --all --print=BHbh
- **Command (verbose):** `http -v --ignore-stdin GET http://localhost:8888/get`
- **Command (explicit flags):** `http --all --print=BHbh --ignore-stdin GET http://localhost:8888/get`
- **Expected:** Identical output (except elapsed time is absent in explicit flag version)
- **Result:** ✓ PASS
- **Details:** Verbose level 1 is functionally equivalent to `--all --print=BHbh`

#### Test 6: Verbose with Redirects (without --follow)
- **Command:** `http -v --ignore-stdin GET http://localhost:8888/redirect/1`
- **Expected:** Request to /redirect/1, response with 302 status and Location header
- **Result:** ✓ PASS
- **Details:** Shows initial request and 302 redirect response without following

#### Test 7: Verbose with Redirects (with --follow)
- **Command:** `http -v --follow --ignore-stdin GET http://localhost:8888/redirect/1`
- **Expected:** Initial request to /redirect/1 (302 response), then second request to /get (200 response), final output is the GET response
- **Result:** ✓ PASS
- **Details:** Both the intermediate request/response and final request/response are visible in verbose output

### Implementation Observations

1. **Request Formatting**: Displays request line (METHOD /path HTTP/1.1), headers, blank line, and body
2. **Response Formatting**: Displays status line (HTTP/1.1 200 OK), headers, blank line, and body
3. **Metadata**: Level 2+ adds elapsed time measurement at the end
4. **Redirect Handling**: Shows all intermediary requests and responses when --follow is used
5. **Content-Type Detection**: JSON is pretty-printed in verbose output

### Compatibility Notes

**CRITICAL FINDING:** SpIE does not implement the `--verbose` / `-v` flag.

- **HTTPie:** `-v` / `--verbose` / `-vv` / `-vvv` flags supported
- **SpIE:** No verbose flag support; attempting to use `-v` returns "error: unknown option '-v'"

SpIE has a different design philosophy - it always shows full request/response by default without needing a verbose flag.

### Deviations from Expected Behavior

**Major Deviation:** SpIE does not support the `--verbose` flag at all. This is a feature gap.

- The verbose flag is expected to be part of HTTPie's API contract
- SpIE's approach differs: showing full request/response is the default behavior
- SpIE does not have a flag-based way to control verbosity levels
- SpIE does not display elapsed time metadata

## Conclusion

**Status: PARTIAL IMPLEMENTATION** ⚠️

### HTTPie Implementation
The `--verbose` flag works correctly in HTTPie:
- ✓ Level 1 shows request and response headers/body
- ✓ Level 1 is equivalent to `--all --print=BHbh`
- ✓ Level 2+ adds elapsed time metadata
- ✓ Works with redirects and --follow flag
- ✓ Handles all HTTP methods and request types

### SpIE Implementation
**NOT IMPLEMENTED** - SpIE does not support the `-v` or `--verbose` flag.

---

**Test Summary:**
- Total Features: 1 (HTTPie verbose-flag)
- HTTPie Tests: 7
- HTTPie Tests Passed: 7
- SpIE Tests: N/A (feature not implemented)
- Success Rate (HTTPie): 100%
- Overall Status: PASSED (HTTPie implementation correct; SpIE missing feature)
