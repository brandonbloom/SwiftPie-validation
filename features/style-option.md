# Style Option Feature Tests

**Feature Slug:** `style-option`
**HTTP Option:** `--style, -s`
**Description:** Output coloring style selection from 40+ themes

## Feature Overview

The `--style` option (short: `-s`) allows users to select from various output coloring/syntax highlighting themes for HTTP responses. HTTPie supports numerous themes including:
- auto (default - follows terminal ANSI colors)
- abap, algol, algol_nu, arduino
- autumn, borland, bw
- coffee, colorful
- default, dracula
- emacs
- friendly, friendly_grayscale, fruity
- github-dark, gruvbox-dark, gruvbox-light
- igor, inkpot
- lightbulb, lilypond, lovelace
- manni, material, monokai, murphy
- native, nord, nord-darker
- one-dark
- paraiso-dark, paraiso-light, pastie, perldoc, pie, pie-dark, pie-light
- rainbow_dash, rrt
- sas
- solarized, solarized-dark, solarized-light
- staroffice
- stata-dark, stata-light
- tango, trac
- vim, vs
- xcode
- zenburn

## Test Results

**Status: PENDING** (Testing in progress)

### Test Environment
- **HTTPie Version:** 3.2.4
- **SpIE Version:** Swift-based implementation
- **HTTPBin Server:** http://localhost:8888 (running)
- **Test Date:** 2025-11-01

### Tests Performed

#### Test 1: Default Style (auto)
- **Command:** `http http://localhost:8888/json`
- **Expected:** Output displays with terminal's default ANSI colors
- **Result:** Testing...
- **Details:** TBD

#### Test 2: Specific Style - monokai
- **Command:** `http --style monokai http://localhost:8888/json`
- **Expected:** Output displays with monokai theme syntax highlighting
- **Result:** Testing...
- **Details:** TBD

#### Test 3: Specific Style - dracula
- **Command:** `http --style dracula http://localhost:8888/json`
- **Expected:** Output displays with dracula theme syntax highlighting
- **Result:** Testing...
- **Details:** TBD

#### Test 4: Specific Style - solarized-light
- **Command:** `http --style solarized-light http://localhost:8888/json`
- **Expected:** Output displays with solarized-light theme
- **Result:** Testing...
- **Details:** TBD

#### Test 5: Specific Style - nord
- **Command:** `http --style nord http://localhost:8888/json`
- **Expected:** Output displays with nord theme
- **Result:** Testing...
- **Details:** TBD

#### Test 6: Non-color (bw) style
- **Command:** `http --style bw http://localhost:8888/json`
- **Expected:** Output displays in black and white only
- **Result:** Testing...
- **Details:** TBD

#### Test 7: Short form (-s) with monokai
- **Command:** `http -s monokai http://localhost:8888/json`
- **Expected:** Short form `-s` works identically to `--style`
- **Result:** Testing...
- **Details:** TBD

#### Test 8: Style with JSON pretty-printing
- **Command:** `http --style dracula --pretty=all http://localhost:8888/json`
- **Expected:** Style applied to formatted JSON output
- **Result:** Testing...
- **Details:** TBD

#### Test 9: Style with Headers and Body
- **Command:** `http --style monokai --print=HhBb http://localhost:8888/post data=test`
- **Expected:** Style applied to both request and response
- **Result:** Testing...
- **Details:** TBD

#### Test 10: Invalid style name
- **Command:** `http --style invalid-style-name http://localhost:8888/json`
- **Expected:** Error or fallback to default behavior
- **Result:** Testing...
- **Details:** TBD

### Implementation Differences

**Testing in progress...**

| Feature | http | spie | Status |
|---------|------|------|--------|
| --style flag | Expected | Testing | TBD |
| Multiple style themes | Expected | Testing | TBD |
| Short form -s | Expected | Testing | TBD |
| Color output control | Expected | Testing | TBD |

### Compatibility Notes

1. **SpIE Implementation Status:** Need to verify if SpIE supports `--style` option
2. **Theme Support:** Need to verify which themes are supported by both implementations

### Edge Cases to Test

- Invalid style names
- Style with output redirection (colors should be disabled)
- Multiple style specifications (last one should win)
- Style with --raw option
- Style with --quiet option

## Conclusion

**Status: PENDING**

Testing in progress. This feature test will document any deviations between http and spie implementations.

---

**Test Summary:**
- Total Tests: 10
- Passed: 0
- Failed: 0
- Blocked: 0
- In Progress: 10
