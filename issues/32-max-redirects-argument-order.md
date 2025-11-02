# Issue: spie requires --max-redirects before URL, treats it as request item if after

**Issue ID:** #32
**Feature Slug:** max-redirects-option
**Status:** Open

## Summary

spie has strict argument order requirements - if `--max-redirects` appears after the URL, it's treated as a request item and causes an error. http allows options anywhere in the command line.

## Tested

**spie command (fails):**
```bash
$ spie http://localhost:8888/redirect/3 --max-redirects 5
error: invalid request item '--max-redirects'
```
Exit code: 64

**spie command (works):**
```bash
$ spie --max-redirects 5 http://localhost:8888/redirect/3
# Success - follows redirects
```

**http command (works both ways):**
```bash
$ http get http://localhost:8888/redirect/3 --follow --max-redirects 5
# Works

$ http get --follow --max-redirects 5 http://localhost:8888/redirect/3
# Also works

$ http get http://localhost:8888/redirect/3 --max-redirects 5 --follow
# Also works - options can appear anywhere
```

## Expected

HTTPie has flexible argument parsing:
- Options can appear before or after the URL
- Options can appear in any order
- Makes commands more natural to type
- Users don't have to remember strict ordering rules

```bash
$ http get http://localhost:8888/redirect/3 --follow --max-redirects 5
# All of these work in http:
$ http get --follow http://localhost:8888/redirect/3 --max-redirects 5
$ http get --follow --max-redirects 5 http://localhost:8888/redirect/3
```

## Actual

SpIE requires strict argument order:
- Options must come before the URL
- Arguments after URL are treated as request items (headers, data, etc.)
- Error if option appears after URL

```bash
$ spie --max-redirects 5 http://localhost:8888/redirect/3
# Works

$ spie http://localhost:8888/redirect/3 --max-redirects 5
error: invalid request item '--max-redirects'
# Fails - thinks --max-redirects is a request item
```

## The Problem

This strict ordering creates usability issues:
- Less intuitive than http's flexible parsing
- Users must remember to put all options before URL
- Natural typing patterns fail (adding options after URL)
- Error message is confusing ("invalid request item" for a valid option)
- Breaks muscle memory from using http

Common failure pattern:
1. User types URL first: `spie http://localhost:8888/redirect/3`
2. User adds option: `spie http://localhost:8888/redirect/3 --max-redirects 5`
3. Error occurs instead of working

## Impact

**Severity:** Medium

This affects usability and compatibility:
- Users migrating from http will encounter confusing errors
- Must learn and remember spie's strict ordering
- Error message doesn't clearly explain the ordering requirement
- Reduces command-line ergonomics
- Scripts that work with http may fail with spie if options are placed after URL

Not critical because:
- Workaround exists (put options before URL)
- Only affects argument order, not functionality
- Easy to fix once understood

## Root Cause

SpIE's argument parser has two phases:
1. Parse options/flags (before URL)
2. Parse URL and request items (after URL)

Once it sees the URL, everything after is treated as request items (headers, data fields, etc.). It doesn't continue parsing options.

http's parser is more sophisticated - it can distinguish options from request items regardless of position.

## Related Issues

This affects all spie options:
- Any option placed after URL will fail
- General argument parsing limitation
- Not specific to --max-redirects

## Recommendation

**Option 1 (Full compatibility):**
Enhance spie's argument parser to support flexible option placement like http:
- Parse options anywhere in command line
- Distinguish between `--option value` and `Header:value` patterns
- Maintain backward compatibility (current strict order still works)

**Option 2 (Better error messages):**
Keep current strict ordering but improve error:
```
error: invalid request item '--max-redirects'
note: options must appear before the URL
hint: try: spie --max-redirects 5 http://localhost:8888/redirect/3
```

**Option 3 (Document limitation):**
- Keep current behavior
- Clearly document the ordering requirement
- Accept as design difference from http

Recommended: **Option 1** for best compatibility, or **Option 2** as simpler improvement to help users understand the constraint.

## Example Error Improvements

Current:
```
error: invalid request item '--max-redirects'
```

Improved:
```
error: invalid request item '--max-redirects'
note: options must be placed before the URL in spie
hint: try: spie --max-redirects 5 http://localhost:8888/redirect/3
```

Even better (detect common mistake):
```
error: option '--max-redirects' cannot appear after URL
note: in spie, all options must come before the URL
hint: try: spie --max-redirects 5 http://localhost:8888/redirect/3
```
