# Issue: --timeout 0 rejected instead of meaning "no timeout"

**Issue ID:** #25
**Feature Slug:** timeout-option
**Status:** Open

## Summary

SpIE rejects `--timeout 0` as invalid, but HTTPie accepts it as meaning "no timeout limit" (infinite wait). This breaks compatibility for users who want to explicitly disable timeouts.

## Tested

**Command tested:**
```bash
spie --timeout 0 GET http://localhost:8888/delay/1
```

## Expected

HTTPie accepts `--timeout 0` to mean "no timeout limit":
```bash
http --timeout 0 GET http://localhost:8888/delay/1
```

This succeeds and waits indefinitely for the response. According to HTTPie documentation:
> "The default value is 0, i.e., there is no timeout limit."

## Actual

SpIE rejects the zero value:
```
error: invalid timeout value '0'
Exit code: 64
```

The request is not sent at all.

## The Problem

SpIE enforces that timeout must be a positive value and rejects zero. However, HTTPie documents and implements zero as meaning "no timeout limit". This is a breaking compatibility issue because:

1. Users cannot explicitly set "no timeout" using `--timeout 0`
2. Scripts that use `--timeout 0` will fail with SpIE
3. The behavior contradicts HTTPie's documented semantics

## Impact

**Severity:** High

This is a functional compatibility issue. Users who want to:
- Explicitly disable timeouts (vs relying on default)
- Use zero timeout in configuration or scripts
- Match HTTPie's documented behavior

will find their commands fail with SpIE.

## Root Cause

SpIE's timeout validation requires a positive value (> 0), while HTTPie treats zero as a special case meaning "infinite timeout". The validation logic needs to accept zero and handle it specially.

## Recommendation

Update SpIE's timeout handling to match HTTPie:
1. Accept `--timeout 0` without error
2. Treat zero as "no timeout limit" (infinite wait)
3. Document this behavior to match HTTPie's semantics

This is the documented HTTPie behavior and should be preserved for compatibility.
