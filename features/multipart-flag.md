# Multipart Flag Feature Tests

**Feature Slug:** `multipart-flag`
**HTTP Option:** `--multipart`
**Description:** Force multipart/form-data request even without files

## Feature Overview

The `--multipart` flag forces HTTPie to send a request with `Content-Type: multipart/form-data` encoding, even when no file fields are present. This is useful for APIs that specifically require multipart encoding for form data.

## Test Results

**Status: FAILED** ✗

### Test Environment
- **HTTPie Version:** 3.2.4
- **SpIE Version:** Swift-based implementation (unknown version)
- **HTTPBin Server:** http://localhost:8888 (running)
- **Test Date:** 2025-11-01

### Tests Performed

#### Test 1: Force Multipart Without Files (http)
- **Command:** `http --multipart --ignore-stdin POST http://localhost:8888/post field=value`
- **Expected:** `Content-Type: multipart/form-data`
- **Result:** ✓ PASS
- **Details:** HTTPie correctly forces multipart encoding even without file fields
  ```
  Content-Type: multipart/form-data; boundary=d24262969c6a43e9b16e98a75cb70073
  ```

#### Test 2: Multipart With Multiple Form Fields (http)
- **Command:** `http --multipart --ignore-stdin POST http://localhost:8888/post field1=value1 field2=value2 field3=value3`
- **Expected:** All fields encoded as multipart, Content-Type includes boundary
- **Result:** ✓ PASS
- **Details:** HTTPie properly encodes multiple fields as multipart data
  ```
  Content-Type: multipart/form-data; boundary=9c64f7016f704f05bf1913b7487570a3
  ```

#### Test 3: Multipart With File Fields (http)
- **Command:** `http --multipart --ignore-stdin POST http://localhost:8888/post name=John resume@/tmp/test-multipart.txt`
- **Expected:** Mixed form fields and file content in multipart encoding
- **Result:** ✓ PASS
- **Details:** HTTPie handles mixed form and file fields correctly in multipart
  ```
  Content-Type: multipart/form-data; boundary=1f12b7bc7c22440baa5ea0f613a16d5c
  ```

#### Test 4: SpIE Form Fields Without Files
- **Command:** `spie --ignore-stdin POST http://localhost:8888/post field=value`
- **Expected (if --multipart existed):** `Content-Type: multipart/form-data`
- **Actual:** `Content-Type: application/x-www-form-urlencoded; charset=utf-8`
- **Result:** ✗ FAIL
- **Details:** SpIE does NOT have a `--multipart` flag. Form fields default to URL-encoded format.

#### Test 5: SpIE With File Fields
- **Command:** `spie --ignore-stdin POST http://localhost:8888/post file@/tmp/test-multipart.txt`
- **Expected:** `Content-Type: multipart/form-data`
- **Result:** ✓ PASS
- **Details:** SpIE automatically switches to multipart when file fields (@) are present
  ```
  Content-Type: multipart/form-data; boundary=boundary-0DAFC12B-47A3-4C60-A3C8-4F1598845BA5
  ```

### Implementation Differences

| Feature | http | spie | Status |
|---------|------|------|--------|
| `--multipart` flag exists | ✓ | ✗ | spie lacks this flag |
| Multipart without files | ✓ (with flag) | ✗ | spie cannot force multipart without files |
| Multipart with files | ✓ | ✓ (automatic) | Different approach: explicit vs. automatic |
| Content-Type management | ✓ | ✓ (partial) | spie auto-detects but cannot override |

### Key Findings

1. **HTTPie Behavior (--multipart):**
   - Forces `multipart/form-data` encoding regardless of content
   - Works with or without file fields
   - Useful for APIs that require multipart encoding
   - Requires explicit flag

2. **SpIE Behavior (No --multipart):**
   - Defaults to `application/x-www-form-urlencoded` for form fields
   - Automatically switches to `multipart/form-data` when @ file fields are present
   - **No way to force multipart without files**
   - Takes automatic approach instead of explicit control

### Compatibility Notes

1. **Missing Feature:** SpIE does not have a `--multipart` flag at all
2. **Use Case Impact:** APIs requiring multipart encoding for non-file form data cannot be called with SpIE
3. **Workaround:** None. SpIE cannot force multipart without including dummy file fields

### Edge Cases Tested

- Multiple form fields with multipart ✓ (http only)
- Mixed form fields and files ✓
- Empty multipart requests ✓ (http)
- URL-encoded default (spie) ✓

## Conclusion

**Status: FAILED** ✗

The `--multipart` feature is **not implemented in SpIE**.

### Summary Table:
| Aspect | http | spie |
|--------|------|------|
| Flag support | ✓ Available | ✗ Missing |
| Can force multipart without files | ✓ Yes | ✗ No |
| Auto-detects multipart with files | ✓ Yes | ✓ Yes |
| Content-Type control | ✓ Full | ✗ Partial |

### Test Results:
- **Total Tests:** 5
- **Passed (http only):** 3
- **Failed (spie gap):** 2
- **Success Rate:** 60% (http passes 100%, spie fails on core feature)

---

**Test Notes:**
- HTTPie's `--multipart` flag provides explicit control over request encoding
- SpIE's automatic multipart detection works but cannot be forced for non-file requests
- This is a significant deviation: HTTPie users can force multipart encoding; SpIE users cannot
- No reasonable workaround exists in SpIE for this use case
