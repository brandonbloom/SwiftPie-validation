# Issue: Raw Option (--raw) Partially Implemented But Broken

**Issue ID:** [#19](https://github.com/brandonbloom/SwiftPie/issues/19)
**Feature:** raw-option
**Severity:** High
**Status:** Open (Updated 2025-11-01)

## Status Update (2025-11-01)

**The `--raw` option is now recognized but critically broken.**

Previous state: Option was not recognized at all (treated as form field).
Current state: Option is recognized but wraps all data in `{"--raw": "data"}` JSON object.

This is progress (the option exists!) but the implementation is fundamentally broken.

## Problem

The `--raw` option is partially implemented in spie, but it wraps all raw data in a JSON object with `"--raw"` as the key, instead of sending the data as-is. This makes the feature completely non-functional.

## Core Bug

When using `--raw='data'`, spie sends:
```json
{"--raw": "data"}
```

Instead of:
```
data
```

**The option name becomes a JSON key**, and the raw data becomes its value. This breaks all use cases.

## Tested

**Feature:** raw-option
**Test Date:** 2025-11-01 (re-tested after implementation update)
**Environment:** httpbin at http://localhost:8888

### Command Examples

```bash
# Test 1: Raw JSON
http --ignore-stdin POST http://localhost:8888/post --raw='{"custom": "json", "number": 42}'
spie --ignore-stdin POST http://localhost:8888/post --raw='{"custom": "json", "number": 42}'

# Test 2: Raw plain text
http --ignore-stdin POST http://localhost:8888/post --raw='plain text data'
spie --ignore-stdin POST http://localhost:8888/post --raw='plain text data'

# Test 3: Raw from file
echo -n '{"test": "data"}' > /tmp/test-raw.json
http --ignore-stdin POST http://localhost:8888/post @/tmp/test-raw.json
spie --ignore-stdin POST http://localhost:8888/post --raw=@/tmp/test-raw.json

# Test 4: Raw from stdin
echo -n 'raw stdin data' | http POST http://localhost:8888/post
echo -n 'raw stdin data' | spie POST http://localhost:8888/post --raw=@-

# Test 5: Space syntax
http --ignore-stdin POST http://localhost:8888/post --raw 'test without equals'
spie --ignore-stdin POST http://localhost:8888/post --raw 'test without equals'
```

## Expected Behavior (http)

When using `--raw DATA`:
1. Option is recognized as a valid flag
2. Data is sent exactly as provided, without any processing
3. No field/header/data parsing occurs
4. Request body contains the exact raw data string
5. Content-Type defaults to `application/json` (can be overridden)

### Example: Raw JSON
```bash
$ http --ignore-stdin POST http://localhost:8888/post --raw='{"custom": "json", "number": 42}'
```

Server receives:
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
✅ Request body is exactly `{"custom": "json", "number": 42}` (32 bytes)

### Example: Raw plain text
```bash
$ http --ignore-stdin POST http://localhost:8888/post --raw='plain text data'
```

Server receives:
```json
{
  "data": "plain text data",
  "json": null,
  "headers": {
    "Content-Type": "application/json"
  }
}
```
✅ Request body is exactly `plain text data` (15 bytes)

### Example: Raw from file
```bash
$ http --ignore-stdin POST http://localhost:8888/post @/tmp/test-raw.json
```

Server receives:
```json
{
  "data": "{\"test\": \"data\"}",
  "json": {
    "test": "data"
  }
}
```
✅ Request body is file contents as-is

### Example: Raw from stdin
```bash
$ echo -n 'raw stdin data' | http POST http://localhost:8888/post
```

Server receives:
```json
{
  "data": "raw stdin data"
}
```
✅ Request body is stdin as-is

## Actual Behavior (spie)

### What Works
- ✅ `--raw` is now recognized (appears in help, doesn't error)
- ✅ `--raw=VALUE` syntax works (equals-separated)
- ✅ `--raw=@file` reads from files
- ✅ `--raw=@-` reads from stdin

### What's Broken
- ❌ **All data is wrapped in JSON object** `{"--raw": "value"}`
- ❌ Cannot send truly raw data
- ❌ `--raw VALUE` space syntax not supported (errors)
- ❌ Standalone `@file` syntax not supported
- ❌ Implicit stdin reading not supported

### Example: Raw JSON (BROKEN)
```bash
$ spie --ignore-stdin POST http://localhost:8888/post --raw='{"custom": "json", "number": 42}'
```

Server receives:
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
❌ Request body is `{"--raw":"{\"custom\": \"json\", \"number\": 42}"}` (50 bytes)
- Data is wrapped in JSON object
- Key is literally `"--raw"`
- Original JSON is double-escaped and becomes a string value
- Server sees wrong structure

### Example: Raw plain text (BROKEN)
```bash
$ spie --ignore-stdin POST http://localhost:8888/post --raw='plain text data'
```

Server receives:
```json
{
  "data": "{\"--raw\":\"plain text data\"}",
  "json": {
    "--raw": "plain text data"
  },
  "headers": {
    "Content-Type": "application/json",
    "Content-Length": "27"
  }
}
```
❌ Request body is `{"--raw":"plain text data"}` (27 bytes)
- Plain text is wrapped in JSON object
- Server receives JSON structure instead of raw text

### Example: Raw from file (BROKEN)
```bash
$ spie --ignore-stdin POST http://localhost:8888/post --raw=@/tmp/test-raw.json
```

Server receives:
```json
{
  "data": "{\"--raw\":\"{\\\"test\\\": \\\"data\\\"}\"}",
  "json": {
    "--raw": "{\"test\": \"data\"}"
  }
}
```
❌ File contents wrapped in `{"--raw": "..."}`

### Example: Space syntax (ERROR)
```bash
$ spie --ignore-stdin POST http://localhost:8888/post --raw 'test without equals'
error: invalid request item '--raw'
Exit code 64
```
❌ Space syntax not supported (only `--raw=VALUE` works)

## The Problem

### Critical Implementation Bug

**spie treats `--raw` as a request item field name** instead of a flag that provides raw data.

For `--raw='hello'`:
- **Expected:** Request body = `hello` (5 bytes, raw)
- **Actual:** Request body = `{"--raw":"hello"}` (18 bytes, JSON-encoded)

This suggests the implementation is routing `--raw` through the request items processing pipeline, where it gets treated as a JSON field with the option name as the key.

### Why This Breaks Everything

1. **Wrong data structure:** Server receives `{"--raw": "data"}` instead of `data`
2. **Double encoding:** JSON data becomes JSON-in-JSON: `{"--raw":"{\"key\":\"value\"}"}`
3. **Wrong size:** Body is larger than expected (wrapper overhead)
4. **Wrong semantics:** APIs expect raw data, not a JSON object with arbitrary key
5. **No API compatibility:** Any endpoint expecting raw data will reject the request

### Data Flow Analysis

The bug suggests this flow:
```
User input: --raw='data'
           ↓
spie parser: Recognizes --raw flag
           ↓
Bug: Treats --raw as request item field
           ↓
Creates: {"--raw": "data"}
           ↓
JSON encoder: Encodes the object
           ↓
Output: {"--raw":"data"}
```

Should be:
```
User input: --raw='data'
           ↓
spie parser: Recognizes --raw flag
           ↓
Bypass request items: Use data as-is
           ↓
Output: data
```

## Impact

### Cannot Send Raw Data
- **All data is wrapped in JSON object**
- No way to bypass the wrapping
- Makes `--raw` completely non-functional

### API Incompatibility
- APIs expecting raw JSON receive `{"--raw":"{...}"}`
- APIs expecting plain text receive `{"--raw":"text"}`
- APIs expecting XML receive `{"--raw":"<xml/>"}`
- All requests will fail or be rejected

### Script Breakage
- HTTPie scripts using `--raw` will send wrong data
- No workaround available
- Must use HTTPie instead (cannot use spie)

### Use Cases Broken

1. **Raw JSON:** `--raw='{"key":"value"}'` → sends `{"--raw":"{\"key\":\"value\"}"}`
2. **Plain text:** `--raw='text'` → sends `{"--raw":"text"}`
3. **XML payloads:** `--raw='<xml/>'` → sends `{"--raw":"<xml/>"}`
4. **Binary-like strings:** `--raw='binary'` → sends `{"--raw":"binary"}`
5. **Custom formats:** `--raw='custom'` → sends `{"--raw":"custom"}`

## Severity: High

This is a **critical functional bug** that:
- Makes the feature completely non-functional
- Breaks all scripts using `--raw`
- Prevents any API that requires raw data from working
- Cannot be worked around (no alternative approach)

## Recommendations

### 1. Fix Data Flow (Critical)

**Stop treating `--raw` as a request item:**
- When `--raw` is detected, bypass all request item processing
- Take the value directly and use it as the request body
- Do not wrap it in any structure
- Do not JSON-encode it (unless it's already JSON and Content-Type requires it)

### 2. Fix Syntax Support

**Support both equals and space syntax:**
- `--raw=VALUE` (currently works but broken)
- `--raw VALUE` (currently errors)

### 3. Add Missing Features

**Standalone `@file` syntax:**
- Support `@file` without `--raw` flag
- `http POST url @file.json` should work

**Implicit stdin:**
- When stdin is piped, read it as raw data
- `echo 'data' | spie POST url` should work

### 4. Content-Type Handling

**Respect Content-Type:**
- Default to `application/json` for raw data
- Allow override with `Content-Type:` header
- Do not JSON-encode when Content-Type is not JSON

### 5. Testing Strategy

**Test these cases:**
```bash
# Direct value
spie POST url --raw='data'
→ Body should be: data

# File input
spie POST url --raw=@file.txt
→ Body should be: <file contents>

# Stdin input
echo 'data' | spie POST url --raw=@-
→ Body should be: data

# JSON data
spie POST url --raw='{"key":"value"}'
→ Body should be: {"key":"value"}

# Plain text with explicit Content-Type
spie POST url Content-Type:text/plain --raw='text'
→ Body should be: text
→ Content-Type should be: text/plain
```

## Related Features

- feature: raw-option (--raw flag) - this issue
- feature: request-item-data-fields (= syntax, should be disabled with --raw)
- feature: request-item-headers (: syntax, headers should still work with --raw)
- feature: offline-flag (--offline, may want to print raw data preview)

## Progress Notes

**Before this update:**
- `--raw` not recognized at all
- Treated as form field name
- Sent as form-encoded data

**After this update:**
- ✅ `--raw` now recognized (appears in help)
- ✅ `--raw=VALUE`, `--raw=@file`, `--raw=@-` syntax works
- ❌ Data wrapped in `{"--raw": "..."}` JSON object
- ❌ Space syntax not supported
- ❌ Standalone `@file` not supported
- ❌ Implicit stdin not supported

**This is partial progress** but the core functionality is still broken.
