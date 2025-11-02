# Issue: --max-redirects implies --follow in spie but not in http

**Issue ID:** #30
**Feature Slug:** max-redirects-option
**Status:** Open

## Summary

In http, `--max-redirects` requires the `--follow` flag to take effect. In spie, `--max-redirects` automatically enables redirect following without requiring a separate `--follow` flag. This is a behavioral difference.

## Tested

**http command:**
```bash
$ http get http://localhost:8888/redirect/3 --max-redirects 5
# Does NOT follow redirects (shows first redirect response only)

$ http get http://localhost:8888/redirect/3 --follow --max-redirects 5
# Follows redirects (requires both flags)
```

**spie command:**
```bash
$ spie --max-redirects 5 http://localhost:8888/redirect/3
# Automatically follows redirects (no --follow needed)
```

## Expected

HTTPie documentation states: "By default, requests have a limit of 30 redirects (works with --follow)."

This means:
- `--max-redirects` only affects behavior when used with `--follow`
- Without `--follow`, redirects are not followed regardless of `--max-redirects` value
- Two separate flags control redirect behavior

**Tested:**
```bash
$ http get http://localhost:8888/redirect/3 --max-redirects 5
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<title>Redirecting...</title>
<h1>Redirecting...</h1>
<p>You should be redirected automatically to target URL: <a href="/relative-redirect/2">/relative-redirect/2</a>.  If not click the link.
```
Returns first redirect response only - does not follow.

## Actual

SpIE documentation states: "Limit redirect hops when following (implies --follow)."

This means:
- `--max-redirects` automatically enables redirect following
- Don't need both flags
- Single flag controls both behaviors

**Tested:**
```bash
$ spie --max-redirects 5 http://localhost:8888/redirect/3
[...shows all intermediate redirects and final response...]
```
Automatically follows redirects.

## The Problem

The behavioral difference creates compatibility issues:
- Users familiar with http expect to need `--follow` separately
- Scripts using `--max-redirects` without `--follow` will behave differently
- spie's behavior is arguably more convenient but incompatible
- Documentation differs between tools ("works with" vs "implies")

## Impact

**Severity:** Medium

This is a behavioral difference that affects:
- Command-line compatibility between http and spie
- User expectations (http users expect two-flag model)
- Scripts that might use `--max-redirects` alone
- Documentation and mental model of how flags interact

However, spie's documentation is accurate about the behavior ("implies --follow"), so users reading spie docs will know what to expect.

The convenience of a single flag is arguably better UX, but breaks compatibility.

## Analysis

**http's design:**
- `--follow`: Boolean to enable redirect following (default 30 redirects)
- `--max-redirects N`: Set limit only when following is enabled
- Orthogonal flags with clear separation of concerns

**spie's design:**
- `--max-redirects N`: Enable following with specific limit
- Single flag combines both behaviors
- Simpler but incompatible

## Related Issues

- Issue #48: follow-flag behavior differences
- Issue #29: Intermediate response display differences

## Recommendation

**Option 1 (Strict compatibility):**
- Change spie to match http's behavior exactly
- Require explicit `--follow` flag
- Make `--max-redirects` only work when `--follow` is also present

**Option 2 (Document as known difference):**
- Keep current behavior (more convenient)
- Clearly document the difference from http
- Accept as intentional UX improvement over http

**Option 3 (Support both):**
- Accept `--max-redirects` alone (implies follow) - current behavior
- Also accept `--follow` flag separately
- If both are present, they work together
- This provides convenience while maintaining some compatibility

Recommended: Option 3 - support both models for maximum compatibility while keeping convenient behavior.
