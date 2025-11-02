# Issue: 25238 - response-mime Not Implemented

**Feature Slug:** response-mime

**Status:** OPEN

**Severity:** Medium

**Date Reported:** 2025-11-01

## Summary

The `--response-mime` option is not implemented in `spie`. This is a deviation from HTTPie because it removes the ability to override the response MIME type for formatting and coloring purposes.

## What Was Tested

- `spie --response-mime=application/json GET http://localhost:8888/html` (override HTML as JSON)
- `spie --response-mime=text/plain GET http://localhost:8888/json` (override JSON as plain text)
- Verification in help text: `spie --help | grep response-mime`

## What Was Expected

According to HTTPie documentation:
- `--response-mime` should accept a MIME type string (e.g., `application/json`, `text/html`, etc.)
- When specified, HTTPie should format and colorize the output according to the provided MIME type
- Useful when the server provides incorrect Content-Type headers or when manual override is needed
- Allows formatting responses in a different way than the server indicated

## What Actually Happened

```
$ spie --response-mime=application/json GET http://localhost:8888/html
error: unknown option '--response-mime=application/json'

$ spie --help | grep response-mime
(no output - flag not found)
```

## Why This Is an Issue

1. **Loss of MIME override capability**: Users cannot force specific formatting for responses
2. **Breaks HTTPie compatibility**: Scripts using `--response-mime` will not work with `spie`
3. **Debugging limitation**: Cannot force formatting when server provides incorrect Content-Type
4. **No workaround**: There is no equivalent feature in `spie` to achieve the same result
5. **Edge case handling**: Cannot handle responses with missing or incorrect MIME type headers

## Related Features

- `--response-charset` option (override response encoding)
- `--format-options` (control formatting details)
- `--pretty` option (control output processing)
- Content-Type header handling

## Recommended Fix

Implement the `--response-mime` option with the following behavior:

1. Add `--response-mime` flag parsing
2. Accept MIME type as parameter (e.g., `application/json`, `text/html`, etc.)
3. Override the MIME type detection from Content-Type header
4. Apply appropriate formatting and coloring based on the specified MIME type
5. Support all MIME types that HTTPie supports (JSON, HTML, XML, plain text, etc.)

## Test Cases That Need to Pass

- `spie --response-mime=application/json GET http://localhost:8888/html` → format HTML as JSON (with JSON colors/formatting)
- `spie --response-mime=text/plain GET http://localhost:8888/json` → format JSON as plain text
- `spie --response-mime=application/xml GET http://localhost:8888/html` → format HTML as XML
- `spie --response-mime=text/html GET http://localhost:8888/json` → format JSON as HTML
- Override affects output formatting and coloring appropriately for each MIME type

## Environment Details

- spie binary: `/Users/bbloom/Projects/SwiftPie-validation/bin/spie`
- httpbin server: `http://localhost:8888`
- HTTPie version: 3.2.4
- Test date: 2025-11-01

## Files

- Test plan: `features/response-mime.md`
- Test results: See test plan for detailed comparisons
