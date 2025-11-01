# Feature: Request Item URL Parameters

HTTPie allows URL parameters to be specified as request items using the `==` separator. These parameters are appended to the request URL as query string parameters.

## Test Plan

Test the `==` separator for URL parameters with various scenarios:
1. Single URL parameter
2. Multiple URL parameters
3. URL parameters with special characters (spaces, etc.)
4. URL parameters combined with existing query string in URL

## Results

### Test 1: Single URL Parameter

**Command**: `http GET http://localhost:8888/get search==httpie`

#### http output
```json
{
  "args": {
    "search": "httpie"
  },
  "headers": {
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate, zstd",
    "Connection": "keep-alive",
    "Host": "localhost:8888",
    "User-Agent": "HTTPie/3.2.4"
  },
  "origin": "192.168.65.1",
  "url": "http://localhost:8888/get?search=httpie"
}
```

#### spie output
```json
{
  "args": {
    "search": "httpie"
  },
  "headers": {
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate",
    "Accept-Language": "en-US,en;q=0.9",
    "Connection": "keep-alive",
    "Host": "localhost:8888",
    "User-Agent": "spie (unknown version) CFNetwork/3860.100.1 Darwin/25.0.0"
  },
  "origin": "192.168.65.1",
  "url": "http://localhost:8888/get?search=httpie"
}
```

### Test 2: Multiple URL Parameters

**Command**: `http GET http://localhost:8888/get foo==bar baz==qux`

#### http output
```json
{
  "args": {
    "baz": "qux",
    "foo": "bar"
  },
  "headers": {
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate, zstd",
    "Connection": "keep-alive",
    "Host": "localhost:8888",
    "User-Agent": "HTTPie/3.2.4"
  },
  "origin": "192.168.65.1",
  "url": "http://localhost:8888/get?foo=bar&baz=qux"
}
```

#### spie output
```json
{
  "args": {
    "baz": "qux",
    "foo": "bar"
  },
  "headers": {
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate",
    "Accept-Language": "en-US,en;q=0.9",
    "Connection": "keep-alive",
    "Host": "localhost:8888",
    "User-Agent": "spie (unknown version) CFNetwork/3860.100.1 Darwin/25.0.0"
  },
  "origin": "192.168.65.1",
  "url": "http://localhost:8888/get?foo=bar&baz=qux"
}
```

### Test 3: URL Parameters with Spaces

**Command**: `http GET http://localhost:8888/get 'query==hello world'`

#### http output
```json
{
  "args": {
    "query": "hello world"
  },
  "headers": {
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate, zstd",
    "Connection": "keep-alive",
    "Host": "localhost:8888",
    "User-Agent": "HTTPie/3.2.4"
  },
  "origin": "192.168.65.1",
  "url": "http://localhost:8888/get?query=hello+world"
}
```

#### spie output
```json
{
  "args": {
    "query": "hello world"
  },
  "headers": {
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate",
    "Accept-Language": "en-US,en;q=0.9",
    "Connection": "keep-alive",
    "Host": "localhost:8888",
    "User-Agent": "spie (unknown version) CFNetwork/3860.100.1 Darwin/25.0.0"
  },
  "origin": "192.168.65.1",
  "url": "http://localhost:8888/get?query=hello world"
}
```

### Test 4: URL Parameters with Existing Query String

**Command**: `http GET 'http://localhost:8888/get?existing=param' new==value`

#### http output
```json
{
  "args": {
    "existing": "param",
    "new": "value"
  },
  "headers": {
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate, zstd",
    "Connection": "keep-alive",
    "Host": "localhost:8888",
    "User-Agent": "HTTPie/3.2.4"
  },
  "origin": "192.168.65.1",
  "url": "http://localhost:8888/get?existing=param&new=value"
}
```

#### spie output
```json
{
  "args": {
    "existing": "param",
    "new": "value"
  },
  "headers": {
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate",
    "Accept-Language": "en-US,en;q=0.9",
    "Connection": "keep-alive",
    "Host": "localhost:8888",
    "User-Agent": "spie (unknown version) CFNetwork/3860.100.1 Darwin/25.0.0"
  },
  "origin": "192.168.65.1",
  "url": "http://localhost:8888/get?existing=param&new=value"
}
```

## Comparison

### Functional Behavior
Both `http` and `spie` correctly:
- Recognize the `==` separator for URL parameters
- Append parameters to the query string
- Handle multiple URL parameters
- Combine with existing query strings
- Pass the parameters to the server correctly (as evidenced by the `args` in the response)

### URL Encoding Difference

There is a **minor difference in URL encoding** for spaces:
- `http`: Encodes spaces as `+` in the URL (`hello+world`)
- `spie`: Does not encode spaces, shows raw space (`hello world`)

However, both implementations result in the **same query parameter value** received by the server (`"query": "hello world"`), so this is a cosmetic difference in URL representation, not a functional issue.

### Request Headers

Both implementations include slightly different headers:
- `http` includes: `Accept-Encoding: gzip, deflate, zstd`
- `spie` includes: `Accept-Language: en-US,en;q=0.9` and `Accept-Encoding: gzip, deflate`

These differences are not related to URL parameters, so they don't affect the feature test.

## Status

**PASSED** - Both implementations correctly support URL parameters using the `==` separator. The minor URL encoding difference for spaces does not affect functionality.
