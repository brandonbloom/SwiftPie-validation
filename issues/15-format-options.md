# Issue: 25237 - format-options Not Implemented

**Feature Slug:** format-options

**Status:** OPEN

**Severity:** Medium

**Date Reported:** 2025-11-01

## Summary

The `--format-options` option is not implemented in `spie`. This is a deviation from HTTPie because it removes the ability to customize output formatting behavior such as JSON indentation, header sorting, and other format controls.

## What Was Tested

- `spie --format-options=json.indent:4 GET http://localhost:8888/json` (custom JSON indentation)
- `spie --format-options=headers.sort:false GET http://localhost:8888/get` (disable header sorting)
- Verification in help text: `spie --help | grep format-options`

## What Was Expected

According to HTTPie documentation:
- `--format-options` should accept a comma-separated list of options
- Available options include:
  - `headers.sort=true/false` - control alphabetical sorting of response headers
  - `json.indent=N` - set JSON indentation level (default 2)
  - `json.ensure_ascii=true/false` - control ASCII escaping in JSON output
- Multiple options can be combined: `--format-options=headers.sort:false,json.indent:4`

## What Actually Happened

```
$ spie --format-options=json.indent:4 GET http://localhost:8888/json
error: unknown option '--format-options=json.indent:4'

$ spie --help | grep format-options
(no output - flag not found)
```

## Why This Is an Issue

1. **Loss of formatting control**: HTTPie's `--format-options` allows fine-tuning output appearance
2. **No customization capability**: Users cannot control JSON indentation or header sorting in spie
3. **Breaks HTTPie compatibility**: Scripts using `--format-options` will not work with `spie`
4. **Common use case**: Developers often want to customize indentation for debugging or readability
5. **No workaround**: There is no equivalent feature in `spie` to achieve the same result

## Related Features

- `--pretty` option (control output processing)
- `--unsorted` flag (disable header sorting)
- `--sorted` flag (enable header sorting)
- Color and formatting preferences

## Recommended Fix

Implement the `--format-options` option with the following behavior:

1. Add `--format-options` flag parsing
2. Accept comma-separated format configuration options
3. Support the following options:
   - `headers.sort=true/false` - enable/disable header sorting
   - `json.indent=N` - set JSON indentation level (0-8 spaces)
   - `json.ensure_ascii=true/false` - control ASCII character escaping
4. Apply formatting preferences to all output
5. Allow multiple options in a single flag

## Test Cases That Need to Pass

- `spie --format-options=json.indent:4 GET http://localhost:8888/json` → output with 4-space indentation
- `spie --format-options=json.indent:0 GET http://localhost:8888/json` → compact JSON (no indentation)
- `spie --format-options=headers.sort:false GET http://localhost:8888/get` → headers in server order
- `spie --format-options=headers.sort:true GET http://localhost:8888/get` → headers sorted alphabetically
- `spie --format-options=json.indent:4,headers.sort:false GET http://localhost:8888/json` → multiple options

## Environment Details

- spie binary: `/Users/bbloom/Projects/SwiftPie-validation/bin/spie`
- httpbin server: `http://localhost:8888`
- HTTPie version: 3.2.4
- Test date: 2025-11-01

## Files

- Test plan: `features/format-options.md`
- Test results: See test plan for detailed comparisons
