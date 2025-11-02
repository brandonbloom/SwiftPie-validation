# Pretty Option Feature Tests

**Feature Slug:** `pretty-option`
**HTTP Option:** `--pretty {all,colors,format,none}`
**Description:** Controls output processing (colors, formatting, both, or none)

## Feature Overview

The `--pretty` option controls how the response is formatted and colored when displayed to the terminal. It supports four values:

- `none`: No prettifying - output raw response exactly as received from server
- `colors`: Apply syntax coloring only (no additional formatting/indentation)
- `format`: Apply formatting/indentation only (no colors)
- `all`: Apply both colors and formatting (default for terminal)

This option is useful for:
- Disabling colors when piping output to files or other programs
- Controlling output formatting independent of colors
- Ensuring consistent output formatting across different environments

## Test Design

Test the `--pretty` option with all four values to verify:
1. Option is recognized and parsed correctly
2. Correct behavior for each value (none, colors, format, all)
3. Error handling for invalid values
4. Comparison of output between http and spie

### Test Environment
- **HTTPie Version:** 3.2.4
- **SpIE Version:** Swift-based implementation (with --pretty support added)
- **HTTPBin Server:** http://localhost:8888 (running locally)
- **Test Date:** 2025-11-01 (re-tested)

### Prerequisites
- Access to http and spie commands
- Access to local httpbin server on localhost:8888
- Ability to compare ANSI color codes and formatting

All commands can be executed without elevated privileges.

## Test Execution

### Test 1: HTTPie with --pretty=none

**Command:**
```bash
http --pretty=none --ignore-stdin http://localhost:8888/json
```

**Expected:** Raw response body with server's original formatting, no ANSI color codes

**Result:**
```
{
  "slideshow": {
    "author": "Yours Truly",
    "date": "date of publication",
    "slides": [
      {
        "title": "Wake up to WonderWidgets!",
        "type": "all"
      },
      {
        "items": [
          "Why <em>WonderWidgets</em> are great",
          "Who <em>buys</em> WonderWidgets"
        ],
        "title": "Overview",
        "type": "all"
      }
    ],
    "title": "Sample Slide Show"
  }
}
```

**Observations:**
- Shows only body (no headers)
- No ANSI color codes
- Preserves server's JSON formatting (2-space indentation)
- Exit code: 0

### Test 2: SpIE with --pretty=none

**Command:**
```bash
spie --pretty=none --ignore-stdin http://localhost:8888/json
```

**Expected:** Should behave like http --pretty=none

**Result:**
```
HTTP/1.1 200 No Error
Access-Control-Allow-Credentials: true
Access-Control-Allow-Origin: *
Content-Type: application/json
Connection: keep-alive
Date: Sun, 02 Nov 2025 05:12:10 GMT
Content-Length: 429
Server: gunicorn/19.9.0

{
  "slideshow": {
    "author": "Yours Truly",
    "date": "date of publication",
    "slides": [
      {
        "title": "Wake up to WonderWidgets!",
        "type": "all"
      },
      {
        "items": [
          "Why <em>WonderWidgets</em> are great",
          "Who <em>buys</em> WonderWidgets"
        ],
        "title": "Overview",
        "type": "all"
      }
    ],
    "title": "Sample Slide Show"
  }
}
```

**Observations:**
- Shows headers + body (different from http)
- No ANSI color codes
- Preserves server's JSON formatting
- Exit code: 0

**Deviation:** SpIE shows response headers while http shows only body

### Test 3: HTTPie with --pretty=all

**Command:**
```bash
http --pretty=all --ignore-stdin http://localhost:8888/json
```

**Expected:** Formatted and colored output (default terminal behavior)

**Result:**
```
{[37m[39;49;00m
[37m    [39;49;00m[94m"slideshow"[39;49;00m:[37m [39;49;00m{[37m[39;49;00m
[37m        [39;49;00m[94m"author"[39;49;00m:[37m [39;49;00m[33m"Yours Truly"[39;49;00m,[37m[39;49;00m
...
```

**Observations:**
- Shows only body
- ANSI color codes present ([37m, [94m, [33m, etc.)
- 4-space indentation
- Exit code: 0

### Test 4: SpIE with --pretty=all

**Command:**
```bash
spie --pretty=all --ignore-stdin http://localhost:8888/json
```

**Expected:** Should behave like http --pretty=all

**Result:**
```
[32mHTTP/1.1 200 No Error[0m
[35mDate[0m: [37mSun, 02 Nov 2025 05:12:15 GMT[0m
[35mServer[0m: [37mgunicorn/19.9.0[0m
...
[37m{
  "slideshow" : {
    "slides" : [
      {
        "title" : "Wake up to WonderWidgets!",
        "type" : "all"
      },
...
```

**Observations:**
- Shows headers + body (different from http)
- ANSI color codes present for both headers and body
- 2-space indentation (different from http's 4-space)
- Different JSON style: `"key" :` vs http's `"key":`
- Different key ordering
- Exit code: 0

**Deviations:**
1. Shows response headers while http shows only body
2. Uses 2-space indentation vs http's 4-space
3. Uses `"key" : value` style vs http's `"key": value`
4. Different key ordering in JSON output

### Test 5: HTTPie with --pretty=colors

**Command:**
```bash
http --pretty=colors --ignore-stdin http://localhost:8888/json
```

**Expected:** Server's original formatting with ANSI color codes applied

**Result:**
- Shows only body
- ANSI color codes present
- Preserves server's 2-space indentation (no reformatting)
- Exit code: 0

### Test 6: SpIE with --pretty=colors

**Command:**
```bash
spie --pretty=colors --ignore-stdin http://localhost:8888/json
```

**Expected:** Should behave like http --pretty=colors

**Result:**
- Shows headers + body
- ANSI color codes present
- Preserves server's 2-space indentation
- Exit code: 0

**Deviation:** Shows response headers while http shows only body

### Test 7: HTTPie with --pretty=format

**Command:**
```bash
http --pretty=format --ignore-stdin http://localhost:8888/json
```

**Expected:** Formatted output without colors

**Result:**
```
{
    "slideshow": {
        "author": "Yours Truly",
        "date": "date of publication",
        ...
```

**Observations:**
- Shows only body
- No ANSI color codes
- 4-space indentation (reformatted)
- Exit code: 0

### Test 8: SpIE with --pretty=format

**Command:**
```bash
spie --pretty=format --ignore-stdin http://localhost:8888/json
```

**Expected:** Should behave like http --pretty=format

**Result:**
```
HTTP/1.1 200 No Error
Content-Length: 429
...

{
  "slideshow" : {
    "slides" : [
...
```

**Observations:**
- Shows headers + body
- No ANSI color codes
- 2-space indentation
- Different JSON style: `"key" : value`
- Exit code: 0

**Deviations:**
1. Shows response headers while http shows only body
2. Uses 2-space indentation vs http's 4-space
3. Uses `"key" : value` style vs http's `"key": value`

### Test 9: Invalid Value Handling

**HTTPie Command:**
```bash
http --pretty=invalid --ignore-stdin http://localhost:8888/json
```

**HTTPie Result:**
```
usage:
    http --pretty {all, colors, format, none} [METHOD] URL [REQUEST_ITEM ...]

error:
    argument --pretty: invalid choice: 'invalid' (choose from all, colors,
format, none)
```
- Exit code: 1

**SpIE Command:**
```bash
spie --pretty=invalid --ignore-stdin http://localhost:8888/json
```

**SpIE Result:**
```
error: invalid value for --pretty: 'invalid'
```
- Exit code: 64

**Observations:**
- Both reject invalid values correctly
- Different error message formats
- Different exit codes (http: 1, spie: 64)

## Test Results

**Status: FAILED**

The `--pretty` option is now implemented in SpIE, but there are several behavioral deviations from HTTPie.

### Summary of Deviations

| Aspect | HTTPie | SpIE | Status |
|--------|--------|------|--------|
| Option Recognition | ✓ Recognized | ✓ Recognized | PASS |
| --pretty=none | ✓ Works | ✓ Works | PARTIAL |
| --pretty=colors | ✓ Works | ✓ Works | PARTIAL |
| --pretty=format | ✓ Works | ✓ Works | PARTIAL |
| --pretty=all | ✓ Works | ✓ Works | PARTIAL |
| Invalid Value Handling | ✓ Works | ✓ Works | PASS |
| Default Output (body only) | ✓ Shows body only | ✗ Shows headers+body | FAIL |
| JSON Indentation | 4 spaces | 2 spaces | FAIL |
| JSON Colon Style | `"key":` | `"key" :` | FAIL |
| JSON Key Ordering | Preserved | Different order | FAIL |

### Critical Deviations

1. **Output Parts Mismatch**: SpIE always shows headers+body, while http shows only body by default
   - This appears to be related to the `--print` option default behavior
   - HTTPie defaults to showing only body when output is to terminal
   - SpIE defaults to showing headers+body

2. **JSON Formatting Differences**:
   - **Indentation**: http uses 4 spaces, spie uses 2 spaces
   - **Colon spacing**: http uses `"key":` (no space), spie uses `"key" :` (space before colon)
   - **Key ordering**: Different ordering of JSON keys

3. **Exit Code Differences**: Invalid values produce different exit codes (http: 1, spie: 64)

### Impact Analysis

**Severity:** Medium-High

While the `--pretty` option is now implemented and functional in SpIE, the deviations affect:

1. **Output compatibility**: Scripts expecting http-style output will get different results
2. **Default behavior mismatch**: The headers+body vs body-only difference is significant
3. **JSON formatting**: Different indentation and style make output comparison difficult
4. **Script compatibility**: Different exit codes may affect error handling in scripts

### Root Causes

1. **Output Parts**: This is likely related to the missing/different implementation of the `--print` option (tracked separately as issue #13)
2. **JSON Formatting**: Different JSON serialization library or formatter being used
3. **Key Ordering**: Possible use of dictionaries/maps without order preservation

### Related Features

- `print-option` (#13): Controls which parts of request/response to show
- `format-options` (#15): Controls formatting details like indentation
- `sorted-flag` (#14): Controls JSON key sorting
- `unsorted-flag` (#10): Disables sorting in formatted output

## Notes

- The `--pretty` option is now implemented in SpIE (was missing in previous tests)
- The option correctly controls color and formatting behavior
- Major deviations exist in default output behavior and JSON formatting style
- These deviations make SpIE output incompatible with HTTPie for many use cases
- The headers+body vs body-only difference suggests the `--print` option has a different default
