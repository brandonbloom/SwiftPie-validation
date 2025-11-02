# Issue: --pretty option not implemented in spie

**Issue ID:** [#8](https://github.com/brandonbloom/SwiftPie/issues/8)
**Feature Slug:** pretty-option
**Status:** Open

## Summary

The `--pretty` option is not supported in spie. This option controls output processing (colors, formatting, both, or none) and is fundamental to HTTPie's output control capabilities.

## Tested

**Command tested:**
```bash
spie --pretty=none http://localhost:8888/json
spie --pretty=all http://localhost:8888/json
spie --pretty=colors http://localhost:8888/json
spie --pretty=format http://localhost:8888/json
```

## Expected

HTTPie supports the `--pretty` option with four values:
- `none`: No prettifying - output raw response exactly as received
- `colors`: Apply syntax coloring only (no formatting/indentation changes)
- `format`: Apply formatting/indentation only (no colors)
- `all`: Apply both colors and formatting (default for terminal)

All four variations work correctly in HTTPie:
```bash
http --pretty=none http://localhost:8888/json    # Works
http --pretty=all http://localhost:8888/json     # Works
http --pretty=colors http://localhost:8888/json  # Works
http --pretty=format http://localhost:8888/json  # Works
```

## Actual

SpIE does not recognize the `--pretty` option:
```
error: unknown option '--pretty=none'
error: unknown option '--pretty=all'
error: unknown option '--pretty=colors'
error: unknown option '--pretty=format'
```

## The Problem

SpIE completely lacks support for the `--pretty` option. This means users cannot:
- Control output formatting and coloring
- Disable colors when piping to files or other programs
- Apply formatting independently of colors
- Have consistent output behavior between HTTPie and SpIE

## Impact

**Severity:** High

This is a core functionality gap. The `--pretty` option is fundamental to HTTPie's design and is used frequently by users who need to control output formatting. Without it, SpIE is not a complete HTTPie replacement.

## Root Cause

The `--pretty` option is not implemented in the SpIE CLI argument parser. The feature would need to be added to:
1. CLI argument parser (accept --pretty with values: all, colors, format, none)
2. Output formatter (apply pretty formatting based on the selected mode)
3. Color/formatting logic (conditional application of colors and indentation)

## Recommendation

Implement the `--pretty` option with support for all four values:
- `none`: Disable all formatting and coloring
- `colors`: Apply colors but no formatting
- `format`: Apply formatting but no colors
- `all`: Apply both colors and formatting (default)
