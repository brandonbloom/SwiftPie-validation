# Feature: quiet-flag (--quiet, -q)

## Description
The `--quiet` (or `-q`) flag suppresses output to stdout and stderr. It can be provided multiple times with increasing levels of suppression:
- `-q` (or `--quiet`): Suppress stdout/stderr but show errors and warnings
- `-qq`: Suppress warnings as well (only show errors)

This is useful for scripting where you want to silently execute HTTP requests.

## Test Plan

### Test 1: Basic quiet mode (-q)
- Make a request with `-q`
- Verify no response body is printed
- Verify no request headers are printed
- Verify errors/warnings are still shown

### Test 2: Double quiet mode (-qq)
- Make a request with `-qq`
- Verify both response and warnings are suppressed
- Only errors should be shown

### Test 3: Error display with quiet mode
- Make a request that produces an error/warning
- Verify appropriate error messages still appear

## Commands Executed

### http (reference implementation)
```bash
# Test 1: Single quiet
http -q POST http://localhost:8888/post foo=bar --ignore-stdin

# Test 2: Double quiet
http -qq POST http://localhost:8888/post foo=bar --ignore-stdin

# Test 3: Error with quiet
http -q GET http://localhost:8888/status --timeout 0.0001
```

### spie (Swift implementation)
```bash
# Test 1: Single quiet
spie -q POST http://localhost:8888/post foo=bar --ignore-stdin

# Test 2: Double quiet
spie -qq POST http://localhost:8888/post foo=bar --ignore-stdin

# Test 3: Error with quiet
spie -q GET http://localhost:8888/status --timeout 0.0001
```

## Expected Behavior
- `-q`: Should suppress most output but show errors
- `-qq`: Should suppress everything except critical errors
- Exit codes should be 0 on success
- Non-200 status codes may affect exit behavior

## Test Execution

### http Results
- Command (single quiet): `http -q POST http://localhost:8888/post foo=bar --ignore-stdin`
- Exit code: 0 (success)
- Output: NONE (completely silent)
- Response displayed: NO
- Headers displayed: NO
- Feature works: YES

- Command (double quiet): `http -qq POST http://localhost:8888/post foo=bar --ignore-stdin`
- Exit code: 0 (success)
- Output: NONE (completely silent)
- Feature works: YES

- Command without quiet for comparison: Shows full JSON response and headers
- Behavior: `-q` suppresses all stdout output for normal requests
- Feature is fully implemented in http

### spie Results
- Command: `spie -q POST http://localhost:8888/post foo=bar --ignore-stdin`
- Exit code: 64 (error)
- Error message: `error: unknown option '-q'`

- Command: `spie -qq POST http://localhost:8888/post foo=bar --ignore-stdin`
- Exit code: 64 (error)
- Error message: `error: unknown option '-qq'`

- Command: `spie --quiet POST http://localhost:8888/post foo=bar --ignore-stdin`
- Exit code: 64 (error)
- Error message: `error: unknown option '--quiet'`

- Feature is NOT IMPLEMENTED in spie (no -q, -qq, or --quiet support)

## Comparison
- http: Feature fully implemented with multiple verbosity levels
- spie: Feature completely missing (no --quiet, -q, or -qq support)
- This prevents silent operation in scripts

## Test Status
FAILED - spie does not support the --quiet/-q/-qq options

## Notes
- All three forms are missing: --quiet, -q, and -qq
- This is essential for scripting and silent operation
- http properly suppresses all output with quiet flags
- No way in spie to silence output for automated scripts
