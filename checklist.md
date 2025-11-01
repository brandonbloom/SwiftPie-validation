# HTTPie Feature Test Checklist

This checklist contains all features extracted from `http --help` for comprehensive testing.

| Slug | Feature Name | Description | Test Status | Notes |
|------|--------------|-------------|-------------|-------|
| method-argument | HTTP Method | Support for HTTP methods (GET, POST, PUT, DELETE, etc.) with smart defaults | Not Tested | |
| url-argument | Request URL | URL parsing with default scheme, localhost shorthand support (:3000, :/foo) | Not Tested | |
| request-item-headers | Request Items: Headers | Headers with ':' separator (e.g., Referer:https://httpie.io) | Not Tested | |
| request-item-url-params | Request Items: URL Parameters | URL parameters with '==' separator (e.g., search==httpie) | Not Tested | |
| request-item-data-fields | Request Items: Data Fields | Data fields with '=' separator for JSON/form data | Not Tested | |
| request-item-json-fields | Request Items: JSON Fields | Non-string JSON fields with ':=' separator | Not Tested | |
| request-item-form-files | Request Items: Form Files | Form file fields with '@' separator | Not Tested | |
| request-item-data-embed | Request Items: Data Embed | Data field from file with '=@' separator | Not Tested | |
| request-item-json-embed | Request Items: JSON Embed | JSON field from file with ':=@' separator | Not Tested | |
| request-item-escape | Request Items: Escaping | Backslash escape for colliding separators | Not Tested | |
| json-flag | --json, -j | JSON serialization (default), sets Content-Type and Accept headers | Not Tested | |
| form-flag | --form, -f | Form data serialization, auto-detects multipart for file fields | Not Tested | |
| multipart-flag | --multipart | Force multipart/form-data request even without files | Not Tested | |
| boundary-option | --boundary | Custom boundary string for multipart/form-data requests | Not Tested | |
| raw-option | --raw | Pass raw request data without extra processing | Not Tested | |
| compress-flag | --compress, -x | Deflate compression with Content-Encoding header | Not Tested | |
| pretty-option | --pretty | Control output processing (all, colors, format, none) | Not Tested | |
| style-option | --style, -s | Output coloring style selection from 40+ themes | Not Tested | |
| unsorted-flag | --unsorted | Disable all sorting in formatted output | Not Tested | |
| sorted-flag | --sorted | Re-enable all sorting in formatted output | Not Tested | |
| response-charset | --response-charset | Override response encoding for terminal display | Not Tested | |
| response-mime | --response-mime | Override response MIME type for coloring/formatting | Not Tested | |
| format-options | --format-options | Control formatting options (headers.sort, json.indent, etc.) | Not Tested | |
| print-option | --print, -p | Specify output parts (H=req headers, B=req body, h=resp headers, b=resp body, m=metadata) | Not Tested | |
| headers-flag | --headers, -h | Print only response headers (shortcut for --print=h) | Not Tested | |
| meta-flag | --meta, -m | Print only response metadata (shortcut for --print=m) | Not Tested | |
| body-flag | --body, -b | Print only response body (shortcut for --print=b) | Not Tested | |
| verbose-flag | --verbose, -v | Verbose output with multiple levels (-v, -vv) | Not Tested | |
| all-flag | --all | Show intermediary requests/responses (redirects, auth, etc.) | Not Tested | |
| stream-flag | --stream, -S | Stream response body line-by-line like 'tail -f' | Not Tested | |
| output-option | --output, -o | Save output to file instead of stdout | Not Tested | |
| download-flag | --download, -d | Download response body to file with auto-guessed filename | Not Tested | |
| continue-flag | --continue, -c | Resume interrupted download (requires --output) | Not Tested | |
| quiet-flag | --quiet, -q | Suppress stdout/stderr output (multiple levels supported) | Not Tested | |
| session-option | --session | Create/reuse session with persistent headers, auth, cookies | Not Tested | |
| session-read-only | --session-read-only | Read session without updating it | Not Tested | |
| auth-option | --auth, -a | Username/password or token authentication | Not Tested | |
| auth-type-option | --auth-type, -A | Authentication mechanism (basic, bearer, digest) | Not Tested | |
| ignore-netrc-flag | --ignore-netrc | Ignore credentials from .netrc file | Not Tested | |
| offline-flag | --offline | Build and print request without sending it | Not Tested | |
| proxy-option | --proxy | Protocol-to-proxy URL mapping with environment variable support | Not Tested | |
| follow-flag | --follow, -F | Follow 30x Location redirects | Not Tested | |
| max-redirects-option | --max-redirects | Maximum redirect limit (default 30) | Not Tested | |
| max-headers-option | --max-headers | Maximum response headers before giving up | Not Tested | |
| timeout-option | --timeout | Connection timeout in seconds | Not Tested | |
| check-status-flag | --check-status | Exit with error for 4xx/5xx status codes | Not Tested | |
| path-as-is-flag | --path-as-is | Bypass dot segment URL squashing (/../ or /./) | Not Tested | |
| chunked-flag | --chunked | Enable chunked transfer encoding | Not Tested | |
| verify-option | --verify | SSL certificate verification control (yes/no/path) | Not Tested | |
| ssl-option | --ssl | SSL/TLS protocol version selection (ssl2.3, tls1, tls1.1, tls1.2) | Not Tested | |
| ciphers-option | --ciphers | OpenSSL cipher list format string | Not Tested | |
| cert-option | --cert | Local client-side SSL certificate | Not Tested | |
| cert-key-option | --cert-key | Private key for SSL certificate | Not Tested | |
| cert-key-pass-option | --cert-key-pass | Passphrase for private key | Not Tested | |
| ignore-stdin-flag | --ignore-stdin, -I | Do not attempt to read from stdin | Not Tested | |
| help-flag | --help | Show help message and exit | Not Tested | |
| manual-flag | --manual | Show full manual | Not Tested | |
| version-flag | --version | Show version and exit | Not Tested | |
| traceback-flag | --traceback | Print exception traceback on error | Not Tested | |
| default-scheme-option | --default-scheme | Default scheme when not specified in URL | Not Tested | |
| debug-flag | --debug | Debug mode with traceback and debugging info | Not Tested | |

---

**Total Features: 67**

**Feature Categories:**
- Positional Arguments: 10
- Content Types: 5
- Content Processing: 1
- Output Processing: 7
- Output Options: 11
- Sessions: 2
- Authentication: 3
- Network: 9
- SSL: 6
- Troubleshooting: 7

**Last Updated:** 2025-10-31 (Verified against http --help)

**Notes:**
- All features extracted from `http --help` output
- Each flag/option is tracked individually or grouped when closely related
- Test Status values: Not Tested, Passed, Failed, Skipped, In Progress
- Update Notes column with any test observations or compatibility issues
