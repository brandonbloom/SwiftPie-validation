# compress-flag Feature Test Report

## Feature Definition
**Slug:** compress-flag
**Name:** --compress, -x Flag
**Description:** Request body compression using the Deflate algorithm with automatic Content-Encoding header management
**HTTPie Help:**
```
--compress, -x
    Content compressed (encoded) with Deflate algorithm.
    The Content-Encoding header is set to deflate.

    Compression is skipped if it appears that compression ratio is
    negative. Compression can be forced by repeating the argument.
```

## Test Results

### Summary
**Status:** FAILED
**Implementation:** Feature not implemented in spie

### Detailed Test Results

#### Test 1: Flag Recognition
- **http:** ✓ PASS - `--compress` flag documented in help and accepted
- **spie:** ✗ FAIL - `--compress` flag not found in help or recognized

#### Test 2: Short Form Support (-x)
- **http:** ✓ PASS - Short form `-x` documented and accepted
- **spie:** ✗ FAIL - Short form `-x` not recognized (error: "unknown option")

#### Test 3: Help Documentation
- **http:** ✓ PASS - Fully documented with behavior details
- **spie:** ✗ FAIL - Not documented in help output

## Deviations

### Critical Deviations
1. **Missing Feature:** spie does not implement the `--compress` / `-x` flag at all
2. **Missing Behavior:** spie cannot compress request bodies with deflate encoding
3. **Missing Header:** spie cannot set Content-Encoding header for compression

### Functionality Not Available in spie
- Deflate compression of request body
- Automatic Content-Encoding header injection
- Compression ratio optimization (skipping when negative)
- Forced compression with repeated flag (`-x -x`)

## Command Examples

### HTTPie
```bash
# Using --compress flag
http --compress POST httpbin.org/post < data.txt

# Using short form -x
http -x POST httpbin.org/post < data.txt

# Force compression even if ratio is negative
http -x -x POST httpbin.org/post < data.txt
```

### SwiftPie (spie)
```bash
# Not supported - will return error:
spie --compress POST httpbin.org/post  # error: unknown option '--compress'
spie -x POST httpbin.org/post          # error: unknown option '-x'
```

## Implementation Notes

### spie Architecture
SwiftPie is a Swift-native implementation with a simplified command-line interface. Current supported features include:
- Basic HTTP methods (GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS)
- Request items (headers, query params, data fields, JSON literals, file uploads)
- Authentication (basic, bearer)
- Transport options (timeout, TLS verification, HTTP/1.1 force, SSL)
- Input/output control (ignore-stdin)

The `--compress` flag would require:
1. Integration with a deflate compression library
2. Request body interception and compression logic
3. Automatic Content-Encoding header management
4. Compression ratio calculation for optimization

### Root Cause
The feature is not currently implemented in spie. This appears to be a deliberate design choice focusing on core HTTP client functionality rather than request body encoding features.

## Recommendation
**Mark as FAILED** - Feature is not implemented in spie and cannot be tested for compatibility.
