# max-headers-option Feature Test

## Feature Description
`--max-headers MAX_HEADERS` - The maximum number of response headers to be read before giving up (default 0, i.e., no limit).

This option controls how many response headers an HTTP client will accept before aborting the connection. A value of 0 means there is no limit.

## Test Plan

### Test 1: Default behavior (no limit)
- Command: `http --max-headers=0 http://localhost:8888/headers`
- Expected: Should successfully retrieve response with all headers

### Test 2: Large header limit
- Command: `http --max-headers=100 http://localhost:8888/headers`
- Expected: Should successfully retrieve response (httpbin typically returns <10 headers)

### Test 3: Reasonable header limit
- Command: `http --max-headers=5 http://localhost:8888/headers`
- Expected: Should successfully retrieve response if headers < 5, otherwise should error/truncate

### Test 4: Header exceeding limit (if possible with httpbin)
- Note: httpbin doesn't easily allow creating many response headers, so this tests the parameter parsing

## Implementation Status

### http (reference implementation)
- Status: Implemented
- Support: Full support for --max-headers option
- Behavior: Accepts integer value, default is 0

### spie (implementation under test)
- Status: Unknown
- Support: To be determined
- Behavior: To be tested

## Test Results

### http Implementation Tests

#### Test 1: Default behavior with --max-headers=0 (no limit)
```
Command: http --max-headers=0 GET http://localhost:8888/headers
Result: SUCCESS - Request completed successfully, all response headers received
Headers received: 5 (Server, Date, Connection, Content-Type, Content-Length, Access-Control-Allow-Origin, Access-Control-Allow-Credentials)
```

#### Test 2: Large header limit --max-headers=100
```
Command: http --max-headers=100 GET http://localhost:8888/headers
Result: SUCCESS - Request completed successfully
Headers received: 5 (well under the limit)
```

#### Test 3: Very restrictive limit --max-headers=1
```
Command: http --max-headers=1 GET http://localhost:8888/headers
Result: FAILURE (Expected) - Connection aborted with error: "got more than 1 headers"
Error Message: ConnectionError: ('Connection aborted.', HTTPException('got more than 1 headers'))
```

#### Test 4: Invalid input --max-headers=invalid
```
Command: http --max-headers=invalid GET http://localhost:8888/headers
Result: FAILURE (Expected) - Argument validation error
Error Message: argument --max-headers: invalid int value: 'invalid'
```

### spie Implementation Tests

#### Test 1: Basic usage with --max-headers=0
```
Command: spie --max-headers=0 GET http://localhost:8888/headers
Result: FAILURE - Unknown option error
Error Message: error: unknown option '--max-headers=0'
Exit Code: 64
```

#### Test 2: With different value --max-headers=100
```
Command: spie --max-headers=100 GET http://localhost:8888/headers
Result: FAILURE - Unknown option error
Error Message: error: unknown option '--max-headers=100'
Exit Code: 64
```

#### Test 3: Check spie help for max-headers
```
Command: spie --help | grep -i max-header
Result: NO MATCH - The --max-headers option is not listed in spie help
```

## Comparison Results

| Feature | http | spie | Status |
|---------|------|------|--------|
| --max-headers option support | ✓ Implemented | ✗ Not Implemented | FAILED |
| Accept valid integer values | ✓ Yes | ✗ No | FAILED |
| Validate integer input | ✓ Yes (rejects non-integers) | N/A | N/A |
| Enforce header limit on connection | ✓ Yes (aborts if exceeded) | N/A | N/A |
| Default value (0 = no limit) | ✓ Yes | N/A | N/A |

## Deviations Found

**CRITICAL DEVIATION**: The `--max-headers` option is completely missing from spie.

**Details**:
- http fully implements `--max-headers MAX_HEADERS` option
- spie does not recognize this option and returns "unknown option" error
- http correctly validates integer input and enforces header limits
- http properly aborts connection when response headers exceed the specified limit
- The feature is essential for handling responses with excessive headers

## Status
FAILED - spie does not implement the --max-headers option that is present in http.
