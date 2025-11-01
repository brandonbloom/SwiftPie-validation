# HTTPie Feature Test: --all Flag

## Feature Description
The `--all` flag shows intermediary requests/responses in addition to the final request/response. This is useful for:
- Following redirects (301, 302, 303, 307, 308) with `--follow` to see all intermediary redirect responses
- Digest authentication to show the initial unauthorized request and the subsequent authorized request
- Other intermediary HTTP transactions

## Specification (from `http --help`)
```
--all
      By default, only the final request/response is shown. Use this flag to show
      any intermediary requests/responses as well. Intermediary requests include
      followed redirects (with --follow), the first unauthorized request when
      Digest auth is used (--auth=digest), etc.
```

## Test Cases

### Test 1: Redirect Chain with --all and --follow
**Scenario**: Follow a redirect from /redirect-to?url=/get to /get, showing all intermediary responses

**HTTP Command**:
```bash
http --all --follow --print=h --ignore-stdin 'http://localhost:8888/redirect-to?url=/get'
```

**HTTP Output**:
Shows BOTH the intermediate 302 redirect response AND the final 200 OK response:
```
HTTP/1.1 302 FOUND
Server: gunicorn/19.9.0
...
Location: /get
...

HTTP/1.1 200 OK
Server: gunicorn/19.9.0
...
```

**SPIE Command**:
```bash
spie --all --follow --print=h --ignore-stdin 'http://localhost:8888/redirect-to?url=/get'
```

**SPIE Output**:
```
error: unknown option '--all'
```

### Test 2: Redirect Chain WITHOUT --all (baseline)
**Scenario**: Follow a redirect WITHOUT --all flag, should only show final response

**HTTP Command**:
```bash
http --follow --print=h --ignore-stdin 'http://localhost:8888/redirect-to?url=/get'
```

**HTTP Output**:
Shows ONLY the final 200 OK response (intermediate 302 is hidden):
```
HTTP/1.1 200 OK
Server: gunicorn/19.9.0
...
```

## Test Results

### Comparison Table

| Aspect | http | spie | Match |
|--------|------|------|-------|
| Flag recognized | ✓ Yes | ✗ No | ✗ FAILED |
| Shows intermediary responses | ✓ Yes | N/A | ✗ FAILED |
| Works with --follow | ✓ Yes | N/A | ✗ FAILED |
| Functional parity | ✓ Full | ✗ Not implemented | ✗ FAILED |

## Deviations Found

### Critical Issue: --all flag not implemented in spie
- **Severity**: FAILURE
- **Type**: Missing feature
- **Impact**: Users cannot view intermediary HTTP transactions (redirects, auth challenges, etc.)
- **spie Behavior**: Rejects `--all` flag with error: `error: unknown option '--all'`
- **http Behavior**: Accepts `--all` flag and displays all intermediary requests/responses

### Root Cause
The `--all` flag is completely absent from spie's command-line interface. When combined with `--follow`, it should show all redirect responses in sequence, but spie's help output shows no such option exists.

## Test Environment
- **HTTPie Version**: 3.2.4
- **spie Location**: /Users/bbloom/Projects/httpie-delta/bin/spie
- **Test Server**: httpbin (localhost:8888)
- **Test Date**: 2025-11-01
- **OS**: macOS (Darwin 25.0.0)

## Summary
The `--all` flag is **NOT IMPLEMENTED** in spie. This is a complete missing feature that prevents users from inspecting intermediary HTTP transactions.

**Status**: FAILED ✗
