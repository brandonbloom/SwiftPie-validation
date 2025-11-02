# Feature: Raw Option (--raw)

## Description
The `--raw` option allows passing raw request data without extra processing. Instead of using the structured request items syntax (key=value, key:value, etc.), you can provide raw data directly as the request body. This is useful for sending arbitrary data that doesn't fit the standard field/header structure.

## Syntax
```
--raw DATA
  Pass raw request data without extra processing

  http --raw='{"custom": "json"}' POST pie.dev/post
  http --raw='plain text data' POST pie.dev/post
```

## Test Plan

### Test Design
We will test the `--raw` option with:
1. **JSON raw data** - Raw JSON string passed as request body
2. **Plain text raw data** - Raw text passed as request body
3. **Content-Type handling** - How the content type is determined
4. **Comparison** - What happens without --raw (structured request items)

### Test Setup
- HTTP server: httpbin at http://localhost:8888
- Raw data strings: JSON and plain text

## Test Results

### Status: FAILED

The implementations handle the `--raw` option completely differently:
- **http**: Properly recognizes `--raw` and sends the data as-is as the request body
- **spie**: Does not recognize `--raw` as a flag; treats it as a regular form field argument instead

### Test Case 1: Raw JSON Data

**Command:**
```bash
http --ignore-stdin POST http://localhost:8888/post --raw='{"custom": "json", "number": 42}'
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
  "data": "",
  "form": {
    "--raw": "{\"custom\": \"json\", \"number\": 42}"
  },
  "headers": {
    "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
  },
  "json": null
}
```
❌ **FAIL** - spie:
- Treats `--raw` as a form field name, not as a flag
- The argument value becomes the field value: `"--raw": "{\"custom\": \"json\", \"number\": 42}"`
- Request body is form-encoded instead of raw
- Does not recognize the option at all

**Deviation:** ✗ INCOMPATIBLE
- Option not recognized; treated as form field instead
- Content type mismatch (JSON vs form-encoded)
- Request body structure completely different

### Test Case 2: Raw Plain Text Data

**Command:**
```bash
http --ignore-stdin POST http://localhost:8888/post --raw='plain text data'
```

**Expected (http):**
- Request body: `plain text data` (exactly as provided)
- Content-Type: `application/json` (default when not JSON-like)
- Response data field: `"plain text data"`
- Response json field: `null` (not valid JSON)

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
  "data": "",
  "form": {
    "--raw": "plain text data"
  },
  "headers": {
    "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
  },
  "json": null
}
```
❌ **FAIL** - spie:
- Again treats `--raw` as a form field name
- The text becomes a form field value
- Request body is form-encoded, not raw
- Option not recognized

**Deviation:** ✗ INCOMPATIBLE
- Option not recognized; treated as form field instead
- Content type mismatch (JSON vs form-encoded)
- Request body structure completely different

## Summary

**Overall Assessment:** FAILED - The `--raw` option is not implemented in spie

### Key Differences

1. **Option recognition**:
   - http: Recognizes `--raw` as a valid option flag
   - spie: Does not recognize `--raw`; treats it as a form field argument

2. **Request body handling**:
   - http: Sends the data exactly as provided after `--raw`
   - spie: Treats `--raw=value` as a form field, including `--raw` as the field name

3. **Content-Type determination**:
   - http: Sets appropriate Content-Type (usually `application/json`)
   - spie: Sets `application/x-www-form-urlencoded` for form fields

4. **Data flow**:
   - http: `--raw` value → request body (raw)
   - spie: `--raw` argument → form field with name `--raw`

## Impact

- Cannot send raw data with spie at all
- Any scripts using `--raw` will fail or send incorrect requests
- Cannot send arbitrary binary data or non-structured payloads
- Form-encoding default prevents sending raw JSON or text
- API clients relying on `--raw` will not work with spie

## Blockers

None - the feature can be tested, but it's not implemented in spie.

## Notes

- This is a critical feature for flexibility in request body handling
- The feature is useful for APIs that don't fit the standard field/header structure
- spie's lack of option parsing for `--raw` suggests incomplete CLI option support
- spie's default form-encoding behavior is problematic for raw data use cases

## Test Evidence

### Environment
- HTTP implementation: HTTPie 3.2.4
- spie implementation: /Users/bbloom/Projects/httpie-delta/bin/spie (version unknown)
- Date: 2025-11-01
- Server: httpbin at http://localhost:8888

### Raw Response Data

**Test 1 - Raw JSON (http):**
```json
{
  "args": {},
  "data": "{\"custom\": \"json\", \"number\": 42}",
  "files": {},
  "form": {},
  "headers": {
    "Content-Type": "application/json",
    "Content-Length": "32"
  },
  "json": {
    "custom": "json",
    "number": 42
  }
}
```

**Test 1 - Raw JSON (spie):**
```json
{
  "args": {},
  "data": "",
  "files": {},
  "form": {
    "--raw": "{\"custom\": \"json\", \"number\": 42}"
  },
  "headers": {
    "Content-Type": "application/x-www-form-urlencoded; charset=utf-8",
    "Content-Length": "60"
  },
  "json": null
}
```

## Status

**FAILED** - The `--raw` option is not implemented in spie. The option is not recognized as a CLI flag and is instead treated as a form field argument. See issue #25242.
