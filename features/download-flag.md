# Feature: download-flag (--download, -d)

## Description
The `--download` (or `-d`) flag enables download mode, which saves the response body to a file with an auto-guessed filename (typically based on the URL path or Content-Disposition header). This is useful for downloading files from APIs without manually specifying filenames.

## Test Plan

### Test 1: Basic download with auto-guessed filename
- Make a GET request to an endpoint that returns file-like content
- Use `--download` flag to trigger download mode
- Verify a file is created with an appropriate name
- Verify no response headers are printed to stdout

### Test 2: Download with Content-Type hint
- Request an endpoint and verify filename is based on URL path or Content-Disposition header

## Commands Executed

### http (reference implementation)
```bash
# Test 1: Download with auto-guessed filename
cd /tmp && http --download http://localhost:8888/get

# Verify file was created
ls -la | grep -E '(get|download|response)'
```

### spie (Swift implementation)
```bash
# Test 1: Download with auto-guessed filename
cd /tmp && spie --download http://localhost:8888/get

# Verify file was created
ls -la | grep -E '(get|download|response)'
```

## Expected Behavior
- Request should be sent successfully
- Response body should be saved to a file with an auto-generated name
- stdout should show minimal output or just metadata
- Exit code should be 0 on success

## Test Execution

### http Results
- Command: `http POST http://localhost:8888/post foo=bar --download --output response.json --ignore-stdin`
- Exit code: 0 (success)
- Output message: "Downloading to response.json"
- File created: YES (/tmp/test_http_dl/response.json, 455 bytes)
- File contents: Proper JSON response with headers from the POST request
- Behavior: When used with `--output`, downloads response body to file
- Without `--output`: `--download` alone still prints to stdout (requires explicit filename)
- Feature partially works but requires `--output` to specify filename

### spie Results
- Command: `spie --download POST http://localhost:8888/post foo=bar --ignore-stdin`
- Exit code: 64 (error)
- Error message: `error: unknown option '--download'`
- File created: NO
- Shorthand `-d` also fails with same error
- Feature is NOT IMPLEMENTED in spie

## Comparison
- http: Feature exists but only works with explicit `--output` filename
- spie: Feature completely missing (no --download or -d support)
- This prevents users from easily downloading responses to files

## Test Status
FAILED - spie does not support the --download/-d option

## Notes
- Both long form (--download) and short form (-d) are missing in spie
- http requires `--output` to actually save the file with --download
- This is a critical feature gap for file downloads
