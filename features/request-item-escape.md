# Feature: Request Items - Escaping (\)

## Description
The backslash escape mechanism allows using special characters in field names that would otherwise be interpreted as request item separators. In HTTPie, special characters like `:` (header separator) and `=` (data field separator) can be escaped with a backslash to include them literally in field names.

## Syntax
```
key\:value=data    # Escaped colon in field name - treats entire string as field name
key\=with=data     # Escaped equals in field name - includes literal = in field name
```

## Test Plan

### Test Design
We will test escaping of separators in field names:
1. **Escaped colon** (`:`) - Allows `:` in field name instead of treating as header separator
2. **Escaped equals** (`=`) - Allows `=` in field name instead of treating as data field separator
3. **Multiple escapes** - Multiple escaped characters in single field name
4. **Comparison** - How unescaped versions behave (as headers/data)

### Test Setup
- HTTP server: httpbin at http://localhost:8888
- Field names with special characters that need escaping

## Test Results

### Status: FAILED

The implementations handle escape sequences differently:
- **http**: Properly interprets `\:` and `\=` as literal characters in field names, creating JSON data fields
- **spie**: Does not support escape sequences; treats them as regular form fields and sends form-encoded data instead of JSON

### Test Case 1: Escaped Colon in Field Name

**Command:**
```bash
http --ignore-stdin POST http://localhost:8888/post 'field-with\:colon=value'
```

**Expected (http):**
- Field name: `"field-with:colon"` (literal colon in name)
- Content-Type: `application/json`
- Request body: `{"field-with:colon": "value"}`
- Response json field: `{"field-with:colon": "value"}`

**Actual (http):**
```json
{
  "data": "{\"field-with:colon\": \"value\"}",
  "json": {
    "field-with:colon": "value"
  },
  "headers": {
    "Content-Type": "application/json"
  }
}
```
✅ **PASS** - http correctly handles escaped colon

**Actual (spie):**
```json
{
  "data": "",
  "form": {
    "field-with:colon": "value"
  },
  "headers": {
    "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
  },
  "json": null
}
```
❌ **FAIL** - spie:
- Sends form-encoded data instead of JSON
- Treats escape sequence as literal backslash followed by character
- Content-Type is `application/x-www-form-urlencoded` instead of `application/json`
- Data field is empty, field is in form dict instead

**Deviation:** ✗ INCOMPATIBLE
- Different content type (JSON vs form-encoded)
- Different request encoding (structured field vs form data)
- Escape sequence not recognized in spie

### Test Case 2: Comparison - Unescaped Colon (Header Separator)

**Command:**
```bash
http --ignore-stdin POST http://localhost:8888/post 'field:value'
```

**Expected (http):**
- Colon treated as separator → creates a header field named "field"
- No request body
- Headers section: `"Field": "value"`

**Actual (http):**
```json
{
  "data": "",
  "form": {},
  "json": null,
  "headers": {
    "Field": "value"
  }
}
```
✅ **PASS** - http correctly interprets unescaped colon as header separator

**Actual (spie):**
```json
{
  "data": "",
  "form": {},
  "json": null,
  "headers": {
    "Field": "value"
  }
}
```
✅ **PASS** - spie also correctly interprets unescaped colon as header separator

### Test Case 3: Escaped Equals in Field Name

**Command:**
```bash
http --ignore-stdin POST http://localhost:8888/post 'field\=with\=equals=myvalue'
```

**Expected (http):**
- Field name: `"field=with=equals"` (with literal equals signs)
- Content-Type: `application/json`
- Request body: `{"field=with=equals": "myvalue"}`
- Response json field: `{"field=with=equals": "myvalue"}`

**Actual (http):**
```json
{
  "data": "{\"field=with=equals\": \"myvalue\"}",
  "json": {
    "field=with=equals": "myvalue"
  },
  "headers": {
    "Content-Type": "application/json"
  }
}
```
✅ **PASS** - http correctly handles escaped equals

**Actual (spie):**
```json
{
  "data": "",
  "form": {
    "field": "with=equals=myvalue"
  },
  "headers": {
    "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
  },
  "json": null
}
```
❌ **FAIL** - spie:
- Sends form-encoded data instead of JSON
- First escaped equals is treated as field separator → creates field "field"
- Remaining escaped equals remain in value: "with=equals=myvalue"
- Escape sequences not recognized

**Deviation:** ✗ INCOMPATIBLE
- Escape sequences not recognized or handled incorrectly
- First escape sequence ignored, treated as separator
- Content type and encoding mismatch

## Summary

**Overall Assessment:** FAILED - Escape sequences not supported in spie

### Key Differences

1. **Escape recognition**:
   - http: Recognizes and processes `\:` and `\=` as escape sequences
   - spie: Does not recognize escape sequences; treats backslash as literal character

2. **Field parsing**:
   - http: Escaped separators prevent field/header/data parsing, keeping them in field names
   - spie: Falls back to regular parsing; escape sequences don't prevent separator interpretation

3. **Default content type**:
   - http: Escaped sequences create data fields → JSON by default
   - spie: Creates form-encoded fields → form-urlencoded by default

4. **Semantic interpretation**:
   - http: `\:` = "literal colon, not a separator"
   - spie: `\:` = "backslash character followed by colon"

## Impact

- Cannot create field names with colons or equals signs in spie
- Escaping sequences are completely unsupported
- Any scripts using escaped separators will fail or behave differently
- Default encoding mismatch (JSON vs form-encoded)

## Blockers

None - the feature can be tested, but it's not implemented in spie.

## Notes

- This is a critical feature for handling edge cases in field names
- The feature is simple to implement but requires proper escape sequence parsing
- spie's form-encoding default is also an issue separate from escape handling

## Status

**FAILED** - The `request-item-escape` feature is not implemented in spie. Escape sequences are not recognized or processed, preventing literal use of separator characters in field names. See issue #25241.
