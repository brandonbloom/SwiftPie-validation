# Feature: stream-flag (Streaming Output)

**Slug:** stream-flag

**Description:** Stream response body line-by-line like 'tail -f' using the `--stream` (shorthand `-S`) flag. Without --stream and with --pretty (either set or implied), HTTPie fetches the whole response before outputting the processed data. The stream flag is useful for long-lived responses such as server-sent events or streaming APIs.

## Test Plan

This test verifies that both `http` and `spie` correctly handle the `--stream` flag:

1. **Stream flag with streaming endpoint**: Test `--stream` with `/stream/n` endpoint
2. **Stream flag shorthand (`-S`)**: Test short form of the flag
3. **Stream flag with pretty formatting**: Test streaming with prettified output
4. **Stream flag with print options**: Test combined with `--print` flag
5. **Comparison with non-streaming behavior**: Verify default buffering behavior differs
6. **Stream flag error handling**: Test with non-streaming endpoints

**Test Endpoint:** http://localhost:8888/stream/N (streams N JSON objects, one per line)

### Prerequisites Check

The test requires:
- `http` CLI available (installed)
- `spie` CLI available (built in ./bin/spie)
- httpbin server running on localhost:8888
- Streaming endpoint accessible

All prerequisites are met.

### Commands to be Tested

- `http --stream GET http://localhost:8888/stream/5`
- `http -S GET http://localhost:8888/stream/5`
- `http --stream --print=b GET http://localhost:8888/stream/5`
- `http --pretty=all GET http://localhost:8888/stream/5` (without stream)
- `http --stream --pretty=all GET http://localhost:8888/stream/5` (with stream)
- `spie --stream GET http://localhost:8888/stream/5`
- `spie -S GET http://localhost:8888/stream/5`

## Expected Behavior

According to httpie documentation:
- `--stream` enables line-by-line streaming output of the response body
- `-S` is the short form
- When streaming is enabled with pretty formatting, each line of the response is prettified as it arrives
- Without stream flag, the entire response is buffered before output
- Stream flag is particularly useful for long-lived HTTP connections (Twitter API, Server-Sent Events, etc.)

## Test Results

### Summary
❌ **FAILED** - The `--stream` flag is not implemented in `spie`. The `http` CLI supports streaming while `spie` does not recognize the flag.

### Detailed Test Results

| Test Case | http Result | spie Result | Status |
|-----------|------------|------------|--------|
| `--stream` flag with `/stream/5` | ✅ Streams 5 JSON objects line-by-line | ❌ Error: unknown option '--stream' | FAIL |
| `-S` shorthand with `/stream/5` | ✅ Streams 5 JSON objects line-by-line | ❌ Error: unknown option '-S' | FAIL |
| `--stream --print=b` with `/stream/5` | ✅ Outputs body only, line-by-line | ❌ Error: unknown option '--stream' | FAIL |
| Default (no stream) with `/stream/5` | ✅ Buffers and outputs all lines | N/A | PASS |
| Pretty formatting with `--stream` | ✅ Works with color output | ❌ Not supported | FAIL |

### Test Observations

1. **Stream Flag Not Implemented**: `spie` does not recognize `--stream` or `-S` flags at all
2. **http Streaming Works**: The `http` CLI correctly streams responses line-by-line
3. **Error Code**: `spie` returns exit code 64 (unknown option) when `--stream` is used
4. **Help Output**: Checking `spie --help` shows no mention of streaming capability

### Key Differences

- **http** supports `--stream` and `-S` for streaming output
- **spie** does not support streaming at all - the flag is completely absent from the implementation
- **http** can combine streaming with `--pretty` and `--print` options
- **spie** has no equivalent streaming feature in its current implementation

### Deviations from Expected Behavior

**DEVIATION**: `spie` does not implement the `--stream` / `-S` flag at all. This is a missing feature compared to HTTPie's standard functionality. The flag is essential for handling long-lived HTTP connections and streaming APIs.

