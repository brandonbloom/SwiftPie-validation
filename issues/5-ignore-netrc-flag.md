# Issue: 25231-ignore-netrc-flag

**Feature**: ignore-netrc-flag
**Issue ID**: 25231
**Severity**: high

## What Was Tested

Checked for the presence and functionality of the `--ignore-netrc` flag in both `http` and `spie` CLIs.

```bash
# Check if flag exists in help
http --help | grep -i netrc
spie --help | grep -i netrc
```

## Expected Behavior

The `--ignore-netrc` flag should be available in both `http` and `spie` implementations to allow users to ignore credentials stored in the .netrc file.

## Actual Behavior

- **http**: The `--ignore-netrc` flag exists and shows in help with description: "Ignore credentials from .netrc."
- **spie**: The `--ignore-netrc` flag does NOT exist in spie and does not appear in `spie --help`

## The Problem

The `--ignore-netrc` flag is a core HTTPie feature that allows users to explicitly disable automatic credential loading from .netrc files. Without this flag in spie, users cannot replicate http's behavior when they need to force fresh authentication without using stored credentials.

This creates a functional gap where spie cannot fully replace http, as users migrating to spie would lose the ability to control .netrc credential usage.

## Impact

**Functional Gap**: Users cannot ignore .netrc credentials in spie, limiting its compatibility with http.

**Severity Classification**:
- **Critical for compatibility**: This flag is documented in http's help and represents a core authentication feature
- **High for functionality**: Users relying on this feature will find spie unusable for their workflow
- **Medium for immediate use**: Not all users rely on .netrc credentials, but those who do cannot work around it

## Notes

- The flag is documented in the official http help output
- This is a straightforward feature addition in terms of implementation complexity (flag parsing + behavior)
- The .netrc file integration is a standard Unix/Linux authentication mechanism used by curl, wget, and other tools
- Without this flag, spie has incomplete authentication feature parity with http
