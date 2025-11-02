# Issue: Raw Option (--raw) Not Implemented

**Issue ID:** [#19](https://github.com/brandonbloom/SwiftPie/issues/19)
**Feature:** raw-option
**Severity:** High
**Status:** Open

## Problem

The `--raw` option is not implemented in spie. This option allows passing raw request data without any HTTPie request item processing. Instead of parsing structured request items (field=value, field:value, etc.), the data after `--raw` is sent directly as the request body.

## Tested

**Feature:** raw-option
**Command examples:**
```bash
http --ignore-stdin POST http://localhost:8888/post --raw='{"custom": "json", "number": 42}'
http --ignore-stdin POST http://localhost:8888/post --raw='plain text data'
spie --ignore-stdin POST http://localhost:8888/post --raw='{"custom": "json", "number": 42}'
spie --ignore-stdin POST http://localhost:8888/post --raw='plain text data'
```

**Test Date:** 2025-11-01
**Environment:** httpbin at http://localhost:8888

## Expected Behavior (http)

When using `--raw DATA`:
1. Option is recognized as a valid flag
2. Data is sent exactly as provided, without request item parsing
3. No field/header/data parsing occurs
4. Content-Type is typically set to `application/json` (default)
5. Request body contains the exact raw data string

Example 1 - Raw JSON:
```bash
http --ignore-stdin POST http://localhost:8888/post --raw='{"custom": "json", "number": 42}'
```
Result:
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

Example 2 - Raw plain text:
```bash
http --ignore-stdin POST http://localhost:8888/post --raw='plain text data'
```
Result:
```json
{
  "data": "plain text data",
  "json": null,
  "headers": {
    "Content-Type": "application/json"
  }
}
```

## Actual Behavior (spie)

When using `--raw DATA`:
1. Option is not recognized as a flag
2. Treated as a regular request item argument
3. Parsed as a form field with name `--raw` and the data as the value
4. Sent as form-encoded request body
5. Content-Type is `application/x-www-form-urlencoded`

Example 1 - Raw JSON attempt:
```bash
spie --ignore-stdin POST http://localhost:8888/post --raw='{"custom": "json", "number": 42}'
```
Result:
```json
{
  "form": {
    "--raw": "{\"custom\": \"json\", \"number\": 42}"
  },
  "headers": {
    "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
  }
}
```
- `--raw` treated as field name
- Data treated as field value
- Entire structure is wrong

Example 2 - Raw plain text attempt:
```bash
spie --ignore-stdin POST http://localhost:8888/post --raw='plain text data'
```
Result:
```json
{
  "form": {
    "--raw": "plain text data"
  },
  "headers": {
    "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
  }
}
```
- Same issue: treated as form field, not raw data
- Data completely misaligned with intent

## The Problem

**Missing feature:**
- `--raw` option is not implemented in spie
- No recognition of the flag in CLI parsing
- Argument is treated as a form field instead

**Content type mismatch:**
- spie defaults to form encoding, not JSON
- Raw data is meant to be sent as-is, not form-encoded

**Request structure completely different:**
- Expected: Raw bytes in request body
- Actual: Form-encoded field with `--raw` as name

## Impact

- Cannot send raw request bodies with spie at all
- Cannot send arbitrary binary data
- Cannot send non-structured payloads (plain text, XML, custom formats)
- Incompatible with HTTPie scripts using `--raw`
- APIs expecting raw JSON or other formats receive malformed form-encoded requests instead
- No workaround available (no other way to bypass request item parsing)

## Use Cases Broken

1. **Raw JSON:** `http --raw='{"key":"value"}'` → spie fails
2. **Plain text:** `http --raw='plain text'` → spie fails
3. **XML payloads:** `http --raw='<data>...</data>'` → spie fails
4. **Custom formats:** `http --raw='custom data'` → spie fails
5. **Binary-like strings:** `http --raw='binary\x00data'` → spie fails

## Recommendations

1. **Implement the `--raw` option:**
   - Add `--raw` or `-r` as a recognized CLI flag
   - Parse the argument value as the request body
   - Skip all request item parsing when `--raw` is used

2. **Content-Type handling:**
   - Default to `application/json` for raw data
   - Allow override with `--content-type` if available
   - Do not default to form encoding

3. **Data flow:**
   - Raw data should go directly to request body
   - No field/header/data parsing
   - No multipart encoding

4. **Validation:**
   - Ensure `--raw` and request items are mutually exclusive
   - Error if both structured items and `--raw` are provided
   - Document this limitation clearly

## Related Features

- feature: raw-option (--raw flag)
- feature: request-item-data-fields (= syntax, should be disabled with --raw)
- feature: request-item-headers (: syntax, should be disabled with --raw)
- feature: offline-flag (--offline, may want to print raw data preview)
