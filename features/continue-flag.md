# Feature: continue-flag (--continue, -c)

## Description
The `--continue` (or `-c`) flag enables resume functionality for interrupted downloads. It allows resuming a partially downloaded file from where it left off, similar to wget's `-c` flag. This requires the `--output` option to specify the file to resume.

## Test Plan

### Test 1: Resume a download from an interrupted state
- Start downloading a file with `--output` and `--continue`
- Verify the request uses the Range header to resume from the last byte
- Verify partial files are properly resumed and completed

### Test 2: Behavior with non-existent file
- Use `--continue` with a file that doesn't exist
- Should start a fresh download

## Commands Executed

### http (reference implementation)
```bash
# Test 1: Resume download
http --output /tmp/resume_test.txt --continue http://localhost:8888/post foo=bar

# Verify Range header is sent
http --output /tmp/resume_test.txt --continue -v http://localhost:8888/post foo=bar 2>&1 | grep -i range
```

### spie (Swift implementation)
```bash
# Test 1: Resume download
spie --output /tmp/resume_test.txt --continue http://localhost:8888/post foo=bar

# Verify Range header (if supported)
spie --output /tmp/resume_test.txt --continue -v http://localhost:8888/post foo=bar
```

## Expected Behavior
- Request should send Range header to resume from existing file size
- Partial responses (206) should be handled correctly
- File should be updated/resumed rather than overwritten
- Exit code should be 0 on success

## Test Execution

### http Results
- Command: `http --download --output response.txt --continue POST http://localhost:8888/post foo=bar --ignore-stdin`
- Exit code: 0 (success)
- Output message: "Downloading to response.txt"
- File created: YES (/tmp/test_continue/response.txt, 455 bytes)
- File contents: Complete JSON response
- Behavior: `--continue` works with `--download --output` combination
- Important: `--continue` only works with `--download` (error message: "--continue only works with --download")
- Feature is fully implemented in http

### spie Results
- Command: `spie --continue POST http://localhost:8888/post foo=bar --ignore-stdin`
- Exit code: 64 (error)
- Error message: `error: unknown option '--continue'`
- Also tested: `spie --download --continue ...` fails with `error: unknown option '--download'`
- Feature is NOT IMPLEMENTED in spie (neither --continue nor -c)

## Comparison
- http: Feature fully implemented (requires --download)
- spie: Feature completely missing (no --continue or -c support)
- This prevents users from resuming interrupted downloads

## Test Status
FAILED - spie does not support the --continue/-c option

## Notes
- Both long form (--continue) and short form (-c) are missing in spie
- This feature requires `--download` to be useful in http (they work together)
- Critical for resumable downloads, especially for large files
- Depends on Range HTTP header support
