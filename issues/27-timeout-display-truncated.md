# Issue: Timeout duration displayed as integer, truncating decimal values

**Issue ID:** #27
**Feature Slug:** timeout-option
**Status:** Open

## Summary

When a timeout occurs with a decimal timeout value (e.g., 0.5 seconds), SpIE displays the timeout duration as an integer (0s) in the error message, while HTTPie shows the actual value (0.5s). This makes debugging more difficult.

## Tested

**Command tested:**
```bash
spie --timeout 0.5 GET http://localhost:8888/delay/1
```

## Expected

HTTPie displays the actual timeout value in the error message:
```bash
http --timeout 0.5 GET http://localhost:8888/delay/1
```

Result:
```
http: error: Request timed out (0.5s).
```

The error message clearly shows "0.5s" which matches the specified timeout.

## Actual

SpIE truncates the decimal to integer:
```
transport error: request timed out after 0s
```

The error message shows "0s" instead of "0.5s", which is confusing and incorrect.

## The Problem

The error message formatting in SpIE appears to:
1. Accept decimal timeout values correctly (functionality works)
2. Enforce the timeout at the correct fractional second time
3. But format the duration as an integer in the error message

This is a cosmetic issue but affects debugging because:
- Users see "0s" and might think no timeout was set
- It's unclear what the actual timeout value was
- The error message doesn't match the command input

## Impact

**Severity:** Low

This is primarily a user experience and debugging issue. The timeout functionality itself works correctly (enforces 0.5s timeout properly), but the error message is misleading. This can:
- Confuse users debugging timeout issues
- Make it harder to verify which timeout value was actually used
- Lead to mistrust in error messages

## Root Cause

The error message formatting code likely uses integer formatting (e.g., %d or similar) instead of floating-point formatting (%.1f or similar) when displaying the timeout duration.

## Recommendation

Update the timeout error message to display the actual timeout value with appropriate precision:
1. Show decimal values when timeout is fractional (e.g., "0.5s")
2. Show integer values when timeout is whole number (e.g., "1s" not "1.0s")
3. Match the precision to be useful for debugging (1 decimal place is sufficient)

This is a simple formatting fix but improves user experience and error clarity.
