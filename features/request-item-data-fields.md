# Feature: Request Items - Data Fields (=)

## Description
Data fields with `=` separator are used to specify form data or JSON fields in request bodies. The default behavior depends on the presence of the `--form` flag:
- **Without `--form`**: Data is sent as JSON (application/json)
- **With `--form`**: Data is sent as form-encoded data (application/x-www-form-urlencoded)

## Syntax
```
key=value    # Data field assignment
key=         # Empty value
```

## Test Results

### Status: FAILED

The implementations handle data fields differently:

### Test Cases

#### Test 1: Single data field (default behavior)
**Command:** `http POST http://localhost:8888/post name=John`

**Expected (http):** Sends as JSON with Content-Type: application/json
- Request body: `{"name": "John"}`
- Response data field: JSON object `{"name": "John"}`

**Actual (spie):** Sends as form-encoded with Content-Type: application/x-www-form-urlencoded
- Request body: `name=John` (form data)
- Response form field: `{"name": "John"}`

**Deviation:** ✗ INCOMPATIBLE - Default content type differs

#### Test 2: Multiple data fields
**Command:** `http POST http://localhost:8888/post name=John age=30`

**Expected (http):** JSON encoding
- Request body: `{"name": "John", "age": "30"}`
- All fields in JSON object

**Actual (spie):** Form encoding
- Request body: `name=John&age=30` (form data)
- All fields in form data

**Deviation:** ✗ INCOMPATIBLE - Content encoding differs

#### Test 3: Data field with quoted/spaced values
**Command:** `http POST http://localhost:8888/post message="Hello World"`

**Expected (http):** JSON encoding with proper string values
- Request body: `{"message": "Hello World"}`

**Actual (spie):** Form encoding
- Request body: `message=Hello+World` (URL-encoded)

**Deviation:** ✗ INCOMPATIBLE - Value encoding differs

#### Test 4: With explicit --form flag
**Command:** `http POST http://localhost:8888/post --form name=John`

**Expected:** Both should send form data
- http: Form encoding ✓
- spie: Form encoding (but may not support --form flag properly)

**Deviation:** ⚠ PARTIAL - spie may not fully support --form flag

#### Test 5: Empty data field
**Command:** `http POST http://localhost:8888/post empty=`

**Expected (http):** Empty string in JSON
- Request body: `{"empty": ""}`

**Actual (spie):** Empty string in form data
- Request body: `empty=`

**Deviation:** ✗ INCOMPATIBLE - Content type differs

## Summary

**Overall Assessment:** FAILED - Critical behavioral difference

### Key Issues
1. **Default content type mismatch**: http defaults to JSON, spie defaults to form encoding
2. **Missing --form flag support**: spie always uses form encoding for `=` fields regardless of flags
3. **No JSON mode for data fields**: spie cannot send data fields as JSON without explicit flag support

### Impact
- Applications expecting JSON request bodies will receive form-encoded data instead
- Cannot replicate http behavior for REST APIs that require JSON payloads
- Scripts that rely on default JSON encoding will fail when using spie

### Recommendations
1. Implement proper `--json` / `-j` flag support to control content type
2. Make JSON the default for data fields (to match http behavior)
3. Support `--form` / `-f` flag to explicitly select form encoding
4. Consider adding `--form` as default only when file uploads (@) are present

## Test Evidence
All tests were run against httpbin at http://localhost:8888
- HTTPie version: 3.2.4
- spie version: unknown (from /Users/bbloom/Projects/httpie-delta/bin/spie)
- Date: 2025-11-01
