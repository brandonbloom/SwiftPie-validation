# Feature: timeout-option

## Description
The `--timeout` option sets the request timeout in seconds. If the server doesn't respond within the specified time, the request should fail with a timeout error.

## Test Plan

1. **Normal request (no timeout)**: Verify both tools can successfully complete a request without timeout
2. **Delayed response within timeout**: Request with 2-second delay and 5-second timeout (should succeed)
3. **Delayed response exceeding timeout**: Request with 3-second delay and 1-second timeout (should fail with timeout error)
4. **Edge case - zero timeout**: Test behavior with `--timeout 0` (http: no limit, spie: should reject)
5. **Edge case - negative timeout**: Test behavior with `--timeout -1` (both should reject)
6. **Decimal timeout**: Test behavior with fractional seconds like `--timeout 0.5`

Test against httpbin's `/delay/{n}` endpoint which delays the response by n seconds (max 10).

## Expected Behavior (http baseline)

- `--timeout SECONDS`: Set connection timeout in seconds
- Default is 0 (no timeout limit)
- Timeout applies to lack of bytes received on underlying socket, not entire download time
- Should error if server hasn't sent bytes within timeout period
- Accepts decimal values (e.g., 0.5 for half a second)
- Zero means no timeout (infinite wait)
- Negative values are rejected with error

## Test Results

### Test 1: Delayed response within timeout (timeout > delay)

**Command:**
```bash
http --timeout 5 GET http://localhost:8888/delay/2
spie --timeout 5 GET http://localhost:8888/delay/2
```

**http result:**
- Exit code: 0
- Elapsed time: ~2.15s
- Status: Success (request completes before timeout)

**spie result:**
- Exit code: 0
- Elapsed time: ~2.03s
- Status: Success (request completes before timeout)

**Comparison:** Both tools behave identically - request succeeds when delay < timeout.

### Test 2: Delayed response exceeding timeout (timeout < delay)

**Command:**
```bash
http --timeout 1 GET http://localhost:8888/delay/3
spie --timeout 1 GET http://localhost:8888/delay/3
```

**http result:**
```
Exit code: 2
Elapsed: 1.16s
Error: http: error: Request timed out (1.0s).
```

**spie result:**
```
Exit code: 1
Elapsed: 1.01s
Error: transport error: request timed out after 1s
```

**Comparison:** Both timeout correctly, but with differences:
1. **Exit code**: http exits with 2, spie exits with 1
2. **Error message format**: Different wording and format
3. **Timing**: Both timeout at approximately the right time (~1s)

### Test 3: Edge case - zero timeout

**Command:**
```bash
http --timeout 0 GET http://localhost:8888/delay/1
spie --timeout 0 GET http://localhost:8888/delay/1
```

**http result:**
```
Exit code: 0
Elapsed: 1.16s
Status: Success (zero means no timeout limit)
```

**spie result:**
```
Exit code: 64
Elapsed: 0.01s
Error: error: invalid timeout value '0'
```

**Comparison:** MAJOR DIFFERENCE
- http: Accepts `--timeout 0` as "no timeout limit" (per documentation)
- spie: Rejects `--timeout 0` as invalid, requires positive value

### Test 4: Edge case - negative timeout

**Command:**
```bash
http --timeout -1 GET http://localhost:8888/get
spie --timeout -1 GET http://localhost:8888/get
```

**http result:**
```
Exit code: 1
Error: http: error: ValueError: Attempted to set connect timeout to -1.0, but the timeout cannot be set to a value less than or equal to 0.
```

**spie result:**
```
Exit code: 64
Error: error: invalid timeout value '-1'
```

**Comparison:** Both reject negative values, but:
1. Different exit codes (1 vs 64)
2. Different error messages (verbose vs terse)

### Test 5: Decimal timeout values

**Command:**
```bash
http --timeout 0.5 GET http://localhost:8888/delay/1
spie --timeout 0.5 GET http://localhost:8888/delay/1
```

**http result:**
```
Exit code: 2
Elapsed: ~0.5s
Error: http: error: Request timed out (0.5s).
```

**spie result:**
```
Exit code: 1
Elapsed: ~0.5s
Error: transport error: request timed out after 0s
```

**Comparison:** Both accept decimal values and timeout correctly, but:
1. Different exit codes (2 vs 1)
2. spie rounds down display to "0s" instead of showing "0.5s"

## Issues Found

### Issue 1: Zero timeout handling difference (#25)
- **http**: `--timeout 0` means "no timeout limit" (documented behavior)
- **spie**: `--timeout 0` is rejected as invalid
- **Impact**: Breaking difference - users cannot disable timeout using 0 value
- **Issue file**: issues/25-timeout-zero-rejected.md

### Issue 2: Timeout error exit code mismatch (#26)
- **http**: Exits with code 2 on timeout
- **spie**: Exits with code 1 on timeout
- **Impact**: Scripts checking exit codes will fail
- **Issue file**: issues/26-timeout-exit-code-mismatch.md

### Issue 3: Timeout display rounding in error message (#27)
- **http**: Shows actual timeout value in error (e.g., "0.5s")
- **spie**: Rounds down to integer in display (e.g., "0s" for 0.5)
- **Impact**: Low - cosmetic issue, but confusing for debugging
- **Issue file**: issues/27-timeout-display-truncated.md

### Issue 4: Invalid timeout exit code mismatch (#28)
- **http**: Exits with code 1 for invalid timeout values
- **spie**: Exits with code 64 for invalid timeout values
- **Impact**: Medium - inconsistent error handling
- **Issue file**: issues/28-invalid-timeout-exit-code.md

## Status
Failed

## Summary

The `--timeout` option is implemented in spie but has several behavioral differences from http:

1. **Critical**: spie does not accept `--timeout 0` as "no timeout limit" (http's documented behavior)
2. **High**: Different exit codes for timeout errors (2 vs 1)
3. **Medium**: Different exit codes for invalid timeout values (1 vs 64)
4. **Low**: Decimal timeout values are displayed as integers in error messages

Core timeout functionality works (enforcing timeout, accepting decimal values), but the edge cases and error handling differ significantly.
