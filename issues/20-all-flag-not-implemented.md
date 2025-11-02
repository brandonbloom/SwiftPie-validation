# Issue: --all flag not implemented in spie

## Summary
The HTTPie `--all` flag is not implemented in spie. This flag shows intermediary requests/responses (e.g., redirect responses when using `--follow`, or initial unauthorized request for digest auth).

## Expected Behavior (http)
```bash
$ http --all --follow --print=h 'http://localhost:8888/redirect-to?url=/get'
HTTP/1.1 302 FOUND
Location: /get
...

HTTP/1.1 200 OK
...
```

Without `--all`, only the final response is shown.

## Actual Behavior (spie)
```bash
$ spie --all --follow --print=h 'http://localhost:8888/redirect-to?url=/get'
error: unknown option '--all'
```

## Impact
- Users cannot view intermediary HTTP transactions
- Missing feature breaks parity with HTTPie
- Affects debugging of redirect chains and authentication flows

## Test Reference
See: `features/all-flag.md`

## Severity
HIGH - Core feature missing
