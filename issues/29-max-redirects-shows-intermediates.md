# Issue: spie shows all intermediate redirect responses instead of just final response

**Issue ID:** #29
**Feature Slug:** max-redirects-option
**Status:** Open

## Summary

When following redirects with `--max-redirects`, spie shows ALL intermediate redirect responses (with full headers and bodies) instead of just the final response like http does. This creates much more verbose output.

## Tested

**Command tested:**
```bash
spie --max-redirects 5 http://localhost:8888/redirect/3
```

## Expected

HTTPie shows only the final response when following redirects (unless --all is used):
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

Clean output showing only what you care about - the final destination.

## Actual

SpIE shows ALL intermediate responses (all 3 redirects plus final):
```bash
$ spie --max-redirects 5 http://localhost:8888/redirect/3
HTTP/1.1 302 Found
Content-Type: text/html; charset=utf-8
Access-Control-Allow-Origin: *
Connection: keep-alive
Location: /relative-redirect/2
Content-Length: 247
...
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<title>Redirecting...</title>
...

HTTP/1.1 302 Found
Location: /relative-redirect/1
...

HTTP/1.1 302 Found
Location: /get
...

HTTP/1.1 200 No Error
{
  "args": {},
  ...
}
```

Output is 4x longer with all intermediate redirect headers and bodies shown.

## The Problem

SpIE's behavior differs from HTTPie's default redirect handling:
- Users expect to see only the final response (the actual destination)
- Intermediate redirects are typically not useful and create noise
- No way to suppress intermediate responses (no equivalent to http's default behavior)
- This makes output much harder to read when following redirect chains

While http has `--all` to show intermediates when needed, spie doesn't have a flag to hide them.

## Impact

**Severity:** High

This significantly affects usability:
- Output is much more verbose than expected
- Harder to read and parse final response
- No way to achieve http's clean default behavior
- Scripts expecting http-like output will break
- Users must manually filter output to get final response

## Root Cause

SpIE appears to implement redirect following similar to http's `--all` behavior, always showing intermediate responses. It lacks:
1. Default behavior to hide intermediate redirects
2. Flag to control whether intermediate responses are shown
3. Equivalent to http's `--all` flag (or opposite: hide intermediates by default)

## Related Issues

- Issue #20: `--all` flag not implemented (though spie behaves like it's always on)
- This is related to the follow-flag feature differences

## Recommendation

Change default behavior to match http:
- Show only final response by default when following redirects
- Add a flag (like `--all`) to show intermediate responses when needed
- This would match user expectations and http compatibility

Alternative: Add a flag like `--no-intermediates` or `--final-only` to hide intermediate responses, though this is less compatible with http.
