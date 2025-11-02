# Issue: --unsorted flag not implemented in spie

**Issue ID:** [#10](https://github.com/brandonbloom/SwiftPie/issues/10)
**Feature Slug:** unsorted-flag
**Status:** Open

## Summary

The `--unsorted` flag is not supported in spie. This flag disables all sorting in formatted output (headers and JSON keys) and is useful for preserving the original order of response data.

## Tested

**Command tested:**
```bash
spie --unsorted http://localhost:8888/json
```

## Expected

HTTPie supports the `--unsorted` flag which disables sorting:
```bash
http --unsorted http://localhost:8888/json
```

This works correctly in HTTPie, displaying response headers and JSON keys in their original order (not alphabetically sorted).

## Actual

SpIE does not recognize the `--unsorted` flag:
```
error: unknown option '--unsorted'
```

## The Problem

SpIE completely lacks support for the `--unsorted` flag. This means users cannot:
- Disable header sorting in output
- Disable JSON key sorting in output
- Preserve the original order of response data
- Override sorting behavior set in configuration files

## Impact

**Severity:** Medium

This is a feature gap that affects output control. While not as critical as basic functionality, users who need to preserve data order or debug ordering-sensitive responses cannot do so with SpIE.

## Root Cause

The `--unsorted` flag is not implemented in the SpIE CLI argument parser. The feature would need to be added to:
1. CLI argument parser (accept --unsorted flag)
2. Output formatter (track sorting preference)
3. Header/JSON formatting logic (conditionally disable sorting)

## Related Issues

- `25235-sorted-flag.md`: The complementary `--sorted` flag is also not implemented
- `25233-pretty-option.md`: Part of broader output control feature gap

## Recommendation

Implement the `--unsorted` flag which disables sorting for:
- Response headers
- JSON object keys
- Any other sortable output elements

This should be a simple boolean flag that affects formatting behavior.
