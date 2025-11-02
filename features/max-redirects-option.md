# Feature: --max-redirects Option

**Slug:** `max-redirects-option`

**Description:** Limit the maximum number of redirects to follow (default 30 in http). Works in conjunction with redirect following.

**HTTPie Documentation:**
- http: `--max-redirects MAX_REDIRECTS` - By default, requests have a limit of 30 redirects (works with --follow).
- spie: `--max-redirects N` - Limit redirect hops when following (implies --follow).

---

## Test Plan

Test the --max-redirects option with various scenarios:

1. **Normal case**: Set limit higher than actual redirects (should succeed)
2. **Limit exceeded**: Set limit lower than actual redirects (should error)
3. **Minimum limit**: Test with --max-redirects 1
4. **Zero limit**: Test with --max-redirects 0
5. **Default behavior**: Test without --max-redirects option
6. **Interaction with --follow**: Check if --max-redirects requires --follow flag

Test using httpbin endpoints:
- `/redirect/{n}` - Creates a chain of n redirects

---

## Expected Behavior (http baseline)

```bash
# Normal case: limit 5, actual redirects 3
$ http get http://localhost:8888/redirect/3 --follow --max-redirects 5
# Should follow all 3 redirects and show final response

# Limit exceeded: limit 2, actual redirects 5
$ http get http://localhost:8888/redirect/5 --follow --max-redirects 2
# Should error: "Too many redirects (--max-redirects=2)"
# Exit code: 6

# Without --follow flag
$ http get http://localhost:8888/redirect/3 --max-redirects 5
# Should NOT follow redirects (--max-redirects has no effect without --follow)
# Shows first redirect response only
```

Key characteristics:
- Requires --follow flag to take effect
- Default limit is 30 redirects
- Shows only final response (not intermediate redirects unless --all is used)
- Errors with exit code 6 when limit exceeded
- Accepts 0 as a valid value (but still follows redirects with --follow)

---

## http Results

### Test 1: Normal case (limit 5, actual 3)
```bash
$ http get http://localhost:8888/redirect/3 --follow --max-redirects 5
{
  "args": {},
  "headers": {
    "Accept": "application/json, */*;q=0.5",
    "Accept-Encoding": "gzip, deflate, zstd",
    "Connection": "keep-alive",
    "Host": "localhost:8888",
    "User-Agent": "HTTPie/3.2.4"
  },
  "origin": "192.168.65.1",
  "url": "http://localhost:8888/get"
}
```
Exit code: 0
Status: Success - followed all 3 redirects, showed final response only

### Test 2: Limit exceeded (limit 2, actual 5)
```bash
$ http get http://localhost:8888/redirect/5 --follow --max-redirects 2
http: error: Too many redirects (--max-redirects=2).
```
Exit code: 6
Status: Properly errored when limit exceeded

### Test 3: Minimum limit (1)
```bash
$ http get http://localhost:8888/redirect/3 --follow --max-redirects 1
http: error: Too many redirects (--max-redirects=1).
```
Exit code: 6
Status: Properly errored after 1 redirect

### Test 4: Zero limit
```bash
$ http get http://localhost:8888/redirect/3 --follow --max-redirects 0
{
  "args": {},
  "headers": {
    "Accept": "application/json, */*;q=0.5",
    "Accept-Encoding": "gzip, deflate, zstd",
    "Connection": "keep-alive",
    "Host": "localhost:8888",
    "User-Agent": "HTTPie/3.2.4"
  },
  "origin": "192.168.65.1",
  "url": "http://localhost:8888/get"
}
```
Exit code: 0
Status: Accepts 0 but still follows redirects (possibly a bug or special behavior)

### Test 5: Without --follow
```bash
$ http get http://localhost:8888/redirect/3 --max-redirects 5
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<title>Redirecting...</title>
<h1>Redirecting...</h1>
<p>You should be redirected automatically to target URL: <a href="/relative-redirect/2">/relative-redirect/2</a>.  If not click the link.
```
Exit code: 0
Status: Does not follow redirects without --follow flag (--max-redirects has no effect)

### Test 6: Default limit with 10 redirects
```bash
$ http get http://localhost:8888/redirect/10 --follow
{
  "args": {},
  "headers": {
    "Accept": "application/json, */*;q=0.5",
    "Accept-Encoding": "gzip, deflate, zstd",
    "Connection": "keep-alive",
    "Host": "localhost:8888",
    "User-Agent": "HTTPie/3.2.4"
  },
  "origin": "192.168.65.1",
  "url": "http://localhost:8888/get"
}
```
Exit code: 0
Status: Default limit (30) allows 10 redirects

---

## spie Results

### Test 1: Normal case (limit 5, actual 3)
```bash
$ spie --max-redirects 5 http://localhost:8888/redirect/3
HTTP/1.1 302 Found
Content-Type: text/html; charset=utf-8
Access-Control-Allow-Origin: *
Connection: keep-alive
Location: /relative-redirect/2
Content-Length: 247
Server: gunicorn/19.9.0
Date: Sun, 02 Nov 2025 05:13:04 GMT
Access-Control-Allow-Credentials: true

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<title>Redirecting...</title>
<h1>Redirecting...</h1>
<p>You should be redirected automatically to target URL: <a href="/relative-redirect/2">/relative-redirect/2</a>.  If not click the link.

HTTP/1.1 302 Found
Location: /relative-redirect/1
Server: gunicorn/19.9.0
Connection: keep-alive
Content-Type: text/html; charset=utf-8
Date: Sun, 02 Nov 2025 05:13:04 GMT
Access-Control-Allow-Credentials: true
Access-Control-Allow-Origin: *
Content-Length: 0

HTTP/1.1 302 Found
Date: Sun, 02 Nov 2025 05:13:04 GMT
Server: gunicorn/19.9.0
Content-Type: text/html; charset=utf-8
Access-Control-Allow-Credentials: true
Connection: keep-alive
Content-Length: 0
Location: /get
Access-Control-Allow-Origin: *

HTTP/1.1 200 No Error
Date: Sun, 02 Nov 2025 05:13:04 GMT
Content-Type: application/json
Connection: keep-alive
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
Server: gunicorn/19.9.0
Content-Length: 353

{
  "args": {},
  "headers": {
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate",
    "Accept-Language": "en-US,en;q=0.9",
    "Connection": "keep-alive",
    "Host": "localhost:8888",
    "User-Agent": "spie (unknown version) CFNetwork/3860.100.1 Darwin/25.0.0"
  },
  "origin": "192.168.65.1",
  "url": "http://localhost:8888/get"
}
```
Exit code: 0
Status: Success - followed all 3 redirects, showed ALL intermediate responses (different from http)

### Test 2: Limit exceeded (limit 2, actual 5)
```bash
$ spie --max-redirects 2 http://localhost:8888/redirect/5
HTTP/1.1 302 Found
Date: Sun, 02 Nov 2025 05:15:09 GMT
Content-Type: text/html; charset=utf-8
Connection: keep-alive
Server: gunicorn/19.9.0
Location: /relative-redirect/4
Access-Control-Allow-Origin: *
Content-Length: 247
Access-Control-Allow-Credentials: true

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<title>Redirecting...</title>
<h1>Redirecting...</h1>
<p>You should be redirected automatically to target URL: <a href="/relative-redirect/4">/relative-redirect/4</a>.  If not click the link.

HTTP/1.1 302 Found
Connection: keep-alive
Date: Sun, 02 Nov 2025 05:15:09 GMT
Access-Control-Allow-Origin: *
Content-Type: text/html; charset=utf-8
Content-Length: 0
Server: gunicorn/19.9.0
Location: /relative-redirect/3
Access-Control-Allow-Credentials: true

HTTP/1.1 302 Found
Content-Length: 0
Location: /relative-redirect/2
Date: Sun, 02 Nov 2025 05:15:09 GMT
Content-Type: text/html; charset=utf-8
Access-Control-Allow-Origin: *
Connection: keep-alive
Access-Control-Allow-Credentials: true
Server: gunicorn/19.9.0
error: too many redirects (max 2)
```
Exit code: 6
Status: Properly errored when limit exceeded (same exit code as http)

### Test 3: Minimum limit (1)
```bash
$ spie --max-redirects 1 http://localhost:8888/redirect/3
HTTP/1.1 302 Found
Access-Control-Allow-Credentials: true
Location: /relative-redirect/2
Connection: keep-alive
Date: Sun, 02 Nov 2025 05:17:43 GMT
Content-Type: text/html; charset=utf-8
Server: gunicorn/19.9.0
Content-Length: 247
Access-Control-Allow-Origin: *

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<title>Redirecting...</title>
<h1>Redirecting...</h1>
<p>You should be redirected automatically to target URL: <a href="/relative-redirect/2">/relative-redirect/2</a>.  If not click the link.

HTTP/1.1 302 Found
Content-Length: 0
Location: /relative-redirect/1
Content-Type: text/html; charset=utf-8
Date: Sun, 02 Nov 2025 05:17:43 GMT
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
Server: gunicorn/19.9.0
Connection: keep-alive
error: too many redirects (max 1)
```
Exit code: 6
Status: Properly errored after 1 redirect

### Test 4: Zero limit
```bash
$ spie --max-redirects 0 http://localhost:8888/redirect/3
error: invalid max redirects value '0'
```
Exit code: 64
Status: REJECTS zero as invalid (different from http which accepts it)

### Test 5: Without --max-redirects
```bash
$ spie http://localhost:8888/redirect/3
HTTP/1.1 302 Found
Access-Control-Allow-Origin: *
Server: gunicorn/19.9.0
Content-Type: text/html; charset=utf-8
Content-Length: 247
Connection: keep-alive
Date: Sun, 02 Nov 2025 05:17:38 GMT
Access-Control-Allow-Credentials: true
Location: /relative-redirect/2

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<title>Redirecting...</title>
<h1>Redirecting...</h1>
<p>You should be redirected automatically to target URL: <a href="/relative-redirect/2">/relative-redirect/2</a>.  If not click the link.
```
Exit code: 0
Status: Does NOT follow redirects by default (consistent with no --follow flag)

### Test 6: Explicit limit with 10 redirects
```bash
$ spie --max-redirects 30 http://localhost:8888/redirect/10
[...intermediate responses...]
{
  "args": {},
  "headers": {
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate",
    "Accept-Language": "en-US,en;q=0.9",
    "Connection": "keep-alive",
    "Host": "localhost:8888",
    "User-Agent": "spie (unknown version) CFNetwork/3860.100.1 Darwin/25.0.0"
  },
  "origin": "192.168.65.1",
  "url": "http://localhost:8888/get"
}
```
Exit code: 0
Status: Successfully follows 10 redirects with limit of 30

---

## Comparison

### Similarities
1. Both properly enforce the redirect limit
2. Both error with exit code 6 when limit is exceeded
3. Both error with similar messages ("Too many redirects" vs "too many redirects")
4. Both handle --max-redirects 1 correctly

### Differences

| Aspect | http | spie |
|--------|------|------|
| **Requires --follow** | Yes, --max-redirects has no effect without --follow | No, --max-redirects implies --follow |
| **Output** | Shows only final response | Shows ALL intermediate responses |
| **Zero limit** | Accepts 0 (but still follows redirects) | Rejects 0 as invalid |
| **Default behavior** | Doesn't follow without --follow | Doesn't follow without --max-redirects |
| **Argument parsing** | Can appear anywhere in command | Must appear before URL (otherwise parsed as request item) |

---

## Issues Found

### Issue 1: Different behavior with --max-redirects 0

**http behavior:**
```bash
$ http get http://localhost:8888/redirect/3 --follow --max-redirects 0
# Returns final response (follows all redirects despite 0 limit)
```

**spie behavior:**
```bash
$ spie --max-redirects 0 http://localhost:8888/redirect/3
error: invalid max redirects value '0'
```

**Impact:** Medium - spie rejects 0 as invalid while http accepts it (though http's behavior with 0 is questionable). This is actually more correct behavior from spie.

### Issue 2: --max-redirects implies --follow in spie but not in http

**http behavior:**
- Requires explicit --follow flag for --max-redirects to take effect
- Documentation: "works with --follow"

**spie behavior:**
- --max-redirects automatically enables redirect following
- Documentation: "implies --follow"

**Impact:** Medium - This is a behavioral difference but spie's documentation is accurate about this. The behavior is more convenient (don't need both flags) but differs from http.

### Issue 3: Intermediate responses shown vs hidden

**http behavior:**
- Shows only final response by default
- Use --all to see intermediate responses

**spie behavior:**
- Always shows ALL intermediate responses when following redirects
- No option to hide them

**Impact:** High - Output is significantly different. Users expecting http-like behavior will see much more verbose output.

### Issue 4: Argument parsing - options after URL treated as request items

**spie behavior:**
```bash
$ spie http://localhost:8888/redirect/3 --max-redirects 5
error: invalid request item '--max-redirects'
```

Must use:
```bash
$ spie --max-redirects 5 http://localhost:8888/redirect/3
```

**Impact:** Medium - This is inconsistent with http's flexible argument parsing.

---

## Status

**FAILED** - Multiple behavioral differences found:
1. --max-redirects 0 handling differs
2. Automatically implies --follow (different from http)
3. Shows all intermediate responses (not just final)
4. Strict argument order (options must come before URL)

While the core functionality (enforcing redirect limits) works correctly, the behavior differs significantly from http in several ways that affect user experience and compatibility.
