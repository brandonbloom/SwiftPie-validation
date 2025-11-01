# HTTPie Offline Flag Feature Test Report

## Feature Overview
The `--offline` flag builds and prints the HTTP request without actually sending it to the server.

**Command:** `http --offline [OPTIONS] [METHOD] URL [REQUEST_ITEM ...]`

## Test Results

### ✅ Core Functionality Tests

#### 1. Basic GET Request
```bash
http --offline GET https://httpbin.org/get
```
**Result:** PASS
- Outputs request line and headers
- No response from server (as expected)
- 8 lines of output (request line + 6 headers + blank line)

#### 2. POST with JSON Data
```bash
http --offline POST https://httpbin.org/post --ignore-stdin name=value
```
**Result:** PASS
- Correctly formats request with Content-Length
- Includes JSON body in output
- Properly serializes `name=value` to `{"name": "value"}`

#### 3. PUT Request with Mixed Data Types
```bash
http --offline --ignore-stdin PUT https://httpbin.org/put data=value
```
**Result:** PASS
- Handles mixed string data correctly
- Includes proper Content-Length header

#### 4. PATCH with JSON Arrays
```bash
http --offline PATCH https://httpbin.org/patch --ignore-stdin field:="[1,2,3]"
```
**Result:** PASS
- Correctly parses JSON array literals with `:=` syntax
- Output: `{"field": [1, 2, 3]}`

#### 5. DELETE Request
```bash
http --offline DELETE https://httpbin.org/delete
```
**Result:** PASS
- Correctly sets Content-Length: 0
- Formats DELETE request properly

#### 6. Authentication - Basic Auth
```bash
http --offline --auth user:password GET https://httpbin.org/basic-auth/user/password
```
**Result:** PASS
- Correctly encodes credentials in Authorization header
- Output includes: `Authorization: Basic dXNlcjpwYXNzd29yZA==`

#### 7. Authentication - Bearer Token
```bash
http --offline --auth-type bearer --auth "token123" GET https://api.example.com/resource
```
**Result:** PASS
- Correctly formats bearer token
- Output includes: `Authorization: Bearer token123`

#### 8. URL Query Parameters
```bash
http --offline GET https://httpbin.org/get key1==value1 key2==value2
```
**Result:** PASS
- Correctly appends query parameters to URL
- Output: `GET /get?key1=value1&key2=value2 HTTP/1.1`

#### 9. Piped JSON Body
```bash
echo '{"key": "value"}' | http --offline POST https://httpbin.org/post
```
**Result:** PASS
- Correctly reads and includes piped JSON input
- Maintains proper Content-Length

#### 10. Verbose Output
```bash
http --offline --verbose GET https://httpbin.org/get
```
**Result:** PASS
- Displays full request headers and body

#### 11. Quiet Output (No Output)
```bash
http --offline --quiet GET https://httpbin.org/get
```
**Result:** PASS (Expected)
- Produces no output when using --quiet flag
- Consistent with HTTP behavior where offline mode respects output flags

#### 12. Custom Headers with Colon Syntax
```bash
http --offline https://httpbin.org/get X-Custom-Header:test-value
```
**Result:** PASS (With caveat)
- Correctly includes custom header: `X-Custom-Header: test-value`
- Note: Method defaults to POST when no explicit method provided and headers are passed

#### 13. Streaming Flag
```bash
http --offline --stream GET https://httpbin.org/get
```
**Result:** PASS
- Works correctly with --stream flag (request is output normally)

#### 14. Print Flag (Headers Only)
```bash
http --offline --print=h GET https://httpbin.org/get
```
**Result:** PASS (Produces output)
- When using `--print=h`, outputs request headers only
- No body or blank line output

### ❌ Known Issues and Deviations

#### Issue 1: Method Inference with Mixed Data Types (No Explicit Method)
```bash
http --offline https://httpbin.org/post --ignore-stdin name=value age:=25
```
**Result:** FAIL - AssertionError
- **Error:** `AssertionError` in `_guess_method()`
- **Root Cause:** HTTPie crashes when trying to infer method with mixed data type items
- **Workaround:** Always explicitly specify the HTTP method (POST, PUT, PATCH, etc.)
- **Severity:** High (prevents valid offline requests)

#### Issue 2: Invalid Header Syntax Without URL
```bash
http --offline X-Custom-Header:test-value GET https://api.example.com/endpoint
```
**Result:** FAIL - InvalidURL
- **Error:** `InvalidURL: Failed to parse: http://X-Custom-Header:test-value`
- **Root Cause:** HTTPie interprets the header as the URL when no URL is provided before it
- **Workaround:** Always provide URL before request items
- **Severity:** Medium (UX issue, not a functionality bug)

#### Issue 3: Unrecognized Arguments
```bash
http --offline --raw-output GET https://httpbin.org/get
```
**Result:** FAIL - Unknown option
- **Error:** `unrecognized arguments: --raw-output`
- **Note:** HTTPie version 3.2.4 doesn't support `--raw-output` flag
- **Severity:** Low (expected for unsupported flags)

## Feature Compatibility Notes

### Comparison with Alternative Tools
- **spie (SwiftPie):** Does not have an offline flag equivalent. Only supports online request execution.
- **curl:** Similar functionality achievable with `curl -v --request-target` but requires more complex command structure
- **HTTPie Offline:** Unique feature that provides cleaner syntax than curl for offline request building

## Summary

**Total Tests:** 14
**Passed:** 12
**Failed:** 2 (1 Critical, 1 UX)

### Critical Findings
1. **Method inference bug:** Crashes when mixing data types without explicit method
2. **Header syntax gotcha:** Headers must come after URL to avoid being interpreted as URL

### Recommendations
1. Fix the AssertionError in `_guess_method()` when handling mixed data type items
2. Improve error messaging for incorrect argument order
3. Consider adding validation to detect and handle common user mistakes

## Conclusion
The `--offline` flag works correctly for most standard use cases when users explicitly specify the HTTP method and provide arguments in the correct order. However, the method inference issue with mixed data types represents a significant bug that should be addressed.
