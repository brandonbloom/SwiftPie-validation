# Issue 25232: output-option (--output/-o) not implemented

## Feature
output-option: The `--output` (or `-o`) option for saving response to file

## Problem
spie does not support the `--output` or `-o` option for saving HTTP responses to a file. This is a critical feature for downloading and saving API responses.

## Tested
```bash
spie --output /tmp/test.txt http://localhost:8888/get
spie -o /tmp/test.txt http://localhost:8888/get
```

## Expected
Both commands should:
1. Execute the GET request successfully
2. Save the response (headers and body) to the specified file
3. Suppress stdout output
4. Exit with code 0

## Actual
Both commands fail with:
```
error: unknown option '--output'
error: unknown option '-o'
```

Exit code: 64 (error)

## The Problem
The `--output`/`-o` option is a fundamental HTTPie feature that allows users to save API responses directly to files without using shell redirection. This is essential for:
- Downloading API responses to files
- Saving large responses
- Scripting API calls without output to stdout

The absence of this feature means users cannot save responses to files directly from spie.

## Impact
Critical - Users cannot save API responses to files without using shell redirection workarounds

## Notes
- http command properly supports both `--output` and `-o` forms
- This is listed as feature "output-option" in the checklist (line 37)
- This is a completely unimplemented feature in spie
