# Test Report: body-flag

**Feature:** `--body, -b` - Print only response body (shortcut for --print=b)

**Test Date:** 2025-11-01

## Feature Description

The `--body` flag (shorthand `-b`) is used to print only the response body, excluding headers and metadata. This is equivalent to using `--print=b`.

## Test Results

### Reference Implementation (http)

**Command:** `http --body GET localhost:8888/json`

**Output:**
```json
{
  "slideshow": {
    "author": "Yours Truly",
    "date": "date of publication",
    "slides": [
      {
        "title": "Wake up to WonderWidgets!",
        "type": "all"
      },
      {
        "items": [
          "Why <em>WonderWidgets</em> are great",
          "Who <em>buys</em> WonderWidgets"
        ],
        "title": "Overview",
        "type": "all"
      }
    ],
    "title": "Sample Slide Show"
  }
}
```

### Implementation Under Test (spie)

**Command:** `spie GET localhost:8888/json`

**Output:**
```
HTTP/1.1 200
Content-Length: 429
Access-Control-Allow-Credentials: true
Server: gunicorn/19.9.0
Connection: keep-alive
Content-Type: application/json
Date: Sat, 01 Nov 2025 17:30:58 GMT
Access-Control-Allow-Origin: *

{
  "slideshow": {
    "author": "Yours Truly",
    "date": "date of publication",
    "slides": [
      {
        "title": "Wake up to WonderWidgets!",
        "type": "all"
      },
      {
        "items": [
          "Why <em>WonderWidgets</em> are great",
          "Who <em>buys</em> WonderWidgets"
        ],
        "title": "Overview",
        "type": "all"
      }
    ],
    "title": "Sample Slide Show"
  }
}
```

**Note:** spie prints response headers by default and lacks the `--body` flag and `--print` option entirely.

## Comparison

| Aspect | http | spie |
|--------|------|------|
| Flag support | ✅ `--body, -b` | ❌ Not implemented |
| Default behavior | Shows both headers and body | Shows headers and body |
| Body-only output | Can be achieved with `--body` | Not possible |
| Shorthand | `-b` works | N/A |
| Equivalent via --print | `--print=b` works | `--print` not implemented |

## Deviation

**Type:** Feature not implemented

**Severity:** Medium

**Description:** spie does not support the `--body` flag or the `--print` option for controlling output format. This means users cannot suppress response headers and print only the body, which is a common use case for processing JSON responses.

## Test Verdict

**Status:** ❌ FAILED

spie does not implement the `--body` flag or any mechanism to suppress response headers. This is a feature gap that affects output control capabilities.

## Related Tests

- `--headers, -h` - Should print only response headers
- `--meta, -m` - Should print only metadata
- `--print, -p` - Master control for output parts
- `--verbose, -v` - Verbose output with multiple levels
