# Issue: Escape Sequences for Separators Not Supported

**Issue ID:** [#18](https://github.com/brandonbloom/SwiftPie/issues/18)
**Feature:** request-item-escape
**Severity:** Medium
**Status:** Open

## Problem

The backslash escape mechanism for special characters in field names is not implemented in spie. This prevents using literal colons (`:`) or equals signs (`=`) in field names, which would otherwise be interpreted as separators.

## Tested

**Feature:** request-item-escape
**Command examples:**
```bash
http --ignore-stdin POST http://localhost:8888/post 'field-with\:colon=value'
http --ignore-stdin POST http://localhost:8888/post 'field\=with\=equals=myvalue'
spie --ignore-stdin POST http://localhost:8888/post 'field-with\:colon=value'
spie --ignore-stdin POST http://localhost:8888/post 'field\=with\=equals=myvalue'
```

**Test Date:** 2025-11-01
**Environment:** httpbin at http://localhost:8888

## Expected Behavior (http)

When using escape sequences in field names:
1. `\:` prevents colon from being interpreted as header separator
2. `\=` prevents equals from being interpreted as field separator
3. Field name includes the literal escaped character
4. Creates a data field (JSON by default) with escaped characters in field name

Example 1 - Escaped colon:
```bash
http --ignore-stdin POST http://localhost:8888/post 'field-with\:colon=value'
```
Result:
```json
{
  "json": {
    "field-with:colon": "value"
  },
  "headers": {
    "Content-Type": "application/json"
  }
}
```

Example 2 - Escaped equals:
```bash
http --ignore-stdin POST http://localhost:8888/post 'field\=with\=equals=myvalue'
```
Result:
```json
{
  "json": {
    "field=with=equals": "myvalue"
  },
  "headers": {
    "Content-Type": "application/json"
  }
}
```

## Actual Behavior (spie)

When using escape sequences:
1. Backslash escape sequences are not recognized
2. Falls back to regular field parsing
3. First unescaped separator is used, rest are ignored
4. Sends form-encoded data instead of JSON

Example 1 - Escaped colon attempt:
```bash
spie --ignore-stdin POST http://localhost:8888/post 'field-with\:colon=value'
```
Result:
```json
{
  "form": {
    "field-with:colon": "value"
  },
  "headers": {
    "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
  }
}
```
- Field is created correctly (by accident)
- But with wrong content type (form instead of JSON)
- Escape sequence was not recognized

Example 2 - Escaped equals attempt:
```bash
spie --ignore-stdin POST http://localhost:8888/post 'field\=with\=equals=myvalue'
```
Result:
```json
{
  "form": {
    "field": "with=equals=myvalue"
  }
}
```
- First escaped equals is treated as field separator (escape ignored)
- Field name becomes just "field"
- Remaining escaped equals appear in the value
- Escape sequences were not recognized at all

## The Problem

**No escape sequence support:**
- spie does not recognize `\:` or `\=` as escape sequences
- Backslash is treated as a literal character
- First unescaped separator is still parsed

**Content type mismatch:**
- spie defaults to form encoding instead of JSON
- Escape sequences create data fields, which should be JSON by default

**Parsing issue:**
- When escape is ignored, first separator causes premature field termination
- Makes it impossible to use literal separators in field names

## Impact

- Cannot create field names containing colons (colon-separated case names, URIs, etc.)
- Cannot create field names containing equals signs
- Escape mechanism completely unavailable
- Default content type is wrong (form vs JSON)
- Some field names become impossible to represent
- Scripts using escaped separators will fail or behave differently

## Examples of Broken Use Cases

1. **Field names with URIs:** `url:http\://example.com=value` → fails
2. **Field names with math:** `equation:2\=2=4` → fails
3. **Compound identifiers:** `id\=type:123=test` → fails

## Recommendations

1. **Implement escape sequence parsing:**
   - Recognize `\:` in field names to prevent header interpretation
   - Recognize `\=` in field names to prevent data field interpretation
   - Remove the backslash from processed field names

2. **Fix content type handling:**
   - Escaped data fields should produce JSON, not form-encoded
   - Only use form encoding when `--form` flag is present

3. **Update field name parsing:**
   - Check for escaped separators before applying separator logic
   - Handle multiple escape sequences in single field name

4. **Test edge cases:**
   - Mixed escaped and unescaped separators
   - Multiple escapes in one field name
   - Escaped separators with other request item types

## Related Features

- feature: request-item-data-fields (= syntax for data)
- feature: request-item-headers (: syntax for headers)
- feature: form-flag (--form, affects default content type)
