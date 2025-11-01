# Issue: 25229 - json-flag Not Implemented

**Feature Slug:** json-flag

**Status:** BLOCKER

**Severity:** Critical

**Date Reported:** 2025-11-01

## Summary

The `--json` flag (and its shorthand `-j`) is not implemented in `spie`. This is a critical deviation from HTTPie because:

1. The `--json` flag is the **DEFAULT** content type in HTTPie
2. `spie` instead defaults to form data serialization
3. Users cannot explicitly request JSON serialization with `spie`

## What Was Tested

- `spie --ignore-stdin --json POST http://localhost:8888/post name=John`
- `spie --ignore-stdin -j POST http://localhost:8888/post key=value`
- Default behavior without any flag: `spie --ignore-stdin POST http://localhost:8888/post name=John`

## What Was Expected

According to HTTPie documentation:
- `--json` (or `-j`) should serialize request data as JSON
- Content-Type header should automatically be set to `application/json`
- Accept header should automatically be set to `application/json, */*;q=0.5`
- JSON should be the default serialization format

## What Actually Happened

```
$ spie --ignore-stdin --json POST http://localhost:8888/post name=John
error: unknown option '--json'

$ spie --ignore-stdin -j POST http://localhost:8888/post key=value
error: unknown option '-j'

$ spie --ignore-stdin POST http://localhost:8888/post name=John
# Sends form data (application/x-www-form-urlencoded) instead of JSON
```

## Why This Is an Issue

1. **Breaking difference from HTTPie**: HTTPie defaults to JSON, spie defaults to form data
2. **No way to force JSON**: Users cannot use `--json` to explicitly request JSON serialization
3. **Inconsistent with HTTPie design**: The entire HTTPie philosophy is JSON-first
4. **API compatibility broken**: Scripts or commands that rely on `--json` will not work with `spie`

## Related Features That Depend On This

- `--form` / `-f` flag (form data alternative)
- `--multipart` flag (multipart form data)
- Content-Type and Accept header auto-setting
- Default method inference (POST when data is present)

## Recommended Fix

Implement the `--json` flag with the following behavior:

1. Add `--json` and `-j` flag parsing
2. Set default serialization to JSON (instead of form data)
3. Automatically set `Content-Type: application/json` header
4. Automatically set `Accept: application/json, */*;q=0.5` header
5. Serialize request items as JSON object: `{"key": "value", "number": 42}`

## Test Cases That Need to Pass

- `spie --json POST url name=John` → sends `{"name": "John"}`
- `spie -j POST url key=value` → sends `{"key": "value"}`
- `spie POST url name=John` → sends `{"name": "John"}` (JSON is default)
- `spie --json POST url name=John age:=30` → sends `{"name": "John", "age": 30}`
- Request headers include `Content-Type: application/json`
- Request headers include `Accept: application/json, */*;q=0.5`

## Environment Details

- spie binary: `/Users/bbloom/Projects/httpie-delta/bin/spie`
- httpbin server: `http://localhost:8888`
- Test date: 2025-11-01

## Files

- Test plan: `features/json-flag.md`
- Test results: See test plan for detailed comparisons
