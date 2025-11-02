# Issue: stream-flag not implemented in spie

**Issue ID:** [#22](https://github.com/brandonbloom/SwiftPie/issues/22)stream-flag-not-implemented

**Feature Slug:** stream-flag

**Severity:** Medium

**Status:** Identified

## Problem Description

The `--stream` (shorthand `-S`) flag is not implemented in the `spie` CLI. This flag is a standard HTTPie feature that enables line-by-line streaming of response bodies, which is essential for handling long-lived HTTP connections and streaming APIs.

## Current Behavior

When attempting to use the `--stream` flag with `spie`:
```bash
$ spie --stream GET http://localhost:8888/stream/5
error: unknown option '--stream'
Exit code: 64
```

The same applies to the shorthand form:
```bash
$ spie -S GET http://localhost:8888/stream/5
error: unknown option '-S'
Exit code: 64
```

## Expected Behavior

Both `http` and `spie` should support the `--stream` flag with identical behavior:
- Enable line-by-line streaming output of the response body
- Work with `--pretty` formatting to colorize streamed lines
- Work with `--print` options to filter which parts of the request/response are output
- Provide the `-S` shorthand for convenience

## HTTPie Documentation Reference

From `http --help`:
```
--stream, -S
  Always stream the response body by line, i.e., behave like `tail -f'.

  Without --stream and with --pretty (either set or implied),
  HTTPie fetches the whole response before it outputs the processed data.

  Set this option when you want to continuously display a prettified
  long-lived response, such as one from the Twitter streaming API.
```

## Use Cases Affected

1. **Server-Sent Events (SSE)**: Real-time event streaming from servers
2. **Twitter Streaming API**: Long-lived HTTP connections for live data
3. **Log streaming**: Monitoring applications that stream logs over HTTP
4. **Real-time data feeds**: Any service that sends unbuffered response streams

## Test Evidence

**Test Command:**
```bash
http --stream GET http://localhost:8888/stream/5
```

**Result:**
Successfully outputs 5 JSON objects, one per line, as they arrive.

**spie Attempt:**
```bash
spie --stream GET http://localhost:8888/stream/5
```

**Result:**
Error: unknown option '--stream'

## Implementation Notes

To fix this issue, the `spie` implementation would need to:

1. Add `--stream` and `-S` flag definition to the argument parser
2. Implement streaming response handling that processes body output line-by-line
3. Ensure compatibility with other output-related flags (`--pretty`, `--print`, etc.)
4. Update help documentation to include the new flag

## Affected HTTPie Features

- Feature: stream-flag
- Slug: stream-flag
- Test Status: Failed

