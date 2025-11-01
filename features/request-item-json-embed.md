# Feature: request-item-json-embed (:=@ separator)

**Slug:** request-item-json-embed

**Description:** Non-string JSON data fields from file using the `:=@` separator in request items. This allows specifying JSON values loaded from a file directly on the command line.

## Test Plan

This test verifies that both `http` and `spie` correctly handle the `:=@` separator for JSON field request items from files:

1. **Simple object embedding**: Test with `data:=@simple.json`
2. **Nested object embedding**: Test with `user:=@nested.json`
3. **Array embedding**: Test with `items:=@array.json`
4. **Mixed fields**: Test combining regular fields and JSON file fields
5. **Proper JSON serialization**: Verify the embedded JSON is properly parsed and included in request body

**Test Endpoint:** http://localhost:8888/post (accepts all standard methods and returns request details)

### Test Files

All test files were created with the following content:

- `simple.json`: `{"name": "test", "value": 42}`
- `nested.json`: `{"user": {"id": 1, "email": "test@example.com"}, "active": true}`
- `array.json`: `["item1", "item2", "item3"]`

### Commands to be Tested

#### With http:
- `http --ignore-stdin POST http://localhost:8888/post data:=@/tmp/httpie-test/simple.json`
- `http --ignore-stdin POST http://localhost:8888/post user:=@/tmp/httpie-test/nested.json`
- `http --ignore-stdin POST http://localhost:8888/post items:=@/tmp/httpie-test/array.json`
- `http --ignore-stdin POST http://localhost:8888/post name=John data:=@/tmp/httpie-test/simple.json`

#### With spie:
- Same commands as above

## Expected Behavior

According to HTTPie documentation:
- `:=@` is used for loading JSON data fields from a file
- The file contents should be parsed as JSON and included in the request body
- Works in JSON request mode (default for JSON fields)
- Can be mixed with other field types
- Results in a JSON request body with the embedded JSON properly included

## Test Results

### Test 1: Simple JSON file embedding
**Command:** `http --ignore-stdin POST http://localhost:8888/post data:=@/tmp/httpie-test/simple.json`

**http Result:**
```
POST /post HTTP/1.1
Accept-Encoding: gzip, deflate, zstd
Connection: keep-alive
Content-Length: 39
User-Agent: HTTPie/3.2.4
Accept: application/json, */*;q=0.5
Content-Type: application/json
Host: localhost:8888

{"data": {"name": "test", "value": 42}}

Response (truncated):
  "json": {
    "data": {
      "name": "test",
      "value": 42
    }
  }
```

**http Status:** ✅ Success (200) - Simple JSON object correctly embedded from file

**spie Result:**
```
HTTP/1.1 200
Content-Type: application/json

{
  "args": {},
  "data": "",
  "files": {
    "data:=": "{\"name\": \"test\", \"value\": 42}\n"
  },
  ...
}
```

**spie Status:** ❌ Failed - spie treats `:=@` as a multipart file field instead of JSON embedding

**Comparison:** ❌ MISMATCH
- http: Correctly parses the JSON file and includes it in the JSON request body
- spie: Incorrectly treats `:=@` as a multipart form file upload field

---

### Test 2: Nested JSON file embedding
**Command:** `http --ignore-stdin POST http://localhost:8888/post user:=@/tmp/httpie-test/nested.json`

**http Result:**
```
POST /post HTTP/1.1
Accept-Encoding: gzip, deflate, zstd
Connection: keep-alive
Content-Length: 74
User-Agent: HTTPie/3.2.4
Accept: application/json, */*;q=0.5
Content-Type: application/json
Host: localhost:8888

{"user": {"user": {"id": 1, "email": "test@example.com"}, "active": true}}

Response:
  "json": {
    "user": {
      "active": true,
      "user": {
        "email": "test@example.com",
        "id": 1
      }
    }
  }
```

**http Status:** ✅ Success (200) - Nested JSON object correctly embedded from file

**spie Result:**
```
{
  "args": {},
  "data": "",
  "files": {
    "user:=": "{\"user\": {\"id\": 1, \"email\": \"test@example.com\"}, \"active\": true}\n"
  },
  "json": null
}
```

**spie Status:** ❌ Failed - spie treats `:=@` as a multipart file field

**Comparison:** ❌ MISMATCH - Same issue as Test 1

---

### Test 3: Array JSON file embedding
**Command:** `http --ignore-stdin POST http://localhost:8888/post items:=@/tmp/httpie-test/array.json`

**http Result:**
```
POST /post HTTP/1.1
Accept-Encoding: gzip, deflate, zstd
Connection: keep-alive
Content-Length: 38
User-Agent: HTTPie/3.2.4
Accept: application/json, */*;q=0.5
Content-Type: application/json
Host: localhost:8888

{"items": ["item1", "item2", "item3"]}

Response:
  "json": {
    "items": [
      "item1",
      "item2",
      "item3"
    ]
  }
```

**http Status:** ✅ Success (200) - JSON array correctly embedded from file

**spie Status:** ❌ Failed - Same multipart file field handling issue

**Comparison:** ❌ MISMATCH - Same issue as Tests 1 and 2

---

### Test 4: Mixed fields with JSON embedding
**Command:** `http --ignore-stdin POST http://localhost:8888/post name=John data:=@/tmp/httpie-test/simple.json`

**http Result:**
```
POST /post HTTP/1.1
Accept-Encoding: gzip, deflate, zstd
Connection: keep-alive
Content-Type: application/json
Host: localhost:8888

{"name": "John", "data": {"name": "test", "value": 42}}

Response:
  "json": {
    "name": "John",
    "data": {
      "name": "test",
      "value": 42
    }
  }
```

**http Status:** ✅ Success (200) - Mixed fields correctly handled with JSON embedding

**spie Result:**
```
{
  "args": {},
  "data": "",
  "files": {
    "data:=": "{\"name\": \"test\", \"value\": 42}\n"
  },
  "form": {
    "name": "John"
  },
  "json": null
}
```

**spie Status:** ❌ Failed - spie creates multipart form data with file field instead of JSON body

**Comparison:** ❌ MISMATCH - Fundamentally different request types

---

## Summary

### Overall Status: FAILED ❌

The `request-item-json-embed` feature is **NOT IMPLEMENTED** in spie.

### Key Findings

1. **http Implementation**: Correctly implements `:=@` to load and parse JSON from files, embedding the parsed JSON in the request body
2. **spie Implementation**: Does not support `:=@` for JSON embedding. Instead, it treats the syntax as a multipart form file upload

### Deviations Found

| Aspect | http | spie | Status |
|--------|------|------|--------|
| Simple object embedding (:=@file) | ✓ JSON body | ✗ Multipart file | MISMATCH |
| Nested object embedding | ✓ JSON body | ✗ Multipart file | MISMATCH |
| Array embedding | ✓ JSON body | ✗ Multipart file | MISMATCH |
| Mixed fields | ✓ JSON body | ✗ Multipart form | MISMATCH |
| Content-Type header | application/json | multipart/form-data | MISMATCH |
| Request body type | JSON | Multipart form | FUNDAMENTAL DIFFERENCE |

### Root Cause

spie does not parse or recognize the `:=@` operator for JSON file embedding. It likely treats all `@` suffixes as file upload indicators for multipart form data.

### Impact

- Users cannot load JSON payloads from files using the `:=@` syntax
- This is a significant compatibility gap with HTTPie
- Workaround would be to manually read files and pass JSON via stdin or other means

### Recommendation

Implement the `:=@` operator in spie to support JSON file embedding, following the same behavior as HTTPie:
1. Parse the `:=@` operator
2. Read the specified file
3. Parse its contents as JSON
4. Include the parsed JSON object/array as a field value in the request body
5. Ensure proper Content-Type (application/json) is set

## Status

**FAILED** - The `request-item-json-embed` feature is not implemented in spie. A significant compatibility gap exists between http and spie regarding JSON file embedding.
