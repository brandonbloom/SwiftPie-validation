# boundary-option Feature Test

## Description
The `--boundary` option allows specifying a custom boundary string for multipart/form-data requests. This is useful when the default boundary might conflict with the data being sent or when specific boundary strings are required for compatibility.

## Usage
```
--boundary BOUNDARY
  Specify a custom boundary string for multipart/form-data requests. Only has effect together with --form.
```

## Test Cases

### Test 1: Custom boundary with form file upload (http)
**Command:**
```bash
echo "test content" > /tmp/testfile.txt
http --ignore-stdin --print=HhBb --form --boundary="CUSTOM_BOUNDARY_STRING_123" POST httpbin.org/post field1=value1 file@/tmp/testfile.txt
```

**Expected Behavior:**
- Request should use multipart/form-data content type
- Content-Type header should include the custom boundary: `Content-Type: multipart/form-data; boundary=CUSTOM_BOUNDARY_STRING_123`
- Request body should use `--CUSTOM_BOUNDARY_STRING_123` as the boundary delimiter

**Result: PASS**
- ✅ http correctly uses custom boundary in Content-Type header
- ✅ Request body correctly uses `--CUSTOM_BOUNDARY_STRING_123--` delimiters
- ✅ File is uploaded correctly with the custom boundary

### Test 2: Custom boundary with form file upload (spie)
**Command:**
```bash
spie --ignore-stdin --form --boundary="CUSTOM_BOUNDARY_STRING_123" POST httpbin.org/post field1=value1 file@/tmp/testfile.txt
```

**Expected Behavior:**
- Should recognize the `--boundary` option and use custom boundary

**Result: FAIL**
- ❌ spie does not support the `--form` flag
- ❌ spie does not support the `--boundary` option (error: unknown option '--boundary=...')
- ℹ️ spie automatically generates a UUID-based boundary when multipart is needed

### Test 3: Form data without files (http boundary has no effect)
**Command:**
```bash
http --ignore-stdin --print=HhBb --form --boundary="CUSTOM_BOUNDARY_STRING_123" POST httpbin.org/post field1=value1 field2=value2
```

**Expected Behavior:**
- Should use application/x-www-form-urlencoded since no files are involved
- Boundary option should have no effect

**Result: PASS**
- ✅ http correctly ignores boundary when not using multipart
- ✅ Uses `Content-Type: application/x-www-form-urlencoded` instead

### Test 4: Spie multipart without boundary control
**Command:**
```bash
spie --ignore-stdin POST httpbin.org/post field1=value1 file@/tmp/testfile.txt
```

**Expected Behavior:**
- spie should generate a default boundary since it detects file upload
- No option to customize the boundary

**Result: PASS for spie behavior**
- ✅ spie correctly detects file upload and uses multipart
- ✅ Generates UUID-based boundary: `boundary-205D0B75-AF0C-4A8B-B38B-1167B4A76F63`
- ❌ But cannot customize this boundary

## Compatibility Summary

| Feature | http | spie |
|---------|------|------|
| `--form` flag support | ✅ Yes | ❌ No |
| `--boundary` option support | ✅ Yes | ❌ No |
| Multipart generation | ✅ Yes | ✅ Yes |
| Custom boundary control | ✅ Yes | ❌ No |

## Conclusion
**Status: FAILED**

spie does not support the `--boundary` option at all. The feature is completely missing from the spie implementation. While spie does generate multipart/form-data requests when files are present, there is no way to customize the boundary string as required by this feature.

**Required for spie:**
- [ ] Add `--boundary` option support
- [ ] Only apply boundary when using multipart (file uploads)
- [ ] Validate boundary string format

## Test Details

### HTTP Test Output
```
POST /post HTTP/1.1
Accept-Encoding: gzip, deflate, zstd
Accept: */*
Connection: keep-alive
Content-Length: 262
User-Agent: HTTPie/3.2.4
Content-Type: multipart/form-data; boundary=CUSTOM_BOUNDARY_STRING_123
Host: httpbin.org

--CUSTOM_BOUNDARY_STRING_123
Content-Disposition: form-data; name="field1"

value1
--CUSTOM_BOUNDARY_STRING_123
Content-Disposition: form-data; name="file"; filename="testfile.txt"
Content-Type: text/plain

test content

--CUSTOM_BOUNDARY_STRING_123--
```

### Spie Error Output
```
error: unknown option '--boundary=CUSTOM_BOUNDARY_STRING_123'
```
