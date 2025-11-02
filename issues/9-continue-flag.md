# Issue 25234: continue-flag (--continue/-c) not implemented

## Feature
continue-flag: The `--continue` (or `-c`) flag for resuming interrupted downloads

## Problem
spie does not support the `--continue` or `-c` flag. This flag is essential for resuming partially downloaded files from where they left off.

## Tested
```bash
spie --continue POST http://localhost:8888/post foo=bar --ignore-stdin
spie -c POST http://localhost:8888/post foo=bar --ignore-stdin
spie --download --continue --output file.txt POST http://localhost:8888/post foo=bar
```

## Expected
The command should:
1. Recognize the `--continue` flag
2. When used with `--download --output`, resume from the existing file size
3. Send Range HTTP header to server for resumption
4. Complete the download successfully
5. Exit with code 0

## Actual
All commands fail with:
```
error: unknown option '--continue'
error: unknown option '--download'
```

Exit code: 64 (error)

## The Problem
The `--continue` flag is critical for downloading large files reliably:
- Allows resuming interrupted downloads (network failures)
- Essential for unreliable connections
- Reduces bandwidth waste on retries
- Standard behavior in download tools like wget and curl

The absence of this feature means users cannot reliably download large files that may be interrupted.

## Impact
Critical - Users cannot resume interrupted downloads (critical feature gap)

## Notes
- http command properly supports both `--continue` and `-c` forms
- This is listed as feature "continue-flag" in the checklist (line 39)
- This is a completely unimplemented feature in spie
- Works in conjunction with `--download` in http
- Depends on HTTP Range header support
