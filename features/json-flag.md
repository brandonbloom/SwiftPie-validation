# Feature: json-flag (--json, -j)

**Slug:** json-flag

**Description:** JSON serialization flag that sets the default request content type to JSON. When used, data items are serialized as JSON objects and both Content-Type and Accept headers are automatically set to application/json.

## Test Plan

This test verifies that both `http` and `spie` correctly handle the `--json` flag and its shorthand `-j`:

1. **Basic --json Flag**: Test with single and multiple data fields
2. **Shorthand -j**: Test the short form of the flag
3. **JSON Field Types**: Test both string fields (=) and JSON fields (:=)
4. **Content-Type Header**: Verify application/json is set in requests
5. **Accept Header**: Verify application/json is set in Accept header
6. **Default Behavior**: Test that JSON is the default serialization format
7. **Body Format**: Verify request body is valid JSON when using --json

**Test Endpoint:** http://localhost:8888/post (accepts all standard methods and returns request details)

### Commands Tested

With `http`:
- `http --ignore-stdin --json POST http://localhost:8888/post name=John`
- `http --ignore-stdin -j POST http://localhost:8888/post key=value`
- `http --ignore-stdin --json POST http://localhost:8888/post name=John age:=30`
- `http --ignore-stdin --json POST http://localhost:8888/post 'tags:=["a", "b", "c"]'`
- `http --ignore-stdin POST http://localhost:8888/post name=John` (default behavior)
- `http --ignore-stdin --headers --json POST http://localhost:8888/post name=test`

With `spie`:
- Same commands as above

## Expected Behavior

According to HTTPie documentation:
- The `--json` flag (or `-j`) is the DEFAULT content type for data serialization
- When used, data items from the command line are serialized as a JSON object
- The Content-Type header is automatically set to `application/json` (if not specified)
- The Accept header is set to `application/json, */*;q=0.5` (if not specified)
- Both string fields (=) and JSON fields (:=) work with --json

## Test Results

### Test 1: Basic --json flag with single field
**Command:** `http --ignore-stdin --json POST http://localhost:8888/post name=John`

**http Result:**
```
POST /post HTTP/1.1
Accept-Encoding: gzip, deflate, zstd
Connection: keep-alive
Content-Length: 16
User-Agent: HTTPie/3.2.4
Accept: application/json, */*;q=0.5
Content-Type: application/json
Host: localhost:8888

{"name": "John"}

HTTP/1.1 200 OK
...
{
  "json": {
    "name": "John"
  },
  ...
}
```

**Status:** Success (200)
**Content-Type in request:** application/json ✓
**Accept header:** application/json, */*;q=0.5 ✓
**Body is JSON:** Yes ✓

**spie Result:**
```
error: unknown option '--json'
```

**Status:** ERROR - Flag not supported
**Comparison:** MISMATCH - spie does not support the --json flag

---

### Test 2: Shorthand -j flag
**Command:** `http --ignore-stdin -j POST http://localhost:8888/post key=value`

**http Result:**
```
POST /post HTTP/1.1
Accept-Encoding: gzip, deflate, zstd
Connection: keep-alive
Content-Length: 15
User-Agent: HTTPie/3.2.4
Accept: application/json, */*;q=0.5
Content-Type: application/json
Host: localhost:8888

{"key": "value"}

HTTP/1.1 200 OK
...
{
  "json": {
    "key": "value"
  },
  ...
}
```

**Status:** Success (200)
**Content-Type in request:** application/json ✓
**Body is JSON:** Yes ✓

**spie Result:**
```
error: unknown option '-j'
```

**Status:** ERROR - Flag not supported
**Comparison:** MISMATCH - spie does not support the -j shorthand

---

### Test 3: Multiple fields with JSON
**Command:** `http --ignore-stdin --json POST http://localhost:8888/post name=John age:=30`

**http Result:**
```
POST /post HTTP/1.1
Accept-Encoding: gzip, deflate, zstd
Connection: keep-alive
Content-Length: 28
User-Agent: HTTPie/3.2.4
Accept: application/json, */*;q=0.5
Content-Type: application/json
Host: localhost:8888

{"name": "John", "age": 30}

HTTP/1.1 200 OK
...
{
  "json": {
    "name": "John",
    "age": 30
  },
  ...
}
```

**Status:** Success (200)
**Body contains both fields:** Yes ✓
**JSON is valid:** Yes ✓

**spie Result:**
```
error: unknown option '--json'
```

**Status:** ERROR - Flag not supported
**Comparison:** MISMATCH - spie does not support the --json flag

---

### Test 4: JSON fields with := (complex data types)
**Command:** `http --ignore-stdin --json POST http://localhost:8888/post 'tags:=["a", "b", "c"]'`

**http Result:**
```
POST /post HTTP/1.1
Accept-Encoding: gzip, deflate, zstd
Connection: keep-alive
Content-Length: 24
User-Agent: HTTPie/3.2.4
Accept: application/json, */*;q=0.5
Content-Type: application/json
Host: localhost:8888

{"tags": ["a", "b", "c"]}

HTTP/1.1 200 OK
...
{
  "json": {
    "tags": ["a", "b", "c"]
  },
  ...
}
```

**Status:** Success (200)
**Array parsed correctly:** Yes ✓
**JSON type preservation:** Yes ✓

**spie Result:**
```
error: unknown option '--json'
```

**Status:** ERROR - Flag not supported
**Comparison:** MISMATCH - spie does not support the --json flag

---

### Test 5: Default behavior (no --json flag specified)
**Command:** `http --ignore-stdin POST http://localhost:8888/post name=John`

**http Result:**
```
POST /post HTTP/1.1
Accept-Encoding: gzip, deflate, zstd
Connection: keep-alive
Content-Length: 16
User-Agent: HTTPie/3.2.4
Accept: application/json, */*;q=0.5
Content-Type: application/json
Host: localhost:8888

{"name": "John"}

HTTP/1.1 200 OK
...
{
  "json": {
    "name": "John"
  },
  ...
}
```

**Status:** Success (200)
**Default is JSON:** Yes ✓ (--json is the default)
**Comparison:** MATCH - http correctly defaults to JSON

**spie Result:**
```
HTTP/1.1 200
Connection: keep-alive
Access-Control-Allow-Credentials: true
Access-Control-Allow-Origin: *
Server: gunicorn/19.9.0
Content-Length: 540
Date: Sat, 01 Nov 2025 16:28:56 GMT
Content-Type: application/json

{
  "args": {},
  "data": "",
  "files": {},
  "form": {
    "name": "John"
  },
  "headers": {
    "Content-Type": "application/x-www-form-urlencoded; charset=utf-8",
    ...
  },
  "json": null,
  ...
}
```

**Status:** Success (200)
**Default serialization:** Form data (application/x-www-form-urlencoded)
**Comparison:** MISMATCH - spie defaults to form data, not JSON

---

### Test 6: Header verification with --headers
**Command:** `http --ignore-stdin --headers --json POST http://localhost:8888/post name=test`

**http Result:**
```
POST /post HTTP/1.1
Accept-Encoding: gzip, deflate, zstd
Connection: keep-alive
Content-Length: 16
User-Agent: HTTPie/3.2.4
Accept: application/json, */*;q=0.5
Content-Type: application/json
Host: localhost:8888

HTTP/1.1 200 OK
Server: gunicorn/19.9.0
Date: Sat, 01 Nov 2025 16:29:16 GMT
Connection: keep-alive
Content-Type: application/json
Content-Length: 476
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
```

**Status:** Success (200)
**Content-Type header present:** Yes ✓
**Accept header present:** Yes ✓

**spie Result:**
```
error: unknown option '--headers'
```

**Status:** ERROR - Option not supported in spie
**Note:** spie doesn't support the --headers flag, so this comparison is not directly possible

---

## Summary

### Overall Status: FAILED

The `json-flag` feature is **NOT IMPLEMENTED** in `spie`.

### Key Findings

1. **Flag Not Implemented**: spie does not recognize the `--json` or `-j` flags
2. **Default Behavior Different**: spie defaults to form data (application/x-www-form-urlencoded), while http defaults to JSON (application/json)
3. **No Content-Type Auto-Set**: spie does not automatically set Content-Type to application/json
4. **No Accept Header Auto-Set**: spie does not automatically set Accept to application/json

### Deviations Found

| Aspect | http | spie | Status |
|--------|------|------|--------|
| `--json` flag support | ✓ Supported | ✗ Not supported | DEVIATION |
| `-j` shorthand | ✓ Supported | ✗ Not supported | DEVIATION |
| Default serialization | JSON | Form data | DEVIATION |
| Content-Type header | application/json | application/x-www-form-urlencoded | DEVIATION |
| Accept header | application/json, */*;q=0.5 | */* | DEVIATION |
| JSON field parsing (:=) | ✓ Works | ✓ Works (when no flag needed) | MATCH |

### Issues Created

This feature will require creating an issue documenting:
- Missing `--json` and `-j` flag implementation
- Wrong default serialization format
- Missing automatic Content-Type and Accept header handling

### Notes

1. **spie's default behavior**: Without a `--json` flag, spie appears to default to form data serialization, which is the opposite of HTTPie's design where JSON is the default.

2. **JSON field support**: spie does support the `:=` syntax for JSON fields (as shown in the help output), but without the `--json` flag being explicitly supported, the context is unclear.

3. **Missing flags**: spie is also missing the `--headers`, `--form`, `--multipart`, and other content-type related flags that would allow users to explicitly select JSON or form serialization.

## Status

**FAILED** - The `--json` flag feature is not implemented in spie. Critical deviation from HTTPie behavior.
