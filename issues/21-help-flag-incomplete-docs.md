# Issue: Incomplete Feature Documentation in spie --help

**Issue ID:** [#21](https://github.com/brandonbloom/SwiftPie/issues/21)help-flag-incomplete-docs
**Severity:** Medium
**Category:** Documentation
**Discovered During:** help-flag feature test
**Date:** 2025-10-31

## Description

The `spie --help` output documents only a subset of features compared to `http --help`. While this may be intentional (if spie implements fewer features), it creates a discoverability problem for users who want to understand what spie can do.

## Evidence

### Statistics
- **http --help:** 406 lines documenting 67+ features
- **spie --help:** 40 lines documenting ~15 features
- **Coverage ratio:** ~22% of http's documented features

### Features Missing from spie Help

The following feature categories are absent from spie help text:

#### Output Processing
- `--pretty` - Control output processing
- `--style, -s` - Output coloring styles
- `--unsorted` - Disable sorting
- `--sorted` - Enable sorting
- `--response-charset` - Override encoding
- `--response-mime` - Override MIME type
- `--format-options` - Formatting controls

#### Output Options
- `--print, -p` - Select output parts (headers, body, metadata)
- `--headers, -h` - Print only headers
- `--meta, -m` - Print only metadata
- `--body, -b` - Print only body
- `--verbose, -v` - Verbose output
- `--all` - Show intermediary requests
- `--stream, -S` - Stream response
- `--output, -o` - Save to file
- `--download, -d` - Download mode
- `--continue, -c` - Resume download
- `--quiet, -q` - Suppress output

#### Sessions
- `--session` - Create/reuse session
- `--session-read-only` - Read session without updating

#### Network
- `--offline` - Build request without sending
- `--proxy` - Configure proxy
- `--follow, -F` - Follow redirects
- `--max-redirects` - Redirect limit
- `--max-headers` - Header limit
- `--check-status` - Exit on error status
- `--path-as-is` - Bypass URL normalization
- `--chunked` - Chunked transfer encoding

#### SSL/TLS
- `--verify` - SSL verification control (documented but differently)
- `--ssl` - Protocol version selection (documented but differently)
- `--ciphers` - Cipher list
- `--cert` - Client certificate
- `--cert-key` - Private key
- `--cert-key-pass` - Key passphrase

#### Content Types
- `--json, -j` - JSON serialization
- `--form, -f` - Form serialization
- `--multipart` - Force multipart
- `--boundary` - Custom boundary
- `--raw` - Raw request data
- `--compress, -x` - Compression

#### Authentication (Partial)
- `--ignore-netrc` - Ignore .netrc file
- Digest authentication (http shows it, spie only shows basic/bearer)

#### Troubleshooting
- `--manual` - Show full manual
- `--version` - Show version
- `--traceback` - Print traceback
- `--default-scheme` - Default URL scheme
- `--debug` - Debug mode

## Impact

### User Experience
- **Discoverability:** Users cannot learn about advanced features from help text
- **Learning Curve:** Users must consult external documentation or source code
- **Comparison:** Users comparing http/spie cannot assess feature parity
- **Trust:** Incomplete help may suggest incomplete implementation

### Developer Impact
- **Testing:** Harder to verify if features are intentionally omitted or just undocumented
- **Maintenance:** Help text may drift from actual implementation

## Possible Causes

1. **Intentional Design:** spie may intentionally implement a minimal subset
2. **Work in Progress:** Features may be implemented but not yet documented
3. **Different Philosophy:** spie may favor concise help over comprehensive reference
4. **Implementation Gap:** Help text may not reflect actual capabilities

## Recommendations

### Short Term
1. **Audit Features:** Determine which features are actually implemented in spie
2. **Document Implemented Features:** Update help text to include all working features
3. **Add Disclaimer:** If subset is intentional, add note like "spie implements a focused subset of HTTPie features"

### Medium Term
1. **Add --manual Flag:** Keep --help concise, add --manual for full reference (like http does)
2. **Version Information:** Consider adding --version flag to help users understand capabilities
3. **Feature Matrix:** Create a feature comparison matrix (http vs spie)

### Long Term
1. **Auto-generated Help:** Generate help text from feature implementation to prevent drift
2. **Examples Section:** Add practical examples for complex features
3. **Online Documentation:** Maintain web-based docs for comprehensive reference

## Workarounds

Users can currently:
1. Experiment with http flags to see if spie supports them
2. Read source code or tests to discover features
3. Consult this test suite's documentation

## Testing Impact

This issue does not affect the functional test result (--help flag works correctly), but it does impact:
- Feature discoverability testing
- User experience evaluation
- Documentation completeness testing

## Related

- **Test Report:** features/help-flag.md
- **Feature Checklist:** checklist.md
- **Similar to:** --manual flag (if not implemented), --version flag
