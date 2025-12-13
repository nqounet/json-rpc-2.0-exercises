# Exercise 009 — echo-with-meta

## Objective

- Implement a JSON-RPC 2.0 `echoWithMeta` method that echoes the provided payload and returns server-generated metadata while filtering client meta keys that start with an underscore.

## Specification

### JSON-RPC fields

- `jsonrpc`: must be the string `"2.0"` in requests and responses.
- `method`: `"echoWithMeta"`.
- `params`: an object containing at least `payload` (any JSON value). Optionally `meta` (an object) may be provided.
- `result`: an object containing at least `payload` (echoed) and `meta` (merged metadata where client-supplied keys starting with `_` are omitted and server adds a `timestamp`).

### Behavior and validation

- Echo `payload` verbatim in the `result`.
- If `params.meta` is present it must be an object; otherwise return `-32602` Invalid params.
- Client-supplied `meta` keys that start with an underscore (`_`) must be excluded from the response `meta`.
- The server must add a `timestamp` (ISO 8601 string) into the returned `meta`.
- Do not respond to notifications.

## Error handling

- Use standard JSON-RPC error codes where applicable (`-32700`, `-32600`, `-32601`, `-32602`, `-32603`).

## Edge cases / Notes

- `timestamp` value is server-generated and not fixed in tests; tests should allow any valid ISO 8601 string.

## Examples

Request:
```json
{"jsonrpc":"2.0","method":"echoWithMeta","params":{"payload":{"x":1},"meta":{"user":"alice","_token":"secret"}},"id":1}
```

Expected response (timestamp varies):
```json
{"jsonrpc":"2.0","result":{"payload":{"x":1},"meta":{"user":"alice","timestamp":"2020-01-01T12:00:00Z"}},"id":1}
```

## Acceptance criteria

- Payload is echoed; meta is filtered to remove underscore-prefixed keys and includes server `timestamp`.
- Invalid JSON -> `-32700` (Parse error) and `id` null.

## Difficulty

- ⭐⭐
