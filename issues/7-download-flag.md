# Issue 25233: download-flag (--download/-d) not implemented

## Feature
download-flag: The `--download` (or `-d`) flag for downloading response body to file

## Problem
spie does not support the `--download` or `-d` flag. This flag is essential for downloading API responses to files (similar to wget behavior).

## Tested
```bash
spie --download POST http://localhost:8888/post foo=bar --ignore-stdin
spie -d POST http://localhost:8888/post foo=bar --ignore-stdin
```

## Expected
The command should:
1. Execute the POST request successfully
2. With `--output`, save the response body to the specified file
3. Show appropriate progress or status messages
4. Exit with code 0

## Actual
Both commands fail with:
```
error: unknown option '--download'
error: unknown option '-d'
```

Exit code: 64 (error)

## The Problem
The `--download` flag is a critical feature for downloading API responses. When combined with `--output`, it specifies to save only the response body (not headers) to a file. This is essential for:
- Downloading files from APIs
- Saving responses without manually redirecting
- Creating scriptable download workflows
- Getting progress information during downloads

The absence of this feature prevents users from easily downloading API responses.

## Impact
Critical - Users cannot download API responses to files (critical feature gap)

## Notes
- http command properly supports both `--download` and `-d` forms
- This is listed as feature "download-flag" in the checklist (line 38)
- This is a completely unimplemented feature in spie
- Often used in conjunction with `--output` to specify filename
