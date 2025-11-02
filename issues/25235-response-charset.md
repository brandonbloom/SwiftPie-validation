# Issue: --response-charset option not implemented in spie

**Issue ID:** 25235
**Feature Slug:** response-charset
**Status:** Open

## Summary

The `--response-charset` option is not supported in spie. This option allows overriding the character encoding that spie uses when decoding the response body for terminal display.

## Tested

**Command tested:**
```bash
spie --response-charset=utf8 http://localhost:8888/json
```

## Expected

HTTPie supports the `--response-charset` option which allows overriding response encoding:
```bash
http --response-charset=utf8 http://localhost:8888/json
```

This works correctly in HTTPie, allowing users to specify custom character encodings.

## Actual

SpIE does not recognize the `--response-charset` option:
```
error: unknown option '--response-charset=utf8'
```

**Exit Code:** 64

## The Problem

SpIE completely lacks support for the `--response-charset` option. This means users cannot:
- Override incorrect or missing charset information from the server
- Display responses in specific character encodings
- Debug encoding-related issues
- Process international content with custom character sets

## Impact

**Severity:** Medium

This is a specialized feature that affects handling of edge cases with character encoding. While not as critical as basic functionality, it's important for users working with non-UTF-8 content or debugging encoding issues.

## Root Cause

The `--response-charset` option is not implemented in the SpIE CLI argument parser. The feature would need to be added to:
1. CLI argument parser (accept --response-charset with encoding parameter)
2. Response decoder (apply the specified charset when decoding response body)
3. Terminal output handler (use the overridden encoding for display)

## Recommendation

Implement the `--response-charset` option which accepts:
- Standard encoding names: utf8, utf-16, iso-8859-1, big5, etc.
- Apply the specified encoding when decoding response body for terminal display
- Fall back to server-specified encoding if not provided
