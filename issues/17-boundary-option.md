# Issue: Boundary Option (--boundary) Not Implemented

**Issue ID:** [#17](https://github.com/brandonbloom/SwiftPie/issues/17)
**Feature:** boundary-option
**Severity:** High
**Status:** Open

## Problem

The `--boundary` option is not implemented in spie. This option allows specifying a custom boundary string for multipart/form-data requests, which is useful for compatibility with APIs that require specific boundary values or to work around conflicts with data content.

## Tested

**Feature:** boundary-option
**Command example:**
```bash
http --ignore-stdin --form --boundary="CUSTOM_BOUNDARY_STRING_123" POST http://localhost:8888/post field1=value1 file@/tmp/testfile.txt
spie --ignore-stdin --form --boundary="CUSTOM_BOUNDARY_STRING_123" POST http://localhost:8888/post field1=value1 file@/tmp/testfile.txt
```

**Test Date:** 2025-11-01
**Environment:** httpbin at http://localhost:8888

## Expected Behavior (http)

When using `--boundary BOUNDARY_STRING`:
1. Option is recognized as a valid flag
2. Multipart/form-data requests use the custom boundary
3. Content-Type header includes the custom boundary: `multipart/form-data; boundary=CUSTOM_BOUNDARY_STRING_123`
4. Request body uses `--CUSTOM_BOUNDARY_STRING_123` as delimiter

Example http behavior:
```
POST /post HTTP/1.1
Content-Type: multipart/form-data; boundary=CUSTOM_BOUNDARY_STRING_123

--CUSTOM_BOUNDARY_STRING_123
Content-Disposition: form-data; name="field1"

value1
--CUSTOM_BOUNDARY_STRING_123
Content-Disposition: form-data; name="file"; filename="testfile.txt"
Content-Type: text/plain

test content

--CUSTOM_BOUNDARY_STRING_123--
```

## Actual Behavior (spie)

When using `--boundary BOUNDARY_STRING`:
1. Option is not recognized
2. Error: `unknown option '--boundary=...'`
3. Request fails to execute
4. No fallback or alternative provided

Example error:
```
error: unknown option '--boundary=CUSTOM_BOUNDARY_STRING_123'
```

## The Problem

**Missing feature:**
- `--boundary` option is not implemented in spie
- spie automatically generates UUID-based boundaries when multipart is needed
- No way to customize the boundary string

**Related issues:**
- Depends on `--form` flag (also not implemented in spie)
- spie lacks CLI option for controlling multipart boundaries

## Impact

- Cannot use custom boundary strings for API compatibility
- No control over multipart boundary generation
- Auto-generated UUID boundaries may conflict with data content
- Incompatible with HTTPie scripts using custom boundaries
- APIs requiring specific boundaries cannot be tested with spie

## Recommendations

1. **Implement the `--boundary` option:**
   - Accept custom boundary string via CLI flag
   - Apply only to multipart/form-data requests
   - Validate boundary string format (alphanumeric, hyphens, underscores)

2. **Validate boundary values:**
   - Ensure boundary doesn't appear in request body
   - Warn or error if boundary would create conflicts
   - Document boundary string requirements

3. **Document interaction with --form:**
   - Make clear that `--boundary` only applies with multipart encoding
   - Specify behavior when no files are present (boundary ignored)

## Related Features

- feature: boundary-option (--boundary)
- feature: form-flag (--form, required for multipart)
- feature: request-item-form-files (@ syntax for file uploads)
