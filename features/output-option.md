# Feature: output-option (--output, -o)

## Description
The `--output` (or `-o`) option saves the response to a file instead of printing to stdout. This is useful for saving API responses without manually redirecting output.

## Test Plan

### Test 1: Basic output to file
- Make a simple GET request with `--output filename.txt`
- Verify the file is created with the response body
- Verify no output is printed to stdout

### Test 2: Output with response headers
- Make a request and specify output file
- Verify headers and body are both saved when appropriate

## Commands Executed

### http (reference implementation)
```bash
# Test 1: Basic GET with output to file
http --output /tmp/test_http_output.txt http://localhost:8888/get

# Verify file contents
cat /tmp/test_http_output.txt
```

### spie (Swift implementation)
```bash
# Test 1: Basic GET with output to file
spie --output /tmp/test_spie_output.txt http://localhost:8888/get

# Verify file contents
cat /tmp/test_spie_output.txt
```

## Expected Behavior
- Request should be sent successfully
- Response (headers and/or body) should be saved to the specified file
- stdout should be empty or minimal (no response body printed to terminal)
- Exit code should be 0 on success

## Test Execution

### http Results
- Command: `http --output /tmp/test_http_output.txt http://localhost:8888/get`
- Exit code: 0 (success)
- File created: YES (/tmp/test_http_output.txt, 178 bytes)
- File contents: HTML error response (405 Method Not Allowed)
- stdout: Empty (no output printed to terminal)
- Feature works as expected: response saved to file, stdout suppressed

### spie Results
- Command: `spie --output /tmp/test_spie_output.txt http://localhost:8888/get`
- Exit code: 64 (error)
- Error message: `error: unknown option '--output'`
- File created: NO
- Shorthand `-o` also fails with: `error: unknown option '-o'`
- Feature is NOT IMPLEMENTED in spie

## Comparison
- http: Feature fully implemented and working
- spie: Feature completely missing (no --output or -o support)
- This is a critical missing feature for saving responses to files

## Test Status
FAILED - spie does not support the --output/-o option

## Notes
- Both long form (--output) and short form (-o) are missing in spie
- This is a functional gap that prevents users from saving API responses to files
- http command successfully saves response to file as expected
