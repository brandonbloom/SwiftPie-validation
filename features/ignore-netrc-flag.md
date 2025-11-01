# Feature Test: ignore-netrc Flag

## Summary

Tests the `--ignore-netrc` flag which tells HTTPie to ignore credentials from the .netrc file.

## Test Plan

The `--ignore-netrc` flag controls whether HTTPie reads credentials from the user's .netrc file:
- **Without flag**: HTTPie reads from .netrc and uses stored credentials for matching hosts
- **With flag**: HTTPie ignores the .netrc file and does not use stored credentials

### Test Approach

1. Create a temporary .netrc file with credentials for localhost
2. Test `http` CLI without the flag (should use .netrc credentials)
3. Test `http` CLI with `--ignore-netrc` flag (should NOT use .netrc credentials)
4. Test `spie` implementation for the same scenarios
5. Compare behaviors for any deviations

## Expected Behavior

- **http --ignore-netrc**: Should accept the flag and skip reading .netrc credentials
- **spie --ignore-netrc**: Should either accept the flag (matching http) or reject it with an error (deviation)

## Testing Results

### http CLI
- **Flag Presence**: The `--ignore-netrc` flag exists in `http --help`
- **Help Text**: "Ignore credentials from .netrc."
- **Status**: Flag is recognized and available

### spie CLI
- **Flag Presence**: The `--ignore-netrc` flag is NOT present in `spie --help`
- **Status**: Flag is not implemented in spie

## Findings

### Deviation Detected

The `--ignore-netrc` flag is implemented in `http` but missing from `spie`.

**Type**: Missing feature in spie
**Severity**: High - Different CLI interface

### Details

| Aspect | http | spie |
|--------|------|------|
| Flag support | ✓ Yes | ✗ No |
| Help text | Shows in --help | Not in --help |
| Flag recognition | Recognized | Unknown/rejected |

## Test Status

**Status**: `failed`

**Reason**: The `--ignore-netrc` flag is not implemented in spie, making it impossible for spie to match http's behavior. Users cannot disable .netrc reading in spie.

## Notes

- The .netrc file integration is a security and authentication feature used to avoid entering passwords repeatedly
- Without this flag in spie, there's no way to force spie to ignore .netrc credentials
- This is a functional gap in spie that may cause compatibility issues for users migrating from http to spie
- Real testing of .netrc behavior (actually sending requests with/without credentials) was not completed due to http CLI hanging with network requests, but the feature gap is clear from flag presence alone

## Related Issues

- Issue to be created for missing `--ignore-netrc` support in spie
