# Feature: --check-status Flag

## Description
The `--check-status` flag instructs HTTPie to exit with an error code if the HTTP response status indicates an error (4xx or 5xx). By default, HTTPie exits with 0 when no network or other fatal errors occur, regardless of the HTTP status code.

## HTTPie Behavior
- **Default**: HTTPie exits with 0 for all successful HTTP responses, including 4xx and 5xx status codes
- **With `--check-status`**: HTTPie exits with a non-zero status code if the response status is in the 4xx or 5xx range
- **Status codes 2xx and 3xx**: Always result in exit code 0

## Test Results

### HTTPie Implementation
- Status: ✅ Verified Working
- Behavior: Works as expected
  - 2xx responses (200, 201): exit code 0
  - 3xx responses (300): exit code 0
  - 4xx responses (400, 403, 404): exit code 4
  - 5xx responses (500, 502, 503): exit code 5
  - Without `--check-status`: Always exit code 0 (default behavior)

### SpIE Implementation
- Status: ❌ **NOT IMPLEMENTED**
- Error: Unknown option '--check-status'
- Exit Code: 64 (option parsing error)
- Behavior: SpIE does not support this flag at all

## Test Cases

### Test 1: 2xx Success (200 OK)
```bash
http --check-status http://localhost:8888/status/200
# Expected: exit code 0
```

### Test 2: 3xx Redirect (300 Multiple Choices)
```bash
http --check-status http://localhost:8888/status/300
# Expected: exit code 0
```

### Test 3: 4xx Client Error (400 Bad Request)
```bash
http --check-status http://localhost:8888/status/400
# Expected: exit code 3
```

### Test 4: 4xx Not Found (404)
```bash
http --check-status http://localhost:8888/status/404
# Expected: exit code 3
```

### Test 5: 5xx Server Error (500 Internal Server Error)
```bash
http --check-status http://localhost:8888/status/500
# Expected: exit code 4
```

### Test 6: 5xx Bad Gateway (502)
```bash
http --check-status http://localhost:8888/status/502
# Expected: exit code 4
```

## Deviation Summary

| Aspect | HTTPie | SpIE |
|--------|--------|------|
| Flag Support | ✅ Supported | ❌ Not Supported |
| 2xx Status | exit 0 | N/A |
| 3xx Status | exit 0 | N/A |
| 4xx Status | exit 3 | N/A |
| 5xx Status | exit 4 | N/A |

## Implementation Gap
SpIE does not currently implement the `--check-status` flag. This is a missing feature that affects error handling in scripts and automated workflows.
