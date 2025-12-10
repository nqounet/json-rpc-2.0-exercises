# Exercise 009 — echo-with-meta (English)

Goal:
- Implement a JSON-RPC 2.0 `echoWithMeta` method that echoes the provided payload and returns server-generated metadata. The twist: keys in the client-supplied `meta` that start with an underscore must be omitted from the response.

Requirements:
- `jsonrpc` must be `"2.0"`.
- `method` must be `"echoWithMeta"`.
- `params` must be an object containing at least `payload` (any JSON value). Optionally `meta` (an object) may be provided.
- The `result` must be an object containing at least:
  - `payload`: the input `payload` echoed back verbatim
  - `meta`: the merged metadata object where client-supplied `meta` keys that start with `_` are excluded, and the server always adds a `timestamp` (ISO 8601 string)
- If `params.meta` is present but not an object, return `-32602` (Invalid params).
- Do not respond to notifications.

Acceptance criteria:
- Payload is echoed; meta is filtered to remove underscore-prefixed keys and includes server `timestamp`.
- Invalid JSON -> `-32700` (Parse error) and `id` null.
- Follow JSON-RPC 2.0 error handling for other invalid requests.

Difficulty: 2/5

Example:
```json
{"jsonrpc":"2.0","method":"echoWithMeta","params":{"payload":{"x":1},"meta":{"user":"alice","_token":"secret"}},"id":1}
```
Expected response (timestamp varies):
```json
{"jsonrpc":"2.0","result":{"payload":{"x":1},"meta":{"user":"alice","timestamp":"2020-01-01T12:00:00Z"}},"id":1}
```
