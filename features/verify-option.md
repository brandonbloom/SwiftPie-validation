# Feature Test: verify-option

**Feature Name:** SSL Certificate Verification (--verify flag)
**Slug:** verify-option
**Category:** SSL
**Status:** Failed

## Feature Description

Controls SSL certificate verification when making HTTPS requests.

### HTTPie (`http`) Behavior
- Flag: `--verify VERIFY`
- Options:
  - `yes` or `true` (default): Verify SSL certificates
  - `no` or `false`: Skip certificate verification
  - Path to CA bundle file: Use custom CA certificate for verification
- Environment variable support: `REQUESTS_CA_BUNDLE`

### SwiftPie (`spie`) Behavior
- Flag: `--verify [BOOL]`
- Options:
  - `true` (default): Enable TLS verification
  - `false`, `no`, `0`, `yes`: Disable/enable TLS verification
- Path values are NOT supported (error: "invalid verify value")
- Environment variable support: Not documented/tested

## Test Plan

### Test 1: HTTPS request with valid certificate (default behavior)
**Goal:** Verify both clients can make HTTPS requests to well-known domains with valid certificates

**Commands:**
```bash
http GET https://httpbin.org/get
spie https://httpbin.org/get
```

**Expected:** Both should succeed with certificate verification enabled by default

### Test 2: HTTPS request with explicit verification enabled
**Goal:** Verify --verify=yes/true works correctly

**Commands:**
```bash
http --verify yes GET https://httpbin.org/get
http --verify true GET https://httpbin.org/get
spie --verify true https://httpbin.org/get
spie --verify yes https://httpbin.org/get
```

**Expected:** All should succeed with certificate verification enabled

### Test 3: HTTPS request with self-signed certificate (verification disabled)
**Goal:** Test that --verify=no/false skips certificate verification

**Commands:**
```bash
http --verify no GET https://self-signed.badssl.com/
http --verify false GET https://self-signed.badssl.com/
spie --verify no https://self-signed.badssl.com/
spie --verify false https://self-signed.badssl.com/
spie --verify 0 https://self-signed.badssl.com/
```

**Expected:** All should succeed despite the self-signed certificate

### Test 4: HTTPS request with self-signed certificate (verification enabled)
**Goal:** Verify that certificate verification catches invalid certificates

**Commands:**
```bash
http GET https://self-signed.badssl.com/
spie https://self-signed.badssl.com/
spie --verify true https://self-signed.badssl.com/
```

**Expected:** Both should fail with SSL verification error

### Test 5: Custom CA bundle path
**Goal:** Test custom CA bundle path support

**Commands:**
```bash
http --verify /invalid/path GET https://httpbin.org/get
spie --verify /invalid/path https://httpbin.org/get
```

**Expected:**
- `http`: Should attempt to use path and fail with file not found error
- `spie`: Should reject path value

---

## Test Results

### Test 1: HTTPS with valid certificate (default)

#### HTTPie
```bash
$ http GET https://httpbin.org/get
```

**Result:** SUCCESS
```json
{
  "args": {},
  "headers": {
    "Accept": "application/json, */*;q=0.5",
    "Accept-Encoding": "gzip, deflate, zstd",
    "Content-Type": "application/json",
    "Host": "httpbin.org",
    "User-Agent": "HTTPie/3.2.4",
    "X-Amzn-Trace-Id": "Root=1-6906e838-7c178ef77ca7b4693b11e137"
  },
  "origin": "50.47.107.184",
  "url": "https://httpbin.org/get"
}
```

#### SwiftPie
```bash
$ spie https://httpbin.org/get
```

**Result:** SUCCESS
```
HTTP/1.1 200 No Error
Access-Control-Allow-Origin: *
Content-Length: 412
Date: Sun, 02 Nov 2025 05:12:13 GMT
Content-Type: application/json
access-control-allow-credentials: true
Server: gunicorn/19.9.0

{
  "args": {},
  "headers": {
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate, br",
    "Accept-Language": "en-US,en;q=0.9",
    "Host": "httpbin.org",
    "Priority": "u=3",
    "User-Agent": "spie (unknown version) CFNetwork/3860.100.1 Darwin/25.0.0",
    "X-Amzn-Trace-Id": "Root=1-6906e82c-26b8eb715a2a59b92aab9ae0"
  },
  "origin": "50.47.107.184",
  "url": "https://httpbin.org/get"
}
```

**Verdict:** PASS - Both successfully verify and connect with valid certificates

---

### Test 2: HTTPS with explicit verification enabled

#### HTTPie (--verify yes)
```bash
$ http --verify yes GET https://httpbin.org/get
```

**Result:** SUCCESS
```json
{
  "args": {},
  "headers": {
    "Accept": "application/json, */*;q=0.5",
    "Accept-Encoding": "gzip, deflate, zstd",
    "Content-Type": "application/json",
    "Host": "httpbin.org",
    "User-Agent": "HTTPie/3.2.4",
    "X-Amzn-Trace-Id": "Root=1-6906e860-304397717f02f8f45a97104f"
  },
  "origin": "50.47.107.184",
  "url": "https://httpbin.org/get"
}
```

#### HTTPie (--verify true)
```bash
$ http --verify true GET https://httpbin.org/get
```

**Result:** SUCCESS
```json
{
  "args": {},
  "headers": {
    "Accept": "application/json, */*;q=0.5",
    "Accept-Encoding": "gzip, deflate, zstd",
    "Content-Type": "application/json",
    "Host": "httpbin.org",
    "User-Agent": "HTTPie/3.2.4",
    "X-Amzn-Trace-Id": "Root=1-6906e861-043e0c1218d9a03a77864387"
  },
  "origin": "50.47.107.184",
  "url": "https://httpbin.org/get"
}
```

#### SwiftPie (--verify true)
```bash
$ spie --verify true https://httpbin.org/get
```

**Result:** SUCCESS
```
HTTP/1.1 200 No Error
Server: gunicorn/19.9.0
Access-Control-Allow-Origin: *
Content-Type: application/json
Content-Length: 412
access-control-allow-credentials: true
Date: Sun, 02 Nov 2025 05:13:06 GMT

{
  "args": {},
  "headers": {
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate, br",
    "Accept-Language": "en-US,en;q=0.9",
    "Host": "httpbin.org",
    "Priority": "u=3",
    "User-Agent": "spie (unknown version) CFNetwork/3860.100.1 Darwin/25.0.0"
  },
  "origin": "50.47.107.184",
  "url": "https://httpbin.org/get"
}
```

#### SwiftPie (--verify yes)
```bash
$ spie --verify yes https://httpbin.org/get
```

**Result:** SUCCESS
```
HTTP/1.1 200 No Error
Content-Length: 412
Content-Type: application/json
access-control-allow-credentials: true
Date: Sun, 02 Nov 2025 05:13:48 GMT
Server: gunicorn/19.9.0
Access-Control-Allow-Origin: *

{
  "args": {},
  "headers": {
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate, br",
    "Accept-Language": "en-US,en;q=0.9",
    "Host": "httpbin.org",
    "Priority": "u=3",
    "User-Agent": "spie (unknown version) CFNetwork/3860.100.1 Darwin/25.0.0"
  },
  "origin": "50.47.107.184",
  "url": "https://httpbin.org/get"
}
```

**Verdict:** PASS - All value variations work correctly (yes, true accepted by both)

**Note:** `spie` accepts `yes` even though it's not documented in help text

---

### Test 3: HTTPS with verification disabled

#### HTTPie (--verify no)
```bash
$ http --verify no GET https://self-signed.badssl.com/
```

**Result:** SUCCESS
```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="shortcut icon" href="/icons/favicon-red.ico"/>
  <link rel="apple-touch-icon" href="/icons/icon-red.png"/>
  <title>self-signed.badssl.com</title>
  <link rel="stylesheet" href="/style.css">
  <style>body { background: red; }</style>
</head>
<body>
<div id="content">
  <h1 style="font-size: 12vw;">
    self-signed.<br>badssl.com
  </h1>
</div>
</body>
</html>
```

Exit code: 0

#### HTTPie (--verify false)
```bash
$ http --verify false GET https://self-signed.badssl.com/
```

**Result:** SUCCESS
```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>self-signed.badssl.com</title>
  <style>body { background: red; }</style>
</head>
<body>
<div id="content">
  <h1 style="font-size: 12vw;">
    self-signed.<br>badssl.com
  </h1>
</div>
</body>
</html>
```

Exit code: 0

#### SwiftPie (--verify no)
```bash
$ spie --verify no https://self-signed.badssl.com/
```

**Result:** SUCCESS
```
HTTP/1.1 200 No Error
Last-Modified: Tue, 28 Oct 2025 21:01:12 GMT
Etag: W/"69012f18-1f6"
Transfer-Encoding: Identity
Content-Type: text/html
Cache-Control: no-store
Date: Sun, 02 Nov 2025 05:12:43 GMT
Server: nginx/1.10.3 (Ubuntu)
Connection: keep-alive
Content-Encoding: gzip

<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>self-signed.badssl.com</title>
  <style>body { background: red; }</style>
</head>
<body>
<div id="content">
  <h1 style="font-size: 12vw;">
    self-signed.<br>badssl.com
  </h1>
</div>
</body>
</html>
```

Exit code: 0

#### SwiftPie (--verify false)
```bash
$ spie --verify false https://self-signed.badssl.com/
```

**Result:** SUCCESS
```
HTTP/1.1 200 No Error
Server: nginx/1.10.3 (Ubuntu)
Date: Sun, 02 Nov 2025 05:12:56 GMT
Transfer-Encoding: Identity
Connection: keep-alive
Content-Encoding: gzip
Etag: W/"69012f18-1f6"
Content-Type: text/html
Cache-Control: no-store
Last-Modified: Tue, 28 Oct 2025 21:01:12 GMT
```

Exit code: 0

#### SwiftPie (--verify 0)
```bash
$ spie --verify 0 https://self-signed.badssl.com/
```

**Result:** SUCCESS
```
HTTP/1.1 200 No Error
Content-Type: text/html
Content-Encoding: gzip
Transfer-Encoding: Identity
Etag: W/"69012f18-1f6"
Last-Modified: Tue, 28 Oct 2025 21:01:12 GMT
Server: nginx/1.10.3 (Ubuntu)
Date: Sun, 02 Nov 2025 05:12:57 GMT
Connection: keep-alive
Cache-Control: no-store
```

Exit code: 0

**Verdict:** PASS - All variations successfully bypass certificate verification

---

### Test 4: HTTPS with self-signed certificate (verification enabled)

#### HTTPie (default)
```bash
$ http GET https://self-signed.badssl.com/
```

**Result:** FAILURE
```
http: error: SSLError: HTTPSConnectionPool(host='self-signed.badssl.com', port=443):
Max retries exceeded with url: / (Caused by SSLError(SSLCertVerificationError(1,
'[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: self-signed certificate (_ssl.c:1077)')))
while doing a GET request to URL: https://self-signed.badssl.com/
```

Exit code: 1

#### SwiftPie (default)
```bash
$ spie https://self-signed.badssl.com/
```

**Result:** FAILURE
```
transport error: The certificate for this server is invalid. You might be connecting to a server
that is pretending to be "self-signed.badssl.com" which could put your confidential information at risk.
```

Exit code: 1

#### SwiftPie (--verify true)
```bash
$ spie --verify true https://self-signed.badssl.com/
```

**Result:** FAILURE
```
transport error: The certificate for this server is invalid. You might be connecting to a server
that is pretending to be "self-signed.badssl.com" which could put your confidential information at risk.
```

Exit code: 1

**Verdict:** PASS - Both correctly reject self-signed certificates when verification is enabled

---

### Test 5: Custom CA bundle path

#### HTTPie
```bash
$ http --verify invalid_path GET https://httpbin.org/get
```

**Result:** FAILURE
```
http: error: OSError: Could not find a suitable TLS CA certificate bundle, invalid path: invalid_path
```

Exit code: 1

**Behavior:** HTTPie accepts path values and attempts to use them as CA bundle files

#### SwiftPie
```bash
$ spie --verify /invalid/path https://httpbin.org/get
```

**Result:** FAILURE
```
error: invalid verify value '/invalid/path'
```

Exit code: 64

**Behavior:** SwiftPie rejects path values entirely - does NOT support custom CA bundles

**Verdict:** FAIL - Different behavior: HTTPie supports custom CA bundle paths, spie does not

---

## Summary

**Test Status:** Failed

**Core Functionality:** Both implementations correctly handle basic SSL/TLS certificate verification with these common operations:
- Default verification enabled ✓
- Explicit enable with `--verify true` ✓
- Explicit disable with `--verify no` or `--verify false` ✓
- Both correctly reject invalid certificates when verification enabled ✓
- Both correctly accept invalid certificates when verification disabled ✓

**Issues Found:**

1. **Missing custom CA bundle support**: HTTPie supports `--verify /path/to/ca-bundle.crt` for custom certificate authorities, but spie rejects path values with "invalid verify value" error. This is a significant feature gap for environments requiring custom CAs (corporate networks, internal services, development environments).

2. **Undocumented value accepted**: spie accepts `--verify yes` even though it's not documented in help text (only documents `true/false/no/0`). This is actually good for compatibility but should be documented.

**Compatibility:** Partial

- Basic boolean verification control: Compatible
- Custom CA bundle paths: NOT compatible (HTTPie feature, spie missing)

**Recommendations:**

1. Implement custom CA bundle path support in spie to match HTTPie's `--verify /path/to/ca-bundle.crt` functionality
2. Document that spie accepts `yes` as a value for `--verify` (or remove support if unintended)
3. Consider supporting `REQUESTS_CA_BUNDLE` environment variable for compatibility

**Impact:**

- **High**: Custom CA bundle support is critical for enterprise/corporate environments with internal certificate authorities
- **Medium**: Affects development workflows using self-signed certificates with specific CA validation
- **Low**: Basic verification on/off toggle works identically between implementations
