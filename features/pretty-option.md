# Pretty Option Feature Tests

**Feature Slug:** `pretty-option`
**HTTP Option:** `--pretty {all,colors,format,none}`
**Description:** Controls output processing (colors, formatting, both, or none)

## Feature Overview

The `--pretty` option controls how the response is formatted and colored when displayed to the terminal. It supports four values:

- `none`: No prettifying - output raw response exactly as received
- `colors`: Apply syntax coloring only (no formatting/indentation changes)
- `format`: Apply formatting/indentation only (no colors)
- `all`: Apply both colors and formatting (default for terminal)

This option is useful for:
- Disabling colors when piping output to files or other programs
- Controlling output formatting independent of colors
- Ensuring consistent output formatting across different environments

## Test Design

Test the `--pretty` option with all four values to verify:
1. Parsing of the option
2. Correct behavior for each value
3. Differences in output between values

### Test Environment
- **HTTPie Version:** 3.2.4
- **SpIE Version:** Swift-based implementation
- **HTTPBin Server:** http://localhost:8888 (running)
- **Test Date:** 2025-11-01

### Test Cases

#### Test 1: HTTPie with --pretty=none
- **Command:** `http --pretty=none --ignore-stdin http://localhost:8888/json`
- **Expected:** Raw unformatted JSON output (single lines, minimal whitespace)
- **Result:** ✓ PASS
- **Output:** JSON displayed as a single block with minimal indentation (2 spaces), no ANSI color codes

#### Test 2: HTTPie with --pretty=format
- **Command:** `http --pretty=format --ignore-stdin http://localhost:8888/json`
- **Expected:** Formatted JSON with indentation (4 spaces), no color codes
- **Result:** ✓ PASS
- **Output:** JSON displayed with 4-space indentation, no ANSI color codes

#### Test 3: HTTPie with --pretty=colors
- **Command:** `http --pretty=colors --ignore-stdin http://localhost:8888/json`
- **Expected:** Raw JSON structure with ANSI color codes, minimal indentation
- **Result:** ✓ PASS
- **Output:** Contains ANSI escape sequences like `[94m` for coloring, minimal indentation

#### Test 4: HTTPie with --pretty=all
- **Command:** `http --pretty=all --ignore-stdin http://localhost:8888/json`
- **Expected:** Formatted JSON with 4-space indentation and ANSI color codes
- **Result:** ✓ PASS
- **Output:** Contains ANSI escape sequences and 4-space indentation (default terminal behavior)

#### Test 5: SpIE with --pretty=none
- **Command:** `/Users/bbloom/Projects/SwiftPie-validation/bin/spie --pretty=none --ignore-stdin http://localhost:8888/json`
- **Expected:** SpIE should support --pretty option (or fail gracefully if not supported)
- **Result:** ✗ FAIL
- **Error:** `error: unknown option '--pretty=none'`

#### Test 6: SpIE with --pretty=all
- **Command:** `/Users/bbloom/Projects/SwiftPie-validation/bin/spie --pretty=all --ignore-stdin http://localhost:8888/json`
- **Result:** ✗ FAIL
- **Error:** `error: unknown option '--pretty=all'`

#### Test 7: SpIE with --pretty=colors
- **Command:** `/Users/bbloom/Projects/SwiftPie-validation/bin/spie --pretty=colors --ignore-stdin http://localhost:8888/json`
- **Result:** ✗ FAIL
- **Error:** `error: unknown option '--pretty=colors'`

#### Test 8: SpIE with --pretty=format
- **Command:** `/Users/bbloom/Projects/SwiftPie-validation/bin/spie --pretty=format --ignore-stdin http://localhost:8888/json`
- **Result:** ✗ FAIL
- **Error:** `error: unknown option '--pretty=format'`

## Test Results

**Status: FAILED**

### Deviation Summary

**SpIE does NOT support the `--pretty` option.**

| Aspect | HTTPie | SpIE |
|--------|--------|------|
| Flag Support | ✓ Implemented | ✗ Not Implemented |
| --pretty=none | ✓ Works | ✗ Unknown option |
| --pretty=colors | ✓ Works | ✗ Unknown option |
| --pretty=format | ✓ Works | ✗ Unknown option |
| --pretty=all | ✓ Works | ✗ Unknown option |
| Output Control | ✓ Full control | ✗ Not available |

### Impact Analysis

- **Severity:** High
- **Category:** Feature Gap
- **User Impact:** Users cannot control output formatting or coloring in SpIE. This is particularly problematic when:
  - Piping output to files or other programs (requires disabling colors)
  - Using HTTPie in scripts or automated workflows
  - Comparing output between HTTPie and SpIE
  - Controlling output verbosity and formatting

### Related Features
- `style-option`: Complementary feature for color scheme selection
- `unsorted-flag`: Related output control feature
- `sorted-flag`: Related output control feature

### Notes
- The `--pretty` option is fundamental to HTTPie's output control
- SpIE lacks this option entirely (no output formatting control available)
- This is a core functionality gap that affects all output processing
