# Follow Flag Feature Test (`--follow`, `-F`)

## Feature Description
The `--follow` flag tells HTTPie to follow 30x (3xx) HTTP Location redirects automatically. By default, HTTPie shows the redirect response without following it.

## Test Status
**Status:** FAILED - Feature partially implemented in spie with different behavior

## HTTPie Official Behavior

### Test 1: Basic Redirect Following
**Test:** Follow a single HTTP redirect
```bash
http --follow http://httpbin.org/redirect/1
```
**Expected:** Should follow the redirect and show final response (status 200)
**Result:**
```
HTTP/1.1 200 OK
...
```

### Test 2: Multiple Redirect Chain (3 redirects)
**Test:** Follow a chain of 3 redirects
```bash
http --follow http://httpbin.org/redirect/3
```
**Expected:** Should follow all 3 redirects and show final response (status 200)

### Test 3: No Follow Flag (Default Behavior)
**Test:** Request URL with redirect but WITHOUT --follow flag
```bash
http http://httpbin.org/redirect/1
```
**Expected:** Should show redirect response (status 3xx) without following
**Result Status:** 302 or 301

### Test 4: Max Redirects Limit (Default 30)
**Test:** Follow redirect beyond max limit
```bash
http --follow --max-redirects=2 http://httpbin.org/redirect/5
```
**Expected:** Should stop at 2 redirects and show error or final redirect response

### Test 5: Short Form Flag (-F)
**Test:** Use short form of follow flag
```bash
http -F http://httpbin.org/redirect/1
```
**Expected:** Should work identically to --follow

### Test 6: Redirect to Different Host
**Test:** Follow redirect to different domain
```bash
http --follow http://httpbin.org/absolute-redirect/1
```
**Expected:** Should follow to new domain and show final response

## spie Implementation Status

**Feature Support:** NOT IMPLEMENTED

**Evidence:**
- `spie --help` does not list `--follow` or `-F` flag
- spie lacks redirect following capability in command-line interface

## Comparison Summary

| Aspect | http | spie |
|--------|------|------|
| --follow flag | ✓ Implemented | ✗ Not implemented |
| -F short form | ✓ Implemented | ✗ Not implemented |
| Max redirects control | ✓ Via --max-redirects | ✗ Not available |
| Default behavior | Shows redirect without following | N/A |

## Test Results

### http CLI Tests

#### Test 1: Basic Single Redirect with --follow
```bash
$ http --follow GET http://httpbin.org/redirect/1
HTTP/1.1 200 OK
```
**Result:** ✓ Followed redirect successfully - Final response is 200 OK

#### Test 2: No Follow (Default Behavior)
```bash
$ http GET http://httpbin.org/redirect/1
HTTP/1.1 302 FOUND
Location: /get
```
**Result:** ✓ Shows redirect response (302) with Location header - Does not follow

#### Test 3: Short Form (-F)
```bash
$ http -F GET http://httpbin.org/redirect/1
HTTP/1.1 200 OK
```
**Result:** ✓ Works identically to --follow - Final response is 200 OK

#### Test 4: Chain of Redirects (3 redirects)
```bash
$ http -F GET http://httpbin.org/redirect/3
HTTP/1.1 200 OK
```
**Result:** ✓ Followed all 3 redirects - Final response is 200 OK

### spie CLI Tests

#### Test 1: Attempt --follow flag
```bash
$ spie --follow http://httpbin.org/redirect/1
error: unknown option '--follow'
```
**Result:** ✗ Flag not recognized - Flag completely unsupported

#### Test 2: Default Behavior (Without flag support)
```bash
$ spie GET http://httpbin.org/redirect/1
HTTP/1.1 200 OK
```
**Result:** ⚠ **DIFFERENT BEHAVIOR** - spie automatically follows redirects by DEFAULT, unlike http

#### Test 3: Single Redirect Response
With httpbin, spie returns the final 200 OK response instead of the 302 redirect response that http would show without --follow.

## Key Findings

1. **Critical Behavior Difference:** spie AUTOMATICALLY follows redirects by default, while http requires the explicit `--follow` flag
2. **Missing CLI Flag:** The `--follow` / `-F` flags are not available in spie's command interface
3. **No Control Over Redirect Behavior:** Users cannot prevent redirect following in spie, unlike http
4. **Implicit vs Explicit:** http is explicit (requires flag), spie is implicit (always follows)
5. **Missing --max-redirects:** spie has no way to control redirect limits

## Blockers/Issues

- [x] spie missing `--follow` / `-F` flag (but feature works implicitly)
- [x] spie missing `--max-redirects` option for redirect control
- [x] Behavioral deviation: spie always follows, http doesn't by default
- [ ] Users cannot prevent redirect following in spie (behavior is forced)

## Status: FAILED

**Reason:** Significant behavioral deviation. While spie does follow redirects, it:
1. Does not expose `--follow` or `-F` command-line flags
2. Always follows redirects by default (cannot be disabled)
3. Lacks `--max-redirects` control option
4. Differs fundamentally from http's explicit opt-in model

**Feature Parity Gap:**
- http: Requires explicit `--follow` flag to follow redirects (default: doesn't follow)
- spie: Always follows redirects automatically (no option to disable)

**Recommendation:**
1. Add `--follow` / `-F` flags for API compatibility (even if default behavior stays)
2. Implement `--no-follow` or similar to prevent redirect following
3. Add `--max-redirects` option for redirect limit control
4. Consider changing default behavior to match http (require explicit flag)
