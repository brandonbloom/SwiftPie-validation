# Feature: Request Items - Data Embed (=@)

## Description
Data embed fields with `=@` separator are used to read field values from files. This allows embedding file contents directly into request bodies as field values (either as JSON strings or form data, depending on the content type).

## Syntax
```
key=@/path/to/file    # Read file content and use as field value
key=@/path/to/file    # Multiple files can be specified
```

## Test Results

### Status: FAILED ✗

The implementations handle data embed fields fundamentally differently:
- **http**: Reads file content as strings and embeds in JSON by default
- **spie**: Treats files as multipart form uploads regardless of context

### Test Cases

#### Test 1: Single data-embed field (default behavior)
**Command:** `http POST http://localhost:8888/post content=@/tmp/embed_test.txt`

**Expected (http):** Sends as JSON with Content-Type: application/json
- Request body: `{"content": "Test data from file\n"}`
- Response: `"json": {"content": "Test data from file\n"}`
- Files field: Empty

**Actual (spie):** Sends as multipart form data with Content-Type: multipart/form-data
- Request body: multipart/form-data with file upload
- Response: `"files": {"content=": "Test data from file\n"}`
- JSON field: null

**Deviation:** ✗ INCOMPATIBLE - Content type and encoding completely different

#### Test 2: JSON file embedding
**Command:** `http POST http://localhost:8888/post data=@/tmp/json_data.json`

**Expected (http):** Embeds JSON file content as a string value
- Request body: `{"data": "{\"key\":\"value\"}\n"}`
- Content-Type: application/json
- Data field contains stringified JSON

**Actual (spie):** Treats as multipart file upload
- Request body: multipart/form-data
- Files field contains the JSON file content
- JSON field: null

**Deviation:** ✗ INCOMPATIBLE - Completely different interpretation

#### Test 3: Multiple data-embed fields
**Command:** `http POST http://localhost:8888/post file1=@/tmp/embed_test.txt file2=@/tmp/form_data.txt`

**Expected (http):** All embedded files as JSON string values
- Request body: `{"file1": "Test data from file\n", "file2": "form value with spaces\n"}`
- Content-Type: application/json
- All fields in single JSON object

**Actual (spie):** All treated as file uploads
- Request body: multipart/form-data
- Files field: `{"file1=": "...", "file2=": "..."}`
- JSON field: null

**Deviation:** ✗ INCOMPATIBLE - Different default content type and encoding

#### Test 4: With --form flag
**Command:** `http --form POST http://localhost:8888/post content=@/tmp/embed_test.txt`

**Expected (http):** With --form, embedded files are treated as form fields
- Request body: `name=value` (form-encoded)
- Content-Type: application/x-www-form-urlencoded
- Form field contains file content

**Actual (spie):** Does not support --form flag
- Error: `unknown option '--form'`
- Cannot explicitly control content type

**Deviation:** ⚠ BLOCKER - spie lacks --form flag support entirely

#### Test 5: Mixed regular and embedded fields
**Command:** `http POST http://localhost:8888/post name=John file=@/tmp/embed_test.txt age=30`

**Expected (http):** All fields in single JSON object
- Request body: `{"name": "John", "file": "Test data from file\n", "age": "30"}`
- Content-Type: application/json
- All values as strings in JSON object

**Actual (spie):** Mixed form and file data
- Request body: multipart/form-data
- Form field: `{"name": "John", "age": "30"}`
- Files field: `{"file=": "Test data from file\n"}`
- Cannot represent all fields consistently

**Deviation:** ✗ INCOMPATIBLE - Mixes multipart form with file data incorrectly

## Summary

**Overall Assessment:** FAILED - Critical behavioral difference

### Key Issues

1. **Default content type mismatch**:
   - http: Embeds files as JSON string values (application/json)
   - spie: Treats all `=@` as multipart file uploads (multipart/form-data)

2. **Missing --form flag support**:
   - spie doesn't recognize the --form flag at all
   - Cannot convert to form-encoded data even with explicit flag

3. **Semantic misinterpretation**:
   - http: `=@` means "read file and use as field value (string)"
   - spie: `=@` means "upload file" (file upload, not value embedding)

4. **Field name corruption**:
   - spie appends `=` to field names in files dict: `"file="` instead of `"file"`

### Impact

- Applications expecting JSON request bodies with file content will receive multipart uploads instead
- Cannot replicate http behavior for APIs that need file content as JSON values
- Scripts mixing regular fields with embedded files will fail
- No way to use --form flag to control encoding

### Recommendations

1. **Implement proper content type handling**:
   - Make `=@` read file as string value, not as file upload
   - Default to JSON unless --form flag is used

2. **Add --form flag support**:
   - Allow explicit selection of form encoding
   - When --form is used with `=@`, send as form-encoded field value

3. **Fix field name handling**:
   - Remove spurious `=` from field names in multipart uploads
   - Ensure field names match original specification

4. **Distinguish file upload from value embedding**:
   - `=@` should embed file as string value
   - Consider using `@` syntax for actual file uploads (if needed)

## Test Evidence

All tests were run against httpbin at http://localhost:8888

### Test Environment
- HTTP implementation: HTTPie 3.2.4
- Spie implementation: /Users/bbloom/Projects/httpie-delta/bin/spie (version unknown)
- Date: 2025-11-01
- Test files:
  - `/tmp/embed_test.txt`: "Test data from file\n"
  - `/tmp/form_data.txt`: "form value with spaces\n"
  - `/tmp/json_data.json`: '{"key":"value"}'

### Raw Response Data

**Test 1 - Single embed field:**

HTTP response:
```json
{
  "data": "{\"content\": \"Test data from file\\n\"}",
  "json": {
    "content": "Test data from file\n"
  },
  "headers": {
    "Content-Type": "application/json"
  }
}
```

SPIE response:
```json
{
  "files": {
    "content=": "Test data from file\n"
  },
  "json": null,
  "headers": {
    "Content-Type": "multipart/form-data; boundary=..."
  }
}
```

**Test 5 - Mixed fields:**

HTTP response:
```json
{
  "data": "{\"name\": \"John\", \"file\": \"Test data from file\\n\", \"age\": \"30\"}",
  "json": {
    "name": "John",
    "file": "Test data from file\n",
    "age": "30"
  }
}
```

SPIE response:
```json
{
  "files": {
    "file=": "Test data from file\n"
  },
  "form": {
    "name": "John",
    "age": "30"
  }
}
```

## Status

**FAILED** ✗ - The `request-item-data-embed` feature is not properly implemented in spie. Critical deviations in content type handling, semantic interpretation, and missing --form flag support.
