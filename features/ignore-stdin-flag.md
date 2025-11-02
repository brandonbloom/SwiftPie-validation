# Feature: --ignore-stdin, -I

## Description
Do not attempt to read stdin. This flag has two effects:
1. Skip reading from stdin (ignores piped input)
2. Disable interactive password prompts

## Test Plan

### Test 1: Stdin Reading with Piped JSON
Without `-I`, both tools should read JSON from stdin when using POST.
With `-I`, both tools should ignore piped input.

**Commands:**
```bash
# Without --ignore-stdin: should read from stdin
echo '{"key":"value"}' | http POST localhost:8888/post
echo '{"key":"value"}' | spie POST localhost:8888/post

# With --ignore-stdin: should ignore stdin
echo '{"key":"value"}' | http -I POST localhost:8888/post
echo '{"key":"value"}' | spie -I POST localhost:8888/post
```

### Test 2: Stdin Reading with Explicit Data Fields
Test interaction between piped stdin and explicit data fields.

**Commands:**
```bash
# With explicit fields, stdin should be ignored even without -I
echo '{"ignored":"data"}' | http POST localhost:8888/post field=value
echo '{"ignored":"data"}' | spie POST localhost:8888/post field=value
```

### Test 3: Password Prompt Suppression
**Note**: This test is blocked in non-interactive environment. Password prompts require TTY interaction which is not available in automated testing. This would need manual testing or a TTY-based test framework.

## Expected Behavior (http baseline)

### Test 1: Piped JSON
- Without `-I`: JSON from stdin should be sent as request body
- With `-I`: No body should be sent (stdin ignored)

### Test 2: Explicit Fields
- Piped stdin should be ignored when explicit request items are provided

## Test Results

### Test 1: Piped JSON Without --ignore-stdin

**http:**
```bash
$ echo '{"piped":"data"}' | http POST http://localhost:8888/post
```
Result: Reads from stdin and sends JSON body. Server receives:
```json
{
  "data": "{\"piped\":\"data\"}\n",
  "json": {"piped": "data"},
  "headers": {"Content-Type": "application/json", "Content-Length": "17"}
}
```

**spie:**
```bash
$ echo '{"piped":"data"}' | spie POST http://localhost:8888/post
```
Result: Does NOT read from stdin. Server receives:
```json
{
  "data": "",
  "json": null,
  "headers": {"Content-Length": "0"}
}
```

**Difference**: spie ignores stdin even without the -I flag, while http reads from stdin by default.

### Test 2: Piped JSON With --ignore-stdin

**http:**
```bash
$ echo '{"piped":"data"}' | http -I POST http://localhost:8888/post
```
Result: Ignores stdin. Server receives:
```json
{
  "data": "",
  "json": null,
  "headers": {"Content-Length": "0"}
}
```

**spie:**
```bash
$ echo '{"piped":"data"}' | spie -I POST http://localhost:8888/post
```
Result: Ignores stdin. Server receives:
```json
{
  "data": "",
  "json": null,
  "headers": {"Content-Length": "0"}
}
```

**Difference**: Both behave identically with -I flag (both ignore stdin).

### Test 3: Piped Stdin with Explicit Data Fields

**http:**
```bash
$ echo '{"ignored":"data"}' | http POST http://localhost:8888/post field=value
```
Result: **Error** - exits with code 1 and error message:
```
error:
    Request body (from stdin, --raw or a file) and request data (key=value)
cannot be mixed. Pass --ignore-stdin to let key/value take priority.
```

**spie:**
```bash
$ echo '{"ignored":"data"}' | spie POST http://localhost:8888/post field=value
```
Result: Automatically ignores stdin and uses explicit field. Server receives:
```json
{
  "data": "{\"field\":\"value\"}",
  "json": {"field": "value"},
  "headers": {"Content-Type": "application/json", "Content-Length": "17"}
}
```

**Difference**: http requires explicit -I flag to resolve conflict; spie implicitly ignores stdin when explicit fields are present.

### Test 4: With --ignore-stdin and Explicit Fields

**http:**
```bash
$ echo '{"ignored":"data"}' | http -I POST http://localhost:8888/post field=value
```
Result: Ignores stdin and uses explicit field. Server receives:
```json
{
  "data": "{\"field\": \"value\"}",
  "json": {"field": "value"},
  "headers": {"Content-Type": "application/json", "Content-Length": "18"}
}
```

**Difference**: Both behave identically when -I is explicitly provided with fields.

## Comparison

### Major Issue: spie Never Reads stdin

**spie does not read from stdin at all**, even when piped data is available and no -I flag is provided. This is a fundamental deviation from HTTPie's behavior:

1. **Default behavior differs**: http reads stdin by default; spie never reads stdin
2. **The -I flag is redundant in spie**: Since spie already ignores stdin by default, the -I flag has no observable effect
3. **Conflict detection missing**: http detects stdin+fields conflicts and errors; spie silently ignores stdin

### What Works

- The -I flag is accepted by both tools without error
- When explicit request fields are provided, both tools (eventually) use those fields

## Status
Failed

## Notes
- Password prompt testing is blocked due to non-interactive environment (requires TTY)
- The core functionality (reading stdin) is completely missing from spie
- This is a critical feature gap that affects piping workflows like: `cat data.json | spie POST /endpoint`
- The -I flag exists in spie but is non-functional since stdin reading is not implemented
