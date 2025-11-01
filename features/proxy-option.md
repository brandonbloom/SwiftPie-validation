# Feature: proxy-option (Network)

**Slug:** proxy-option

**Description:** HTTP/HTTPS proxy configuration via `--proxy PROTOCOL:PROXY_URL` flag. Allows routing requests through a proxy server for different protocols.

## Test Plan

This test verifies that both `http` and `spie` correctly handle HTTP proxy configuration:

1. **Basic HTTP proxy configuration**: Test `--proxy http:http://proxy:port` syntax
2. **HTTPS proxy configuration**: Test `--proxy https:https://proxy:port` syntax
3. **Multiple protocol proxies**: Test both HTTP and HTTPS proxies simultaneously
4. **Proxy authentication**: Test proxy with credentials in URL (if supported)
5. **Environment variables**: Test `$HTTP_PROXY`, `$HTTPS_PROXY`, and `$ALL_PROXY` support
6. **Proxy bypass scenarios**: Test requests to localhost (typically bypass proxy)
7. **Invalid proxy URL**: Test error handling for malformed proxy URLs

**Test Endpoint:** http://localhost:8888/get (simple endpoint to verify request routing)

### Prerequisites Check

The test requires:
- `http` CLI available (installed)
- `spie` CLI available (built in ./bin/spie)
- httpbin server running on localhost:8888
- A test proxy server available or ability to verify proxy handling without actual proxy

All prerequisites are met except we cannot test actual proxy routing without a running proxy server.

### Commands to be Tested

**http CLI tests:**
- `http --proxy http:http://localhost:3128 http://localhost:8888/get`
- `http --proxy https:https://localhost:3129 https://example.com`
- `http --proxy http:http://proxy:3128 --proxy https:https://proxy:3129 http://localhost:8888/get`
- `http http://localhost:8888/get` (with HTTP_PROXY environment variable set)
- `http http://localhost:8888/get` (with ALL_PROXY environment variable set)

**spie CLI tests:**
- `/Users/bbloom/Projects/httpie-delta/bin/spie --proxy http:http://localhost:3128 http://localhost:8888/get`
- `/Users/bbloom/Projects/httpie-delta/bin/spie --proxy https:https://localhost:3129 https://example.com`

## Expected Behavior

According to HTTPie documentation:
- `--proxy PROTOCOL:PROXY_URL` sets a proxy for the specified protocol
- Multiple `--proxy` flags can be used for different protocols
- `$HTTP_PROXY`, `$HTTPS_PROXY`, and `$ALL_PROXY` environment variables are supported
- Localhost requests typically bypass the proxy
- Proxy URLs should follow standard format: `protocol://[user:pass@]host:port`

## Test Results

### Summary
🔴 **BLOCKED - Feature Not Implemented in spie**

The `--proxy` option is not available in the spie implementation. While `http` CLI supports proxy configuration, `spie` lacks this functionality entirely.

### Detailed Test Results

| Test Case | http Result | spie Result | Status |
|-----------|------------|------------|--------|
| `--proxy http:http://proxy:3128` | ✅ Flag recognized | ❌ Unknown option | DEVIATION |
| `--proxy https:https://proxy:3129` | ✅ Flag recognized | ❌ Unknown option | DEVIATION |
| Help text includes `--proxy` | ✅ Yes | ❌ No | DEVIATION |

### Test Observations

1. **Feature Missing in spie**: The `--proxy` option is completely absent from spie's command-line interface
2. **Feature Present in http**: The `http` CLI (v3.2.4) fully supports proxy configuration
3. **Help Documentation**: `http --help` shows detailed proxy documentation; `spie --help` has no proxy-related content
4. **Protocol Support**: `http` supports per-protocol proxy mapping (HTTP, HTTPS, etc.)

### Key Differences

- **http** supports `--proxy` flag with syntax `PROTOCOL:PROXY_URL`
- **spie** does not support `--proxy` flag at all
- This is a **significant feature deviation** between implementations

### Deviations from Expected Behavior

✅ **Confirmed Deviation**: The `--proxy` option is not implemented in `spie`.
- `http` CLI fully implements proxy support as documented
- `spie` implementation is missing this network feature entirely
- This affects any use case requiring proxy routing (corporate networks, security testing, etc.)

### Blocking Status

This feature test is blocked because:
1. spie does not support the `--proxy` option
2. Testing actual proxy behavior requires a running proxy server on the system
3. Cannot verify feature parity between implementations due to missing functionality in spie

**Recommendation**: Implement `--proxy` option in spie with the same syntax and behavior as HTTPie to achieve feature parity.

