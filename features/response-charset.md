# Response Charset Feature Tests

**Feature Slug:** `response-charset`
**HTTP Option:** `--response-charset ENCODING`
**Description:** Override the response encoding for terminal display purposes

## Feature Overview

The `--response-charset` option allows you to override the character encoding that HTTPie uses when decoding the response body for terminal display. This is useful when:
- The server provides an incorrect or missing charset header
- You know the correct encoding but the server doesn't advertise it
- You want to display content in a specific encoding regardless of what the server reports

Common encoding values include: utf8, utf-16, big5, iso-8859-1, etc.

## Test Design

Test the `--response-charset` option to verify:
1. Parsing of the option and encoding argument
2. Correct behavior in applying the charset override
3. Proper handling of different encodings

### Test Environment
- **HTTPie Version:** 3.2.4
- **SpIE Version:** Swift-based implementation
- **HTTPBin Server:** http://localhost:8888 (running)
- **Test Date:** 2025-11-01

### Test Cases

#### Test 1: HTTPie with --response-charset=utf8
- **Command:** `http --response-charset=utf8 --ignore-stdin http://localhost:8888/json`
- **Expected:** Response decoded using UTF-8 encoding
- **Result:** ✓ PASS
- **Output:** JSON response displayed correctly with UTF-8 decoding applied

#### Test 2: SpIE with --response-charset=utf8
- **Command:** `/Users/bbloom/Projects/SwiftPie-validation/bin/spie --response-charset=utf8 --ignore-stdin http://localhost:8888/json`
- **Expected:** SpIE should support --response-charset option (or fail gracefully if not supported)
- **Result:** ✗ FAIL
- **Error:** `error: unknown option '--response-charset=utf8'`
- **Exit Code:** 64

## Test Results

**Status: FAILED**

### Deviation Summary

**SpIE does NOT support the `--response-charset` option.**

| Aspect | HTTPie | SpIE |
|--------|--------|------|
| Flag Support | ✓ Implemented | ✗ Not Implemented |
| Charset Override | ✓ Works | ✗ Not available |
| Encoding Control | ✓ Works (multiple encodings) | ✗ Not available |

### Impact Analysis

- **Severity:** Medium
- **Category:** Feature Gap
- **User Impact:** Users cannot override response encoding in SpIE. This is particularly problematic when:
  - The server provides incorrect or missing charset information
  - Working with responses in non-standard encodings
  - Debugging encoding-related issues
  - Processing international content with specific character sets

### Related Features
- `response-mime`: Complementary feature for MIME type override
- `pretty-option`: Related output control feature

### Notes
- The `--response-charset` option works as expected in HTTPie
- SpIE lacks the option entirely (no charset override capability)
- This is a specialized but important feature for handling edge cases with encoding
