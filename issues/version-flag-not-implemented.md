# Issue: Version Flag Not Implemented in spie

**Issue ID:** version-flag-not-implemented
**Severity:** High
**Category:** Missing Feature
**Discovered During:** version-flag feature test
**Date:** 2025-10-31

## Description

The `spie` tool does not support the `--version` flag, which is a standard CLI convention implemented by `http` and expected by users. When users attempt to check the version using `spie --version`, the command fails with an "unknown option" error.

## Evidence

### http --version Behavior
```bash
$ http --version
3.2.4
$ echo $?
0
```

- Exit code: 0 (success)
- Output: Clean version number
- Behavior: Standard and expected

### spie --version Behavior
```bash
$ spie --version
error: unknown option '--version'
$ echo $?
64
```

- Exit code: 64 (command line usage error)
- Output: Error message
- Behavior: Flag not recognized

### Alternative Attempts
```bash
$ spie -v
error: unknown option '-v'
$ echo $?
64
```

```bash
$ spie --help | grep -i version
(no results)
```

- No short form `-v` flag available
- Help text does not mention any version flag

## Impact

### User Experience
- **Basic Functionality:** Users cannot easily determine which version of spie is installed
- **Automation:** Scripts that check version before running (common pattern) will fail
- **Troubleshooting:** Bug reports lack version information context
- **Standards Compliance:** Violates common CLI conventions (--version is nearly universal)

### Development Impact
- **Support:** Harder to diagnose issues without version information
- **Testing:** Cannot programmatically verify tool version in test scripts
- **Documentation:** Cannot reference version-specific features or bugs

### Operational Impact
- **Package Management:** Tools like Homebrew, apt, etc. often use --version to verify installation
- **CI/CD:** Build scripts commonly check tool versions for compatibility
- **Monitoring:** System monitoring tools may expect --version to work

## Comparison with Standards

The `--version` flag is a de facto standard in CLI tools:
- **GNU tools:** ls, grep, sed, awk all support --version
- **Python tools:** python --version, pip --version
- **Node tools:** node --version, npm --version
- **HTTP clients:** curl --version, wget --version
- **HTTPie:** http --version (as shown above)

Exit code 64 indicates "command line usage error" (EX_USAGE from BSD sysexits.h), which is correct for an unknown option, but the flag should exist.

## Root Cause

The `--version` flag (and `-v` short form) is not implemented in the spie argument parser. This appears to be an oversight or incomplete implementation rather than an intentional design decision.

## Recommendations

### Immediate Action (Priority: High)
1. **Implement --version Flag:**
   - Add `--version` flag to spie's argument parser
   - Display version number in clean format (matching http's output style)
   - Exit with code 0 after displaying version

2. **Consider Short Form:**
   - Optionally add `-v` as short form (if not conflicting with verbose flag)
   - Note: http uses `-v` for verbose, so this may not be appropriate

3. **Update Help Text:**
   - Add --version to help documentation
   - Ensure it appears in appropriate section (likely "Troubleshooting" or at bottom)

### Implementation Example

Based on http's behavior, spie should:
```bash
$ spie --version
<version_number>
$ echo $?
0
```

Where `<version_number>` is the current spie version (format: X.Y.Z)

### Testing Requirements

After implementation:
1. Verify `spie --version` displays version and exits with 0
2. Verify output format is clean (version number only or minimal formatting)
3. Verify --help documents the --version flag
4. Test in automation scenarios (scripts, CI/CD)
5. Verify behavior matches http --version (within reason)

## Workarounds

Currently, users have no direct way to check spie version. Possible workarounds:
1. Check package manager: `brew list --versions spie` (Homebrew example)
2. Check git tags if installed from source
3. Look for VERSION file in installation directory
4. Check source code directly

None of these are satisfactory replacements for a proper --version flag.

## Related Issues

- **help-flag-incomplete-docs:** Help text does not mention --version flag
- This is a prerequisite for proper tool usage and automation

## Testing Impact

**Test Status:** FAILED

This is a critical feature gap. The version-flag feature test fails completely because the feature is not implemented. This blocks:
- Version compatibility checking
- Automated testing workflows
- Standard CLI tool expectations

## References

- **Test Report:** /Users/bbloom/Projects/httpie-delta/features/version-flag.md
- **Feature Checklist:** /Users/bbloom/Projects/httpie-delta/checklist.md
- **GNU Coding Standards:** Section 4.8 - Standards for Command Line Interfaces
