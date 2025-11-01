# Feature: request-item-headers (Request Items: Headers)

**Slug:** request-item-headers

**Description:** Headers with ':' separator (e.g., Referer:https://httpie.io). Request headers are specified as header-name:value pairs, where the colon (`:`) is used to distinguish header items from other request item types.

## Test Plan

This test verifies that both `http` and `spie` correctly handle header specification using the `:` separator:

1. **Simple Headers**: Test basic header specification with single-word values
2. **Multiple Headers**: Test multiple headers in a single request
3. **Headers with Special Characters**: Test headers with tokens, Bearer tokens, etc.
4. **Header Override**: Test overriding default headers
5. **Empty Header Values**: Test headers with empty values
6. **Headers with Colons in Values**: Test values that contain colons (timestamps, URLs)
7. **Header Case Sensitivity**: Test how duplicate headers with different cases are handled
8. **Standard Headers**: Test setting standard HTTP headers like Content-Type
9. **Many Headers**: Test requests with multiple custom headers

**Test Endpoint:** http://localhost:8888/anything (echoes back request headers)

### Commands Tested

- `http --ignore-stdin http://localhost:8888/anything Referer:https://httpie.io`
- `http --ignore-stdin http://localhost:8888/anything Referer:https://httpie.io X-Custom-Header:TestValue`
- `http --ignore-stdin http://localhost:8888/anything "Authorization:Bearer token123"`
- `http --ignore-stdin http://localhost:8888/anything Accept:application/json`
- `http --ignore-stdin http://localhost:8888/anything "X-Empty:"`
- `http --ignore-stdin http://localhost:8888/anything "Time:12:30:45"`
- `http --ignore-stdin http://localhost:8888/anything "x-test:value1" "X-Test:value2"`
- `http --ignore-stdin POST http://localhost:8888/anything "Content-Type:application/xml"`
- Multiple custom headers test

And equivalent tests with `spie`.

## Expected Behavior

According to HTTPie documentation:
- Headers are specified with the `name:value` syntax
- The first colon separates the header name from the value
- Subsequent colons are part of the header value (e.g., for timestamps, URLs)
- Header names are normalized to standard HTTP header casing by the server
- Multiple headers with the same name (different cases) may be combined
- Empty values are allowed and result in empty header values

## Test Results

### Test 1: Simple Header
**Command:** `http --ignore-stdin http://localhost:8888/anything Referer:https://httpie.io`

**http Result:**
```
Headers include:
  "Referer": "https://httpie.io"
Status: 200 OK
```

**spie Result:**
```
Headers include:
  "Referer": "https://httpie.io"
Status: 200 OK
```

**Comparison:** MATCH - Both correctly send the Referer header

---

### Test 2: Multiple Headers
**Command:** `http --ignore-stdin http://localhost:8888/anything Referer:https://httpie.io X-Custom-Header:TestValue`

**http Result:**
```
Headers include:
  "Referer": "https://httpie.io",
  "X-Custom-Header": "TestValue"
Status: 200 OK
```

**spie Result:**
```
Headers include:
  "Referer": "https://httpie.io",
  "X-Custom-Header": "TestValue"
Status: 200 OK
```

**Comparison:** MATCH - Both correctly send multiple headers

---

### Test 3: Header with Special Characters (Bearer Token)
**Command:** `http --ignore-stdin http://localhost:8888/anything "Authorization:Bearer token123"`

**http Result:**
```
Headers include:
  "Authorization": "Bearer token123"
Status: 200 OK
```

**spie Result:**
```
Headers include:
  "Authorization": "Bearer token123"
Status: 200 OK
```

**Comparison:** MATCH - Both correctly handle authorization headers with bearer tokens

---

### Test 4: Header Override (Accept)
**Command:** `http --ignore-stdin http://localhost:8888/anything Accept:application/json`

**http Result:**
```
Headers include:
  "Accept": "application/json"
Status: 200 OK
```

**spie Result:**
```
Headers include:
  "Accept": "application/json"
Status: 200 OK
```

**Comparison:** MATCH - Both correctly override the default Accept header

---

### Test 5: Header with Empty Value
**Command:** `http --ignore-stdin http://localhost:8888/anything "X-Empty:"`

**http Result:**
```
Headers: X-Empty header is not present (empty values are omitted by http)
Status: 200 OK
```

**spie Result:**
```
Headers: X-Empty header is not present (empty values are omitted by spie)
Status: 200 OK
```

**Comparison:** MATCH - Both omit headers with empty values

---

### Test 6: Header with Colon in Value
**Command:** `http --ignore-stdin http://localhost:8888/anything "Time:12:30:45"`

**http Result:**
```
Headers include:
  "Time": "12:30:45"
Status: 200 OK
```

**spie Result:**
```
Headers include:
  "Time": "12:30:45"
Status: 200 OK
```

**Comparison:** MATCH - Both correctly handle colons in header values (after the separator)

---

### Test 7: Header Case Sensitivity
**Command:** `http --ignore-stdin http://localhost:8888/anything "x-test:value1" "X-Test:value2"`

**http Result:**
```
Headers include:
  "X-Test": "value1,value2" (combined by server)
Status: 200 OK
```

**spie Result:**
```
Headers include:
  "X-Test": "value1,value2" (combined by server)
Status: 200 OK
```

**Comparison:** MATCH - Both correctly send both values; server combines them

---

### Test 8: Standard Header (Content-Type)
**Command:** `http --ignore-stdin POST http://localhost:8888/anything "Content-Type:application/xml"`

**http Result:**
```
Headers include:
  "Content-Type": "application/xml"
Status: 200 OK
```

**spie Result:**
```
Headers include:
  "Content-Type": "application/xml"
Status: 200 OK
```

**Comparison:** MATCH - Both correctly set custom Content-Type header

---

### Test 9: Multiple Custom Headers
**Command:** `http --ignore-stdin http://localhost:8888/anything X-Header-1:value1 X-Header-2:value2 X-Header-3:value3 X-Header-4:value4 X-Header-5:value5`

**http Result:**
```
Headers include:
  "X-Header-1": "value1",
  "X-Header-2": "value2",
  "X-Header-3": "value3",
  "X-Header-4": "value4",
  "X-Header-5": "value5"
Status: 200 OK
```

**spie Result:**
```
Headers include:
  "X-Header-1": "value1",
  "X-Header-2": "value2",
  "X-Header-3": "value3",
  "X-Header-4": "value4",
  "X-Header-5": "value5"
Status: 200 OK
```

**Comparison:** MATCH - Both correctly handle multiple headers

---

## Summary

### Overall Status: PASSED

All request-item-headers tests passed. Both `http` and `spie` demonstrate:
- Correct parsing of the `:` separator for header items
- Proper handling of header names and values
- Support for values containing colons (timestamps, URLs, etc.)
- Case-insensitive header name handling (normalized by HTTP)
- Correct override of default headers
- Support for multiple headers in a single request
- Proper omission of headers with empty values

### Deviations Found

None - `http` and `spie` behave identically for all request-item-headers test cases.

### Notes

1. **Header Parsing**: Both tools parse headers as `name:value` pairs where the first colon is the separator and subsequent colons are part of the value. This allows for timestamps, URLs, and other values containing colons.

2. **Header Normalization**: HTTP headers are case-insensitive in transmission. Both tools preserve the specified case in the header name, and servers normalize them as needed.

3. **Empty Values**: Both tools omit headers with empty values (e.g., `X-Header:`). This is standard HTTP behavior.

4. **Multiple Headers with Same Name**: When the same header is specified multiple times (even with different cases), servers combine them with commas as the separator (standard HTTP behavior).

5. **User-Agent Differences**: The tools report different User-Agent headers, but this doesn't affect header specification functionality.

## Status

**PASSED** - All request-item-headers features work identically between `http` and `spie`.
