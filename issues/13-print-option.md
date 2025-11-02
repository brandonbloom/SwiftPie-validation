# Issue: 25236 - print-option Not Implemented

**Feature Slug:** print-option

**Status:** OPEN

**Severity:** High

**Date Reported:** 2025-11-01

## Summary

The `--print` option (and its shorthand `-p`) is not implemented in `spie`. This is a significant deviation from HTTPie because it removes the ability to control which parts of the HTTP request and response are displayed.

## What Was Tested

- `spie --print=b GET http://localhost:8888/json` (response body only)
- `spie --print=Hh GET http://localhost:8888/json` (request and response headers)
- `spie --print=H GET http://localhost:8888/json` (request headers only)
- Verification in help text: `spie --help | grep print`

## What Was Expected

According to HTTPie documentation:
- `--print` (or `-p`) should accept a string of characters specifying output parts
- Available parts:
  - `H` = request headers
  - `B` = request body
  - `h` = response headers
  - `b` = response body
  - `m` = response metadata
- Default is `HhBb` (all parts)
- Users can combine characters for different output combinations

## What Actually Happened

```
$ spie --print=b GET http://localhost:8888/json
error: unknown option '--print=b'

$ spie -p h GET http://localhost:8888/json
error: unknown option '-p'

$ spie --help | grep print
(no output - flag not found)
```

## Why This Is an Issue

1. **Loss of output control**: HTTPie's `--print` option is a core feature for controlling output granularity
2. **No filtering capability**: Users cannot show headers only, body only, or metadata only
3. **Breaks HTTPie compatibility**: Scripts using `--print` flags will not work with `spie`
4. **No workaround**: There is no equivalent feature in `spie` to achieve the same result
5. **Common use case**: Many users rely on `--print=h` for debugging and `--print=b` for piping JSON

## Related Features

- `--headers` / `-h` flag (shortcut for `--print=h`)
- `--body` / `-b` flag (shortcut for `--print=b`)
- `--meta` / `-m` flag (shortcut for `--print=m`)
- `--verbose` / `-v` flag (related output control)

## Recommended Fix

Implement the `--print` option with the following behavior:

1. Add `--print` and `-p` flag parsing
2. Accept a string parameter with any combination of `H`, `B`, `h`, `b`, `m`
3. Default to showing all parts when flag is not provided
4. Filter output to show only requested parts:
   - `--print=b` → show only response body
   - `--print=h` → show only response headers
   - `--print=Hh` → show request and response headers
   - `--print=HhBb` → show all (default)
5. Properly handle all combinations

## Test Cases That Need to Pass

- `spie --print=b GET http://localhost:8888/json` → show only response body
- `spie --print=h GET http://localhost:8888/json` → show only response headers
- `spie --print=H GET http://localhost:8888/json` → show only request headers
- `spie --print=Hh GET http://localhost:8888/json` → show headers only (request and response)
- `spie -p b GET http://localhost:8888/json` → short form should work
- `spie GET http://localhost:8888/json` → default behavior shows all parts

## Environment Details

- spie binary: `/Users/bbloom/Projects/SwiftPie-validation/bin/spie`
- httpbin server: `http://localhost:8888`
- HTTPie version: 3.2.4
- Test date: 2025-11-01

## Files

- Test plan: `features/print-option.md`
- Test results: See test plan for detailed comparisons
