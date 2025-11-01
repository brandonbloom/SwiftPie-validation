# Feature: method-argument (HTTP Method Support)

**Slug:** method-argument

**Description:** Support for HTTP methods (GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS, etc.) with smart defaults based on request content.

## Test Plan

This test verifies that both `http` and `spie` correctly handle HTTP method specification and smart default selection:

1. **Explicit Method Tests**: Test each standard HTTP method (GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS)
2. **Case Sensitivity**: Test uppercase, lowercase, and mixed case method names
3. **Smart Defaults**:
   - Without data and without stdin: should default to GET
   - With data fields: should default to POST
   - With query parameters (==): should remain GET
4. **Custom Methods**: Test behavior with non-standard HTTP methods

**Test Endpoint:** http://localhost:8888/anything (accepts all standard methods)

### Commands Tested

- `http GET http://localhost:8888/anything`
- `http POST http://localhost:8888/anything`
- `http PUT http://localhost:8888/anything`
- `http DELETE http://localhost:8888/anything`
- `http PATCH http://localhost:8888/anything`
- `http HEAD http://localhost:8888/anything`
- `http OPTIONS http://localhost:8888/anything`
- `http --ignore-stdin http://localhost:8888/anything` (default GET)
- `http --ignore-stdin http://localhost:8888/anything name=John` (default POST with data)
- `http --ignore-stdin http://localhost:8888/anything search==test` (GET with query params)
- `http get http://localhost:8888/anything` (lowercase method)
- `http Get http://localhost:8888/anything` (mixed case method)
- `http CUSTOM http://localhost:8888/anything` (unsupported method)

And equivalent tests with `spie`.

## Expected Behavior

According to httpie documentation:
- The METHOD argument is optional
- When omitted, httpie uses POST if data is being sent, otherwise GET
- Methods are case-insensitive
- Standard HTTP methods should be supported: GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS

## Test Results

### Test 1: Explicit GET Method
**Command:** `http GET http://localhost:8888/anything`
**http Result:**
```
method: "GET"
Status: Success (200)
```

**spie Result:**
```
method: "GET"
Status: Success (200)
```

**Comparison:** MATCH - Both correctly send GET request

---

### Test 2: Explicit POST Method
**Command:** `http POST http://localhost:8888/anything`
**http Result:**
```
method: "POST"
Status: Success (200)
```

**spie Result:**
```
method: "POST"
Status: Success (200)
```

**Comparison:** MATCH - Both correctly send POST request

---

### Test 3: Explicit PUT Method
**Command:** `http PUT http://localhost:8888/anything`
**http Result:**
```
method: "PUT"
Status: Success (200)
```

**spie Result:**
```
method: "PUT"
Status: Success (200)
```

**Comparison:** MATCH - Both correctly send PUT request

---

### Test 4: Explicit DELETE Method
**Command:** `http DELETE http://localhost:8888/anything`
**http Result:**
```
method: "DELETE"
Status: Success (200)
```

**spie Result:**
```
method: "DELETE"
Status: Success (200)
```

**Comparison:** MATCH - Both correctly send DELETE request

---

### Test 5: Explicit PATCH Method
**Command:** `http PATCH http://localhost:8888/anything`
**http Result:**
```
method: "PATCH"
Status: Success (200)
```

**spie Result:**
```
method: "PATCH"
Status: Success (200)
```

**Comparison:** MATCH - Both correctly send PATCH request

---

### Test 6: Explicit HEAD Method
**Command:** `http HEAD http://localhost:8888/anything`
**http Result:**
```
Status: 200 OK
No response body (expected for HEAD)
Verbose output shows: HEAD /anything HTTP/1.1
```

**spie Result:**
```
Status: 200 OK
No response body (expected for HEAD)
Headers shown with no body
```

**Comparison:** MATCH - Both correctly send HEAD request

---

### Test 7: Explicit OPTIONS Method
**Command:** `http OPTIONS http://localhost:8888/anything`
**http Result:**
```
Status: 200 OK
Allow header present with supported methods
Verbose output shows: OPTIONS /anything HTTP/1.1
```

**spie Result:**
```
Status: 200 OK
Allow header present with supported methods
```

**Comparison:** MATCH - Both correctly send OPTIONS request

---

### Test 8: Default Method Without Data (with --ignore-stdin)
**Command:** `http --ignore-stdin http://localhost:8888/anything`
**http Result:**
```
method: "GET"
```

**spie Result:**
```
method: "GET"
```

**Comparison:** MATCH - Both default to GET when no data supplied

---

### Test 9: Default Method With Data Field
**Command:** `http --ignore-stdin http://localhost:8888/anything name=John`
**http Result:**
```
method: "POST"
```

**spie Result:**
```
method: "POST"
```

**Comparison:** MATCH - Both default to POST when data field is supplied

---

### Test 10: Default Method With Query Parameters
**Command:** `http --ignore-stdin http://localhost:8888/anything search==test`
**http Result:**
```
method: "GET"
```

**spie Result:**
```
method: "GET"
```

**Comparison:** MATCH - Both stay with GET when only query parameters are supplied

---

### Test 11: Lowercase Method
**Command:** `http get http://localhost:8888/anything`
**http Result:**
```
method: "GET"
```

**spie Result:**
```
method: "GET"
```

**Comparison:** MATCH - Both handle lowercase method names correctly

---

### Test 12: Mixed Case Method
**Command:** `http Get http://localhost:8888/anything`
**http Result:**
```
method: "GET"
```

**spie Result:**
```
method: "GET"
```

**Comparison:** MATCH - Both handle mixed case method names correctly

---

### Test 13: Custom/Unsupported Method
**Command:** `http CUSTOM http://localhost:8888/anything`
**http Result:**
```
HTTP Status: 405 Method Not Allowed
HTML error response from server
```

**spie Result:**
```
HTTP/1.1 405
Allow header showing permitted methods
HTML error response from server
```

**Comparison:** MATCH - Both attempt to send custom method and server rejects it appropriately

---

## Summary

### Overall Status: PASSED

All HTTP method handling tests passed. Both `http` and `spie` demonstrate:
- Correct handling of all standard HTTP methods (GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS)
- Case-insensitive method names (GET, get, Get all work)
- Proper smart defaults:
  - GET when no data/stdin is present
  - POST when data fields are provided
  - GET preserved when only query parameters are present
- Consistent behavior with custom/unsupported methods (server rejects them)

### Deviations Found

None - `http` and `spie` behave identically for all method-argument test cases.

### Notes

1. **stdin handling:** The tests used `--ignore-stdin` for `http` to eliminate stdin ambiguity. Without this flag, `http` appears to treat stdin as potential data even when empty, defaulting to POST. This is expected behavior per httpie documentation.

2. **Output differences:** While both tools handle methods identically, there are cosmetic differences in output formatting:
   - `http` shows request line with method (e.g., `GET /get HTTP/1.1`)
   - `spie` shows status line first (e.g., `HTTP/1.1 200`)
   - These are output formatting choices, not method handling differences

3. **Method case normalization:** Both tools normalize methods to uppercase in the actual HTTP request, regardless of input case.

4. **User-Agent differences:** The tools report different User-Agent headers, but this doesn't affect method handling.

## Status

**PASSED** - All method argument features work identically between `http` and `spie`.
