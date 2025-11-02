# Issue: spie rejects --max-redirects 0 as invalid while http accepts it

**Issue ID:** #31
**Feature Slug:** max-redirects-option
**Status:** Open

## Summary

spie rejects `--max-redirects 0` with an error, while http accepts it (though http's behavior with 0 is questionable - it still follows redirects).

## Tested

**spie command:**
```bash
$ spie --max-redirects 0 http://localhost:8888/redirect/3
error: invalid max redirects value '0'
```
Exit code: 64

**http command:**
```bash
$ http get http://localhost:8888/redirect/3 --follow --max-redirects 0
{
  "args": {},
  "headers": {
    "Accept": "application/json, */*;q=0.5",
    "Accept-Encoding": "gzip, deflate, zstd",
    "Connection": "keep-alive",
    "Host": "localhost:8888",
    "User-Agent": "HTTPie/3.2.4"
  },
  "origin": "192.168.65.1",
  "url": "http://localhost:8888/get"
}
```
Exit code: 0 (success - follows all redirects despite limit of 0!)

## Expected

HTTPie accepts `--max-redirects 0`:
```bash
$ http get http://localhost:8888/redirect/3 --follow --max-redirects 0
# Returns final response (after following 3 redirects)
# Does NOT respect the 0 limit
```

This appears to be a bug or special behavior in http - a limit of 0 should mean "don't follow any redirects" but http still follows them.

## Actual

SpIE rejects 0 as invalid:
```bash
$ spie --max-redirects 0 http://localhost:8888/redirect/3
error: invalid max redirects value '0'
```

SpIE performs input validation and rejects 0.

## The Problem

This is a behavioral difference where **spie is arguably more correct**:
- A limit of 0 logically means "don't follow any redirects"
- http's behavior of accepting 0 but still following redirects is confusing
- spie enforces that the limit must be at least 1

However, this breaks compatibility:
- Scripts using `--max-redirects 0` will fail on spie but work on http
- Users migrating from http may encounter this validation error
- The error behavior differs (64 vs accepting the value)

## Impact

**Severity:** Low

This is a low-severity issue because:
- spie's behavior is more logical and correct
- http's behavior with 0 appears to be a bug or undefined behavior
- Using 0 as a redirect limit is unusual (why follow redirects with a limit of 0?)
- The proper way to prevent redirect following is to omit `--follow` (http) or `--max-redirects` (spie)

Impact is limited to:
- Edge case where someone explicitly uses `--max-redirects 0`
- Compatibility testing that tries invalid/boundary values
- Scripts that might use 0 as a special value

## Analysis

**What should --max-redirects 0 mean?**

Option 1: Don't follow any redirects
- Most intuitive interpretation
- Matches spie's validation (reject it) or behavior (follow 0, error on first)
- Different from http's current behavior

Option 2: Unlimited redirects
- Possible interpretation of "no limit"
- Not what http does (http has default limit of 30)
- Confusing semantics

Option 3: Invalid value
- spie's current approach
- Forces users to use explicit positive values
- Prevents ambiguity

**http's behavior:**
- Accepts 0 without error
- Still follows redirects (ignores the 0 limit)
- Unclear if this is a bug or intended behavior
- Doesn't match what you'd expect from "max redirects = 0"

## Related Issues

None directly related. This is a validation/edge case difference.

## Recommendation

**Keep spie's current behavior** (reject 0 as invalid):
- It's more correct and less confusing than http's behavior
- Forces explicit positive limits
- Prevents ambiguity about what 0 means
- http's acceptance of 0 appears to be a bug

**Optional enhancement:**
- Provide better error message explaining why 0 is invalid
- Suggest using minimum of 1 or omitting flag to not follow redirects
- Current error "invalid max redirects value '0'" is clear enough

Example improved error:
```
error: invalid max redirects value '0'
note: use --max-redirects with a value >= 1, or omit the flag to disable redirect following
```

This is one case where spie's behavior is arguably better than http's.
