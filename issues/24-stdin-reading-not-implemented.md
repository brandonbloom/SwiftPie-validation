# Issue 24: stdin Reading Not Implemented

**Feature**: ignore-stdin-flag
**Impact**: Critical
**Type**: Missing Core Functionality

## Tested

```bash
# Test 1: Piping JSON to POST request without --ignore-stdin
echo '{"piped":"data"}' | http POST http://localhost:8888/post
echo '{"piped":"data"}' | spie POST http://localhost:8888/post

# Test 2: Piping JSON with --ignore-stdin flag
echo '{"piped":"data"}' | http -I POST http://localhost:8888/post
echo '{"piped":"data"}' | spie -I POST http://localhost:8888/post

# Test 3: Piping stdin with explicit data fields
echo '{"ignored":"data"}' | http POST http://localhost:8888/post field=value
echo '{"ignored":"data"}' | spie POST http://localhost:8888/post field=value
```

## Expected

**HTTPie (http) behavior:**

1. **Default (no -I flag)**: Reads from stdin and sends piped data as request body
   - Server receives: `{"data": "{\"piped\":\"data\"}\n", "json": {"piped": "data"}}`
   - Content-Length: 17

2. **With -I flag**: Ignores stdin
   - Server receives: `{"data": "", "json": null}`
   - Content-Length: 0

3. **With stdin + explicit fields**: Errors and tells user to use --ignore-stdin
   ```
   error: Request body (from stdin, --raw or a file) and request data (key=value)
   cannot be mixed. Pass --ignore-stdin to let key/value take priority.
   ```

## Actual

**spie behavior:**

1. **Default (no -I flag)**: Does NOT read from stdin (ignores it completely)
   - Server receives: `{"data": "", "json": null}`
   - Content-Length: 0

2. **With -I flag**: Still ignores stdin (same as default)
   - Server receives: `{"data": "", "json": null}`
   - Content-Length: 0

3. **With stdin + explicit fields**: Silently ignores stdin, no error or warning
   - Server receives: `{"data": "{\"field\":\"value\"}", "json": {"field": "value"}}`
   - Uses explicit field, ignores piped data

## The Problem

**spie does not implement stdin reading at all**. This is a critical missing feature that breaks common HTTPie workflows:

1. **Piping workflows don't work**: Common patterns like `cat data.json | spie POST /endpoint` or `echo '{}' | spie POST /api` fail silently
2. **The -I flag is non-functional**: Since stdin is never read, the --ignore-stdin flag has no observable effect
3. **No conflict detection**: spie doesn't warn users when stdin is piped but ignored
4. **Silent failure**: Users expect their piped data to be sent, but it's silently discarded

This affects a fundamental use case for HTTPie: piping JSON/data from other commands or files directly into HTTP requests.

## Impact

**Critical** - This breaks a core HTTPie feature that many users rely on for:
- Scripting workflows that generate JSON dynamically
- Piping output from other tools (jq, cat, etc.)
- Interactive shell usage where stdin is commonly used
- Any use case documented in HTTPie's examples that involves piping data

## Examples of Broken Workflows

```bash
# Generate JSON and send it - BROKEN in spie
jq -n '{name: "test"}' | spie POST http://api.example.com/users

# Send file contents - BROKEN in spie
cat request.json | spie POST http://api.example.com/data

# Send heredoc - BROKEN in spie
spie POST http://api.example.com/data <<EOF
{
  "key": "value"
}
EOF
```

All of these work in HTTPie but silently fail in spie (sending empty body instead).
