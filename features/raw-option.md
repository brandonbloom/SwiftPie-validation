# Feature: Raw Option (--raw)

## Description
The `--raw` option allows passing raw request data without extra processing. Instead of using the structured request items syntax (key=value, key:value, etc.), you can provide raw data directly as the request body. This is useful for sending arbitrary data that doesn't fit the standard field/header structure.

## Syntax
```
--raw DATA
  Pass raw request data without extra processing

  http --raw='{"custom": "json"}' POST pie.dev/post
  http --raw='plain text data' POST pie.dev/post
  http pie.dev/post @data.txt  (read raw from file)
  echo 'data' | http pie.dev/post  (read raw from stdin)
```

## Test Plan

### Test Design
We will test the `--raw` option with:
1. **JSON raw data** - Raw JSON string passed as request body
2. **Plain text raw data** - Raw text passed as request body
3. **Content-Type handling** - How the content type is determined
4. **File input** - Loading raw data from a file
5. **Stdin input** - Loading raw data from stdin

### Test Setup
- HTTP server: httpbin at http://localhost:8888
- Raw data strings: JSON and plain text
- Test file: /tmp/test-raw.json

## Test Results

### Status: FAILED

**Update (2025-11-01):** The `--raw` option now appears in `spie --help`, indicating partial implementation. However, the implementation is broken - spie wraps the raw data in a JSON object with `--raw` as a key instead of sending it as-is.

### Test Case 1: Raw JSON Data (Direct Value)

**Command:**
```bash
http --ignore-stdin POST http://localhost:8888/post --raw='{"custom": "json", "number": 42}'
spie --ignore-stdin POST http://localhost:8888/post --raw='{"custom": "json", "number": 42}'
```

**Expected (http):**
- Request body: `{"custom": "json", "number": 42}` (exactly as provided)
- Content-Type: `application/json` (auto-detected from content)
- Response data field: `"{\"custom\": \"json\", \"number\": 42}"`
- Response json field: `{"custom": "json", "number": 42}`

**Actual (http):**
```json
{
  "data": "{\"custom\": \"json\", \"number\": 42}",
  "json": {
    "custom": "json",
    "number": 42
  },
  "headers": {
    "Content-Type": "application/json"
  }
}
```
✅ **PASS** - http correctly sends raw JSON data

**Actual (spie):**
```json
{
  "data": "{\"--raw\":\"{\\\"custom\\\": \\\"json\\\", \\\"number\\\": 42}\"}",
  "json": {
    "--raw": "{\"custom\": \"json\", \"number\": 42}"
  },
  "headers": {
    "Content-Type": "application/json",
    "Content-Length": "50"
  }
}
```
❌ **FAIL** - spie:
- Wraps the raw data in a JSON object: `{"--raw": "{\"custom\": \"json\", \"number\": 42}"}`
- The intended raw data becomes a JSON value under the key `--raw`
- Sends JSON encoding of the wrapper object, not the raw data itself
- Double-escapes the JSON: the server receives `{"--raw":"..."}` instead of `{"custom":"json","number":42}`

**Deviation:** ✗ INCORRECT IMPLEMENTATION
- Option is recognized (progress from previous version!)
- But data is wrapped in JSON object instead of sent as-is
- Request body structure completely wrong

### Test Case 2: Raw Plain Text Data

**Command:**
```bash
http --ignore-stdin POST http://localhost:8888/post --raw='plain text data'
spie --ignore-stdin POST http://localhost:8888/post --raw='plain text data'
```

**Expected (http):**
- Request body: `plain text data` (exactly as provided)
- Content-Type: `application/json` (default)
- Response data field: `"plain text data"`

**Actual (http):**
```json
{
  "data": "plain text data",
  "json": null,
  "headers": {
    "Content-Type": "application/json"
  }
}
```
✅ **PASS** - http correctly sends raw text data

**Actual (spie):**
```json
{
  "data": "{\"--raw\":\"plain text data\"}",
  "json": {
    "--raw": "plain text data"
  },
  "headers": {
    "Content-Type": "application/json"
  }
}
```
❌ **FAIL** - spie:
- Wraps plain text in JSON object: `{"--raw": "plain text data"}`
- Server receives JSON structure instead of plain text
- Data is JSON-encoded instead of raw

**Deviation:** ✗ INCORRECT IMPLEMENTATION

### Test Case 3: Raw Data with Explicit Content-Type

**Command:**
```bash
http --ignore-stdin POST http://localhost:8888/post Content-Type:text/plain --raw='plain text'
spie --ignore-stdin POST http://localhost:8888/post Content-Type:text/plain --raw='plain text'
```

**Expected (http):**
- Request body: `plain text`
- Content-Type: `text/plain` (as specified)

**Actual (http):**
```json
{
  "data": "plain text",
  "headers": {
    "Content-Type": "text/plain"
  }
}
```
✅ **PASS** - http respects explicit Content-Type and sends raw text

**Actual (spie):**
```json
{
  "data": "{\"--raw\":\"plain text\"}",
  "json": {
    "--raw": "plain text"
  },
  "headers": {
    "Content-Type": "text/plain"
  }
}
```
❌ **FAIL** - spie:
- Respects the Content-Type header (good!)
- But still wraps data in JSON object `{"--raw": "plain text"}`
- Sends JSON-encoded structure despite text/plain Content-Type
- Content-Type header doesn't match actual content format

**Deviation:** ✗ INCORRECT IMPLEMENTATION

### Test Case 4: Raw Data from File

**Command:**
```bash
# Create test file
echo -n '{"test": "data"}' > /tmp/test-raw.json

# HTTPie syntax: standalone @ loads file as raw
http --ignore-stdin POST http://localhost:8888/post @/tmp/test-raw.json

# spie syntax: --raw=@file according to help
spie --ignore-stdin POST http://localhost:8888/post --raw=@/tmp/test-raw.json
```

**Expected (http with @file):**
- Request body: `{"test": "data"}` (file contents)
- Content-Type: `application/json`

**Actual (http with @file):**
```json
{
  "data": "{\"test\": \"data\"}",
  "json": {
    "test": "data"
  },
  "headers": {
    "Content-Type": "application/json"
  }
}
```
✅ **PASS** - http loads file and sends raw contents

**Actual (spie with --raw=@file):**
```json
{
  "data": "{\"--raw\":\"{\\\"test\\\": \\\"data\\\"}\"}",
  "json": {
    "--raw": "{\"test\": \"data\"}"
  },
  "headers": {
    "Content-Type": "application/json"
  }
}
```
❌ **FAIL** - spie:
- Does read the file (progress!)
- But wraps file contents in JSON object: `{"--raw": "{\"test\": \"data\"}"}`
- Same wrapping issue as with direct values

**Note:** spie does NOT support the standalone `@file` syntax (without --raw):
```bash
spie POST http://localhost:8888/post @/tmp/test-raw.json
# Error: invalid file reference '@/tmp/test-raw.json'
```

**Deviation:** ✗ INCORRECT IMPLEMENTATION + MISSING FEATURE (@file syntax)

### Test Case 5: Raw Data from Stdin

**Command:**
```bash
# HTTPie: implicit stdin when piped
echo -n 'raw stdin data' | http POST http://localhost:8888/post

# spie: requires --raw=@- according to help
echo -n 'raw stdin data' | spie POST http://localhost:8888/post --raw=@-
```

**Expected (http with stdin):**
- Request body: `raw stdin data`
- Content-Type: `application/json`

**Actual (http with stdin):**
```json
{
  "data": "raw stdin data",
  "headers": {
    "Content-Type": "application/json"
  }
}
```
✅ **PASS** - http reads stdin and sends raw data

**Actual (spie with --raw=@-):**
```json
{
  "data": "{\"--raw\":\"raw stdin data\"}",
  "json": {
    "--raw": "raw stdin data"
  },
  "headers": {
    "Content-Type": "application/json"
  }
}
```
❌ **FAIL** - spie:
- Does read from stdin with `--raw=@-` (progress!)
- But wraps stdin data in JSON object: `{"--raw": "raw stdin data"}`
- Same wrapping issue

**Note:** spie does NOT support implicit stdin reading:
```bash
echo -n 'data' | spie POST http://localhost:8888/post
# Sends empty body (Content-Length: 0)
```

**Deviation:** ✗ INCORRECT IMPLEMENTATION + MISSING FEATURE (implicit stdin)

### Test Case 6: Space Syntax (--raw VALUE)

**Command:**
```bash
http --ignore-stdin POST http://localhost:8888/post --raw 'test without equals'
spie --ignore-stdin POST http://localhost:8888/post --raw 'test without equals'
```

**Expected (http):**
- Works the same as `--raw='value'`

**Actual (http):**
```json
{
  "data": "test without equals",
  "headers": {
    "Content-Type": "application/json"
  }
}
```
✅ **PASS** - http accepts both `--raw VALUE` and `--raw=VALUE`

**Actual (spie):**
```
Exit code 64
error: invalid request item '--raw'
```
❌ **FAIL** - spie:
- Does NOT support `--raw VALUE` syntax (space-separated)
- Only supports `--raw=VALUE` syntax (equals-separated)
- Error suggests it's still treating `--raw` as a request item in some parsing path

**Deviation:** ✗ MISSING FEATURE (space syntax)

## Summary

**Overall Assessment:** FAILED - The `--raw` option is partially implemented but broken

### Implementation Status

**Partial implementation detected:**
- ✅ `--raw` appears in `spie --help`
- ✅ `--raw=VALUE` syntax is recognized (doesn't error)
- ✅ `--raw=@file` reads from files
- ✅ `--raw=@-` reads from stdin
- ❌ **Critical bug:** All raw data is wrapped in `{"--raw": "data"}` JSON object
- ❌ Missing: `--raw VALUE` space syntax (only equals syntax works)
- ❌ Missing: Standalone `@file` syntax
- ❌ Missing: Implicit stdin reading (piped data)

### The Core Problem

**spie treats --raw as a JSON field instead of raw data:**

For `--raw='hello'`:
- **Expected:** Request body = `hello` (5 bytes)
- **Actual:** Request body = `{"--raw":"hello"}` (18 bytes, JSON-encoded)

This makes the feature completely non-functional because:
1. The raw data is not sent as-is
2. It's wrapped in a JSON structure
3. The key is literally `--raw` (the flag name!)
4. This breaks all use cases for raw data

### Key Differences

1. **Data wrapping**:
   - http: Sends raw data exactly as provided
   - spie: Wraps data in JSON object `{"--raw": "data"}`

2. **Request body**:
   - http: Raw bytes (text, JSON, binary, etc.)
   - spie: JSON-encoded object containing the raw data

3. **Syntax support**:
   - http: `--raw=VALUE`, `--raw VALUE`, `@file`, stdin
   - spie: Only `--raw=VALUE`, `--raw=@file`, `--raw=@-`

4. **Content-Type handling**:
   - http: Defaults to `application/json`, can be overridden
   - spie: Same, but actual content doesn't match (JSON wrapper vs raw)

## Impact

- **Cannot send raw data with spie** - All data is wrapped in JSON
- **Breaks all APIs expecting raw payloads** - Server receives wrong structure
- **Scripts using --raw will fail** - Completely different request body
- **No workaround available** - The wrapping happens regardless of Content-Type
- **Double-encoding issues** - Raw JSON becomes JSON-in-JSON: `{"--raw":"{...}"}`

### Broken Use Cases

1. **Raw JSON:** `http --raw='{"key":"value"}'` → spie sends `{"--raw":"{\"key\":\"value\"}"}`
2. **Plain text:** `http --raw='text'` → spie sends `{"--raw":"text"}`
3. **XML:** `http --raw='<xml/>'` → spie sends `{"--raw":"<xml/>"}`
4. **Binary data:** `http --raw='binary'` → spie sends `{"--raw":"binary"}`

## Blockers

None - the feature can be tested. The implementation exists but is broken.

## Notes

- **Major progress:** Option is now recognized (wasn't before)
- **Major bug:** Core functionality is broken due to JSON wrapping
- **Suggests implementation error:** The `--raw` flag is being treated as a request item field name
- **Needs complete reimplementation:** The data path needs to bypass JSON encoding entirely

## Test Evidence

### Environment
- HTTPie implementation: HTTPie 3.2.4
- spie implementation: /Users/bbloom/Projects/httpie-delta/bin/spie (version unknown)
- Test date: 2025-11-01
- Server: httpbin at http://localhost:8888

### Raw Command Outputs

**Test 1 - Raw JSON value (spie):**
```bash
$ spie --ignore-stdin POST http://localhost:8888/post --raw='{"custom": "json", "number": 42}'
```
Server received:
```json
{
  "data": "{\"--raw\":\"{\\\"custom\\\": \\\"json\\\", \\\"number\\\": 42}\"}",
  "json": {
    "--raw": "{\"custom\": \"json\", \"number\": 42}"
  }
}
```

**Test 2 - Raw plain text (spie):**
```bash
$ spie --ignore-stdin POST http://localhost:8888/post --raw='plain text data'
```
Server received:
```json
{
  "data": "{\"--raw\":\"plain text data\"}",
  "json": {
    "--raw": "plain text data"
  }
}
```

**Test 3 - Raw from file (spie):**
```bash
$ echo -n '{"test": "data"}' > /tmp/test-raw.json
$ spie --ignore-stdin POST http://localhost:8888/post --raw=@/tmp/test-raw.json
```
Server received:
```json
{
  "data": "{\"--raw\":\"{\\\"test\\\": \\\"data\\\"}\"}",
  "json": {
    "--raw": "{\"test\": \"data\"}"
  }
}
```

## Status

**FAILED** - The `--raw` option is recognized but broken. spie wraps all raw data in a JSON object `{"--raw": "data"}` instead of sending it as-is. This makes the feature completely non-functional. See issue #19 (to be updated with new findings).
