# Meta Flag (`--meta`, `-m`) Feature Test

## Feature Description
The `--meta` flag is a shortcut for `--print=m` that prints only the response metadata (HTTP status line and elapsed time).

- **Long form:** `--meta`
- **Short form:** `-m`
- **Function:** Prints only response metadata
- **Equivalent to:** `--print=m`

## HTTPie Behavior

The `--meta` flag in HTTPie prints only the response metadata, which includes:
- HTTP status line (e.g., "HTTP/1.1 200 OK")
- Elapsed time (e.g., "Elapsed time: 0.005553s")

Example output:
```
Elapsed time: 0.005553s
```

## Test Results

### Test 1: Basic GET Request
**Command:** `http --meta GET http://localhost:8888/get`
**Result:** ✅ PASSED
- HTTPie correctly outputs only the elapsed time metadata
- No response headers or body are printed

### Test 2: POST Request with Body
**Command:** `http --ignore-stdin --meta POST http://localhost:8888/post name=John age:=30`
**Result:** ✅ PASSED
- Flag works correctly with POST requests
- Request body is sent but only metadata is returned

### Test 3: Error Response (404)
**Command:** `http --meta GET http://localhost:8888/status/404`
**Result:** ✅ PASSED
- Works with error responses
- Still prints only metadata, no error details in response body

### Test 4: Custom Headers
**Command:** `http -m GET http://localhost:8888/headers X-Custom:TestValue`
**Result:** ✅ PASSED
- Short form `-m` works as expected
- Custom headers in request don't affect metadata output

### Test 5: Status Code Variations
**Command:** `http --meta GET http://localhost:8888/status/200`
**Result:** ✅ PASSED
- Works across different HTTP status codes
- Consistently returns only elapsed time

## SPIE (spie) Implementation Status

### Finding: **NOT IMPLEMENTED** ❌

SPIE does not support the `--meta` flag:
- `spie --meta GET http://localhost:8888/get` → Error: "unknown option '--meta'"
- `spie -m GET http://localhost:8888/get` → Error: "unknown option '-m'"

Neither the long form nor the short form is implemented in spie.

## Implementation Requirements

To implement the `--meta` flag in spie, the following is needed:

1. Add `--meta` / `-m` flag definition to argument parser
2. Make it a shortcut for `--print=m` (if --print is already implemented)
3. Ensure only "m" (metadata) part is printed in output
4. Metadata should include:
   - HTTP status line
   - Elapsed time in seconds

## Compatibility Assessment

| Feature | HTTPie | SPIE | Status |
|---------|--------|------|--------|
| `--meta` flag | ✅ Yes | ❌ No | **Not Implemented** |
| `-m` shorthand | ✅ Yes | ❌ No | **Not Implemented** |
| Metadata output format | Consistent | N/A | N/A |
| Works with GET | ✅ Yes | ❌ No | **Not Implemented** |
| Works with POST | ✅ Yes | ❌ No | **Not Implemented** |
| Works with error responses | ✅ Yes | ❌ No | **Not Implemented** |

## Deviation Summary

**MAJOR DEVIATION:** The `--meta` flag is completely missing from the SPIE implementation. This is an output control flag that users may rely on for scripting and debugging purposes.

## Notes

- The `--meta` flag is useful in scripting scenarios where only response timing is needed
- It's a convenient shortcut; the same result can be achieved with `--print=m`
- HTTPie's implementation is straightforward and works reliably across all tested scenarios
- SPIE needs to implement this feature to achieve feature parity with HTTPie
