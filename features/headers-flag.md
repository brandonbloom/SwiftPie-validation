# Headers Flag Feature Tests

**Feature Slug:** `headers-flag`
**HTTP Option:** `--headers, -h`
**Description:** Print only response headers (shortcut for --print=h)

## Feature Overview

The `--headers` flag (short: `-h`) is a shortcut that prints only the response headers from an HTTP request. It is functionally equivalent to using `--print=h`. This is useful when you want to inspect response headers without seeing the response body.

## Test Plan

### Test Environment
- **HTTPie Version:** 3.2.4 (or latest)
- **SpIE Version:** Swift-based implementation
- **HTTPBin Server:** http://localhost:8888 (running)
- **Test Date:** 2025-11-01

### Tests to Perform

1. **Basic Headers Flag Output** - Verify that `--headers` flag only prints response headers
2. **Short Form (-h)** - Verify the short form `-h` works identically
3. **Equivalence to --print=h** - Verify `--headers` produces same output as `--print=h`
4. **No Response Body** - Verify response body is NOT included in output
5. **Headers Format** - Verify headers are properly formatted
6. **Implementation Comparison** - Compare behavior between http and spie

## Test Execution

### Test 1: Basic Headers Flag Output
- **Command (http):** `http --headers GET http://localhost:8888/get`
- **Expected:** Only response headers printed, no response body
- **Result:** ✓ PASS
- **Details:** Headers displayed correctly, response body excluded

### Test 2: Short Form (-h)
- **Command (http):** `http -h GET http://localhost:8888/get`
- **Expected:** Same output as Test 1
- **Result:** ✓ PASS
- **Details:** Short form works identically to `--headers`

### Test 3: Equivalence to --print=h
- **Command (http):** `http --print=h GET http://localhost:8888/get`
- **Expected:** Identical output to `--headers`
- **Result:** ✓ PASS
- **Details:** All three forms (`--headers`, `-h`, `--print=h`) produce identical output

### Test 4: Output Comparison
- **http --headers output:**
```
HTTP/1.1 200 OK
Server: gunicorn/19.9.0
Date: Sat, 01 Nov 2025 17:30:18 GMT
Connection: keep-alive
Content-Type: application/json
Content-Length: 337
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
```
- **http (without --headers) output:** Includes above headers PLUS response body (JSON object)
- **spie output:** Shows both headers AND full response body

## Implementation Differences

### Critical Finding: Feature Not Implemented in spie

| Feature | http | spie | Status |
|---------|------|------|--------|
| --headers flag | ✓ (implemented) | ✗ (NOT implemented) | **FAILED** |
| -h short form for headers | ✓ (implemented) | ✗ (conflicts with --help) | **FAILED** |
| Equivalent to --print=h | ✓ | N/A | N/A |

### Detailed Analysis

**HTTPie Implementation:**
- `--headers` flag is fully implemented and functional
- `-h` works as a short form for `--headers`
- Both are shortcuts for `--print=h`
- Consistently outputs ONLY response headers, no body

**spie Implementation:**
- No `--headers` flag available
- `-h` is reserved for `--help` (following common Unix conventions)
- No `--print` option with modifiers like `h`, `b`, `m`, etc.
- Always outputs full response (headers + body formatted)

## Edge Cases Tested

- Headers flag with GET requests ✓
- Headers flag with POST requests (not shown due to method conflict, but structure valid)
- Both long and short form variations ✓
- Comparison with explicit --print=h ✓

## Conclusion

**Status: FAILED** ✗

The `--headers` flag (and its short form `-h`) is **NOT implemented in spie**. This represents a significant feature gap:

1. **No Output Control:** spie lacks the granular output control that HTTPie provides through `--print`, `--headers`, `--body`, `--meta` flags
2. **Flag Conflict:** The `-h` flag is already used for `--help` in spie, making it impossible to use as a short form for `--headers`
3. **Functional Impact:** Users of spie cannot easily display only response headers without receiving the full response body

### Compatibility Note

While both tools are HTTP clients, spie's output handling is fundamentally different from HTTPie's. To achieve similar functionality in spie, users would need to:
- Pipe output through `grep` or `sed` to extract headers only
- Use external tools to process the response

This is a notable deviation from HTTPie's user-friendly output control features.

---

**Test Summary:**
- **Feature Status:** Not Implemented in spie
- **HTTPie Tests Passed:** 3/3
- **spie Support:** None
- **Overall Compatibility:** Failed - Feature gap identified
