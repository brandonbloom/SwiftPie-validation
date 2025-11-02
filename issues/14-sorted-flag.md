# Issue: --sorted flag not implemented in spie

**Issue ID:** [#14](https://github.com/brandonbloom/SwiftPie/issues/14)
**Feature Slug:** sorted-flag
**Status:** Open

## Summary

The `--sorted` flag is not supported in spie. This flag re-enables all sorting options in formatted output and is useful for ensuring consistent, reproducible output.

## Tested

**Command tested:**
```bash
spie --sorted http://localhost:8888/json
```

## Expected

HTTPie supports the `--sorted` flag which enables sorting:
```bash
http --sorted http://localhost:8888/json
```

This works correctly in HTTPie, displaying response headers and JSON keys in alphabetical order.

## Actual

SpIE does not recognize the `--sorted` flag:
```
error: unknown option '--sorted'
```

## The Problem

SpIE completely lacks support for the `--sorted` flag. This means users cannot:
- Re-enable header sorting after disabling it
- Ensure consistent, alphabetically sorted output
- Override unsorted behavior set in configuration files
- Control output sorting preferences

## Impact

**Severity:** Medium

This is a feature gap that affects output control. While not as critical as basic functionality, users who need consistent, sorted output cannot do so with SpIE.

## Root Cause

The `--sorted` flag is not implemented in the SpIE CLI argument parser. The feature would need to be added to:
1. CLI argument parser (accept --sorted flag)
2. Output formatter (track sorting preference)
3. Header/JSON formatting logic (conditionally enable sorting)

## Related Issues

- `25234-unsorted-flag.md`: The complementary `--unsorted` flag is also not implemented
- `25233-pretty-option.md`: Part of broader output control feature gap

## Recommendation

Implement the `--sorted` flag which enables sorting for:
- Response headers (alphabetically)
- JSON object keys (alphabetically)
- Any other sortable output elements

This should be a simple boolean flag that affects formatting behavior.
