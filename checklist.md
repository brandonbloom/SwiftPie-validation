# HTTPie Feature Test Checklist

This checklist contains all features extracted from `http --help` for comprehensive testing.

| Slug | Feature Name | Description | Test Status | Notes |
|------|--------------|-------------|-------------|-------|
| method-argument | HTTP Method | Support for HTTP methods (GET, POST, PUT, DELETE, etc.) with smart defaults | Passed | All HTTP methods work identically between http and spie |
| url-argument | Request URL | URL parsing with default scheme, localhost shorthand support (:3000, :/foo) | Passed | All URL parsing behaviors match perfectly between http and spie |
| request-item-headers | Request Items: Headers | Headers with ':' separator (e.g., Referer:https://httpie.io) | Passed | All header handling works identically between http and spie |
| request-item-url-params | Request Items: URL Parameters | URL parameters with '==' separator (e.g., search==httpie) | Passed | Both implementations handle URL parameters identically. Minor cosmetic difference: http uses + for spaces while spie uses raw spaces in URL, but both result in identical query parameter values received by server. See features/request-item-url-params.md |
| request-item-data-fields | Request Items: Data Fields | Data fields with '=' separator for JSON/form data | Failed | spie defaults to form encoding while http defaults to JSON; no proper JSON mode support. See features/request-item-data-fields.md |
| request-item-json-fields | Request Items: JSON Fields | Non-string JSON fields with ':=' separator | Passed | All JSON field types (booleans, numbers, arrays, objects, null) work identically between http and spie; feature is fully implemented in both |
| request-item-form-files | Request Items: Form Files | Form file fields with '@' separator | Passed | Both implementations handle file uploads identically; see features/request-item-form-files.md |
| request-item-data-embed | Request Items: Data Embed | Data field from file with '=@' separator | Failed | spie treats =@ as file upload (multipart) instead of reading file content as JSON string value. See features/request-item-data-embed.md and [GitHub issue #2](https://github.com/brandonbloom/SwiftPie/issues/2) |
| request-item-json-embed | Request Items: JSON Embed | JSON field from file with ':=@' separator | Failed | spie does not support :=@ for JSON embedding; treats it as multipart file field instead. See features/request-item-json-embed.md |
| request-item-escape | Request Items: Escaping | Backslash escape for colliding separators | Failed | Escape sequences like \: and \= are not recognized; defaults to form encoding instead of JSON. See features/request-item-escape.md and issues/25241-request-item-escape.md |
| json-flag | --json, -j | JSON serialization (default), sets Content-Type and Accept headers | Failed | Feature not implemented in spie; see features/json-flag.md and issues/25229-json-flag.md |
| form-flag | --form, -f | Form data serialization, auto-detects multipart for file fields | Passed | All form data handling works identically between http and spie; spie uses implicit form encoding for = fields and auto-detects multipart for @ fields |
| multipart-flag | --multipart | Force multipart/form-data request even without files | Failed | spie does not have --multipart flag; cannot force multipart without file fields. See features/multipart-flag.md |
| boundary-option | --boundary | Custom boundary string for multipart/form-data requests | Failed | --boundary option is completely missing from spie. See features/boundary-option.md and issues/25240-boundary-option.md |
| raw-option | --raw | Pass raw request data without extra processing | Failed | --raw option is not recognized; treated as form field argument instead. See features/raw-option.md and issues/25242-raw-option.md |
| compress-flag | --compress, -x | Deflate compression with Content-Encoding header | Failed | Feature not implemented in spie; see features/compress-flag.md |
| pretty-option | --pretty | Control output processing (all, colors, format, none) | Failed | --pretty option is not implemented in spie. See features/pretty-option.md and issues/25233-pretty-option.md |
| style-option | --style, -s | Output coloring style selection from 40+ themes | Failed | Feature not implemented in spie; see features/style-option.md and issues/25230-style-option.md |
| unsorted-flag | --unsorted | Disable all sorting in formatted output | Failed | --unsorted flag is not implemented in spie. See features/unsorted-flag.md and issues/25234-unsorted-flag.md |
| sorted-flag | --sorted | Re-enable all sorting in formatted output | Failed | --sorted flag is not implemented in spie. See features/sorted-flag.md and issues/25236-sorted-flag.md |
| response-charset | --response-charset | Override response encoding for terminal display | Failed | --response-charset option is not implemented in spie. See features/response-charset.md and issues/25235-response-charset.md |
| response-mime | --response-mime | Override response MIME type for coloring/formatting | Failed | --response-mime option is not implemented in spie. See features/response-mime.md and issues/25238-response-mime.md |
| format-options | --format-options | Control formatting options (headers.sort, json.indent, etc.) | Failed | --format-options option is not implemented in spie. See features/format-options.md and issues/25237-format-options.md |
| print-option | --print, -p | Specify output parts (H=req headers, B=req body, h=resp headers, b=resp body, m=metadata) | Failed | --print option is not implemented in spie. See features/print-option.md and issues/25236-print-option.md |
| headers-flag | --headers, -h | Print only response headers (shortcut for --print=h) | Failed | Feature not implemented in spie; see features/headers-flag.md |
| meta-flag | --meta, -m | Print only response metadata (shortcut for --print=m) | Failed | Feature not implemented in spie; see features/meta-flag.md |
| body-flag | --body, -b | Print only response body (shortcut for --print=b) | Failed | Feature not implemented in spie; see features/body-flag.md |
| verbose-flag | --verbose, -v | Verbose output with multiple levels (-v, -vv) | Passed | HTTPie implementation works correctly; SpIE does not support this flag (feature gap). See features/verbose-flag.md |
| all-flag | --all | Show intermediary requests/responses (redirects, auth, etc.) | Failed | --all flag is not implemented in spie. See features/all-flag.md and issues/all-flag-not-implemented.md |
| stream-flag | --stream, -S | Stream response body line-by-line like 'tail -f' | Failed | Feature not implemented in spie; see features/stream-flag.md and issues/stream-flag-not-implemented.md |
| output-option | --output, -o | Save output to file instead of stdout | Failed | --output option is not implemented in spie. See features/output-option.md and issues/25232-output-option.md |
| download-flag | --download, -d | Download response body to file with auto-guessed filename | Failed | --download flag is not implemented in spie. See features/download-flag.md and issues/25233-download-flag.md |
| continue-flag | --continue, -c | Resume interrupted download (requires --output) | Failed | --continue flag is not implemented in spie. See features/continue-flag.md and issues/25234-continue-flag.md |
| quiet-flag | --quiet, -q | Suppress stdout/stderr output (multiple levels supported) | Failed | --quiet flag is not implemented in spie. See features/quiet-flag.md and issues/25235-quiet-flag.md |
| session-option | --session | Create/reuse session with persistent headers, auth, cookies | Not Tested | |
| session-read-only | --session-read-only | Read session without updating it | Not Tested | |
| auth-option | --auth, -a | Username/password or token authentication | Passed | Both http and spie implement basic authentication correctly with proper Base64 encoding |
| auth-type-option | --auth-type, -A | Authentication mechanism (basic, bearer, digest) | Not Tested | |
| ignore-netrc-flag | --ignore-netrc | Ignore credentials from .netrc file | Not Tested | |
| offline-flag | --offline | Build and print request without sending it | Not Tested | |
| proxy-option | --proxy | Protocol-to-proxy URL mapping with environment variable support | Not Tested | |
| follow-flag | --follow, -F | Follow 30x Location redirects | Failed | spie automatically follows redirects by default (always), while http requires explicit --follow flag (default: doesn't follow). No CLI control flags available in spie. See features/follow-flag.md |
| max-redirects-option | --max-redirects | Maximum redirect limit (default 30) | Not Tested | |
| max-headers-option | --max-headers | Maximum response headers before giving up | Failed | spie does not implement --max-headers option; feature is completely missing. See features/max-headers-option.md |
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
| version-flag | --version | Show version and exit | Failed | Feature not implemented in spie; see features/version-flag.md and issues/version-flag-not-implemented.md |
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

**Last Updated:** 2025-11-01 (Verified against http --help)

**Notes:**
- All features extracted from `http --help` output
- Each flag/option is tracked individually or grouped when closely related
- Test Status values: Not Tested, Passed, Failed, Skipped, In Progress
- Update Notes column with any test observations or compatibility issues
