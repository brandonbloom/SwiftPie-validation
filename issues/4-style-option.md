# Issue #25230: Style Option Not Implemented in SpIE

**Feature Slug:** `style-option`
**HTTP Option:** `--style, -s`
**Status:** Feature Missing in SpIE

## Issue Description

The `--style` (short: `-s`) option is not implemented in SpIE. This option allows users to select from 40+ color themes for syntax highlighting of HTTP responses.

HTTPie fully implements this feature with support for themes like:
- monokai, dracula, solarized-light, nord, vim, github-dark, gruvbox-dark, etc.
- A special "auto" theme that follows terminal ANSI colors
- A "bw" (black and white) theme for colorless output

## Impact

- Users switching from HTTPie to SpIE lose the ability to customize output colors
- SpIE uses fixed, non-customizable coloring
- The `--style` and `-s` flags are not recognized and cause errors

## Test Evidence

### HTTPie Behavior
```bash
$ http --style monokai http://localhost:8888/json
# Successfully applies monokai theme

$ http -s dracula http://localhost:8888/json
# Short form works correctly

$ http --style bw http://localhost:8888/json
# Black and white theme works
```

### SpIE Behavior
```bash
$ spie --style monokai http://localhost:8888/json
# Error: unknown option '--style'

$ spie -s dracula http://localhost:8888/json
# Error: unknown option '-s'
```

## Available Themes in HTTPie

1. **Default Themes:** abap, algol, algol_nu, arduino, autumn, borland, bw
2. **Popular Themes:** coffee, colorful, default, dracula, emacs, friendly, fruity
3. **Colorblind-Friendly:** friendly_grayscale, solarized-light
4. **Dark Themes:** github-dark, gruvbox-dark, material, monokai, native, nord, nord-darker, one-dark, vim
5. **Special Themes:** auto (default - follows terminal colors)

Total: 40+ supported styles

## Current SpIE Implementation

SpIE has no style customization mechanism:
- Colors are always enabled when output is to terminal
- Colors are always disabled when output is redirected
- Users cannot switch between color schemes
- Help message shows no `--style` or `-s` option

## Recommendation

Implement the `--style` option in SpIE to match HTTPie's functionality. This would allow users to:
1. Customize output colors to match their terminal theme
2. Use colorless output with `--style bw`
3. Achieve parity with HTTPie's color management

## Files
- Feature test: `features/style-option.md`
- This issue: `issues/25230-style-option.md`
