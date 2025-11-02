# Issue: --pretty option implementation deviations in spie

**Issue ID:** [#8](https://github.com/brandonbloom/SwiftPie/issues/8)
**Feature Slug:** pretty-option
**Status:** Open (Updated)

## Summary

The `--pretty` option is now implemented in spie, but has several behavioral deviations from HTTPie's implementation that affect output compatibility.

## Tested

**Commands tested:**
```bash
http --pretty=none --ignore-stdin http://localhost:8888/json
spie --pretty=none --ignore-stdin http://localhost:8888/json

http --pretty=all --ignore-stdin http://localhost:8888/json
spie --pretty=all --ignore-stdin http://localhost:8888/json

http --pretty=colors --ignore-stdin http://localhost:8888/json
spie --pretty=colors --ignore-stdin http://localhost:8888/json

http --pretty=format --ignore-stdin http://localhost:8888/json
spie --pretty=format --ignore-stdin http://localhost:8888/json

http --pretty=invalid --ignore-stdin http://localhost:8888/json
spie --pretty=invalid --ignore-stdin http://localhost:8888/json
```

## Expected

HTTPie's `--pretty` option should:
1. Accept values: `none`, `colors`, `format`, `all`
2. Show only response body by default (no headers)
3. Use 4-space indentation for JSON formatting
4. Use compact JSON style: `"key": value` (no space before colon)
5. Preserve original key ordering
6. Exit with code 1 for invalid values

## Actual

SpIE's `--pretty` option:
1. **✓ Accepts all four values** (none, colors, format, all)
2. **✗ Shows headers + body** instead of body only
3. **✗ Uses 2-space indentation** instead of 4-space
4. **✗ Uses spaced JSON style**: `"key" : value` (space before colon)
5. **✗ Different key ordering** in JSON output
6. **✗ Exits with code 64** for invalid values (instead of 1)

## The Problem

While the `--pretty` option is now implemented, several deviations prevent output compatibility:

### 1. Output Parts Mismatch
- **HTTPie**: Shows only body by default
- **SpIE**: Shows headers + body by default
- **Impact**: Scripts parsing output will fail due to unexpected headers

### 2. JSON Formatting Style
- **HTTPie**: 4-space indentation, `"key": value` format
- **SpIE**: 2-space indentation, `"key" : value` format
- **Impact**: Direct output comparison fails, different visual appearance

### 3. JSON Key Ordering
- **HTTPie**: Preserves server's original key ordering
- **SpIE**: Uses different ordering (possibly alphabetical or insertion order)
- **Impact**: Makes diff/comparison difficult

### 4. Exit Code Inconsistency
- **HTTPie**: Returns exit code 1 for invalid --pretty values
- **SpIE**: Returns exit code 64 for invalid --pretty values
- **Impact**: Error handling scripts may not catch failures correctly

## Impact

**Severity:** Medium-High

The option is functional but produces incompatible output:

1. **Breaking for automated scripts**: Output parsing will fail due to headers
2. **Visual inconsistency**: Different formatting makes manual comparison difficult
3. **Testing challenges**: Cannot easily verify spie matches http behavior
4. **Migration friction**: Users switching from http to spie will see different output

## Root Cause

Multiple implementation differences:

1. **Output parts**: Related to default `--print` option behavior (see issue #13)
2. **JSON formatting**: Different JSON encoder/formatter library or settings
3. **Indentation**: Hardcoded to 2 spaces instead of HTTPie's 4 spaces
4. **Colon spacing**: Different JSON serialization style
5. **Key ordering**: Possible use of unordered dictionaries/maps

## Recommendation

To achieve full HTTPie compatibility:

1. **Fix default output parts**: Show only body by default (unless `--print` specifies otherwise)
2. **Adjust JSON indentation**: Use 4-space indentation to match HTTPie
3. **Fix JSON colon style**: Use `"key": value` format (no space before colon)
4. **Preserve key ordering**: Maintain server's original JSON key order
5. **Standardize exit codes**: Use exit code 1 for invalid option values

## Related Issues

- Issue #13: `--print` option (controls which parts of request/response to show)
- Issue #15: `--format-options` (controls formatting details like indentation)
- Issue #10: `--unsorted` flag (disables sorting)
- Issue #14: `--sorted` flag (enables sorting)

## Test Details

See `/Users/bbloom/Projects/SwiftPie-validation/features/pretty-option.md` for complete test results and examples.

## Update History

- **Original (pre-2025-11-01)**: Reported that --pretty option was completely missing
- **Updated (2025-11-01)**: Option is now implemented but has behavioral deviations
