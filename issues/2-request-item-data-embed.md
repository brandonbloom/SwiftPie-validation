# Issue: Data Embed Fields (=@) Default to Multipart Instead of JSON

**Issue ID:** [#2](https://github.com/brandonbloom/SwiftPie/issues/2)
**Feature:** request-item-data-embed
**Severity:** Critical
**Status:** Open

## Problem

The `=@` request item syntax (data embed from file) behaves fundamentally differently between `http` and `spie`:

- **http**: Reads file content and embeds it as a JSON string value (sends JSON by default)
- **spie**: Treats all `=@` fields as multipart file uploads (sends multipart/form-data)

This breaks compatibility with HTTPie scripts that expect data embedding to work like JSON field embedding.

## Tested

**Feature:** request-item-data-embed
**Command examples:**
```bash
http POST http://localhost:8888/post content=@/tmp/embed_test.txt
http POST http://localhost:8888/post file1=@/tmp/embed_test.txt file2=@/tmp/form_data.txt
http POST http://localhost:8888/post name=John file=@/tmp/embed_test.txt age=30
```

**Test Date:** 2025-11-01
**Environment:** httpbin at http://localhost:8888

## Expected Behavior (http)

When using `key=@/path/to/file`:
1. File content is read as a string
2. Field is added to JSON object with string value
3. Default Content-Type is `application/json`
4. Request body: `{"key": "file content here"}`

Example output from httpbin:
```json
{
  "json": {
    "content": "Test data from file\n"
  },
  "data": "{\"content\": \"Test data from file\\n\"}",
  "headers": {
    "Content-Type": "application/json"
  }
}
```

## Actual Behavior (spie)

When using `key=@/path/to/file`:
1. File is treated as a multipart file upload
2. Field is added to multipart form-data
3. Content-Type is `multipart/form-data`
4. Request body: multipart with file as attachment
5. Field name is corrupted: `"key="` instead of `"key"`

Example output from httpbin:
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

## The Problem

**Semantic mismatch:**
- `=@` should mean "read file and use content as field value" (data embedding)
- spie interprets it as "upload file" (file upload)

**Related issues:**
- spie lacks `--form` flag support, so there's no way to fix this with an explicit flag
- Field names get corrupted in multipart (appends `=` to name)
- Default content type is wrong (form instead of JSON)

## Impact

- Incompatible with HTTPie scripts using data embedding
- Cannot send file contents as JSON field values
- APIs expecting JSON payloads receive multipart/form-data instead
- Mixed field requests (both regular and embedded) fail
- No workaround available (no --form flag to enable correct behavior)

## Recommendations

1. **Implement proper content type handling:**
   - Make `=@` read file as string value and embed in JSON by default
   - Only use multipart when `--form` flag is present

2. **Add `--form` flag support:**
   - Allow explicit selection of form encoding
   - When `--form` is used with `=@`, send as form field value

3. **Fix field name handling:**
   - Remove spurious `=` suffix from field names
   - Ensure field names match original specification

4. **Distinguish semantics:**
   - `=@` = embed file content as string value
   - Consider separate syntax for file uploads if needed

## Related Features

- feature: request-item-form-files (@ syntax for file uploads)
- feature: form-flag (--form flag for form encoding)
- feature: request-item-data-fields (= syntax for regular data fields)
