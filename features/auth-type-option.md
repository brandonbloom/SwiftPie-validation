# Feature: auth-type-option

**Slug:** auth-type-option

**Description:** Select the authentication mechanism type via `--auth-type` (shorthand `-A`) flag.

Supported types:
- `basic`: HTTP Basic Authentication (default)
- `bearer`: Bearer Token Authentication
- `digest`: Digest Authentication (http only)

## Test Plan

This test verifies that both `http` and `spie` correctly handle the `--auth-type` option for different authentication mechanisms.

### Commands to be Tested

1. Basic auth type: `http --auth user:pass --auth-type basic http://localhost:8888/basic-auth/user/pass`
2. Bearer auth type: `http --auth token123 --auth-type bearer http://localhost:8888/get`
3. Digest auth type: `http --auth user:pass --auth-type digest http://localhost:8888/digest-auth/auth/user/pass`
4. Shorthand -A flag: `http --auth user:pass -A basic http://localhost:8888/get`
5. Invalid auth type (http): `http --auth user:pass --auth-type invalid http://localhost:8888/get`
6. Invalid auth type (spie): `./bin/spie --auth user:pass --auth-type invalid http://localhost:8888/get`

### Prerequisites

The test requires:
- `http` CLI available (installed)
- `spie` CLI available (built in ./bin/spie)
- httpbin server running on localhost:8888
- Basic auth, bearer, and digest auth endpoints accessible

All prerequisites are met.

## Test Results

### Summary

⚠️ **PARTIAL SUPPORT** - `http` supports all auth types (basic, bearer, digest), while `spie` only supports basic and bearer.

### Detailed Test Results

| Test Case | http Result | spie Result | Status |
|-----------|------------|------------|--------|
| `--auth-type basic` | ✅ 200 OK with Authorization header | ✅ 200 OK with Authorization header | PASS |
| `--auth-type bearer` | ✅ 200 OK with Authorization header | ✅ 200 OK with Authorization header | PASS |
| `--auth-type digest` | ✅ 200 OK with Authorization header | ❌ Error: unsupported auth type 'digest' | FAIL |
| `-A basic` shorthand | ✅ Works, Authorization header sent | ❌ Error: unknown option '-A' | FAIL |

### Test Observations

1. **Basic Authentication**: Both tools correctly implement HTTP Basic Authentication via the `--auth-type basic` option
2. **Bearer Authentication**: Both tools correctly implement Bearer Token Authentication via the `--auth-type bearer` option
   - Bearer token format: `Authorization: Bearer <token>`
3. **Digest Authentication**: Only `http` supports digest authentication. `spie` explicitly rejects digest auth with error "unsupported auth type 'digest'"
4. **Shorthand `-A` flag**:
   - `http` supports the `-A` shorthand for `--auth-type`
   - `spie` does NOT support the `-A` shorthand and returns error "unknown option '-A'"
5. **Default behavior**: When `--auth-type` is not specified, both tools default to basic authentication

### Key Differences

| Feature | http | spie |
|---------|------|------|
| Basic auth | ✅ | ✅ |
| Bearer auth | ✅ | ✅ |
| Digest auth | ✅ | ❌ |
| `-A` shorthand | ✅ | ❌ |
| Long form `--auth-type` | ✅ | ✅ |

### Deviations from Expected Behavior

1. **Digest Authentication Not Supported in spie**: `spie` explicitly rejects digest auth type with error message "unsupported auth type 'digest'"
2. **Missing `-A` Shorthand in spie**: `spie` does not support the `-A` shorthand for `--auth-type` option, only the long form `--auth-type` is supported

### Implementation Status

- **http (reference)**: Fully supports auth-type-option with basic, bearer, and digest authentication mechanisms, plus shorthand flags
- **spie (test)**: Partially supports auth-type-option with basic and bearer authentication only, no shorthand flag support
