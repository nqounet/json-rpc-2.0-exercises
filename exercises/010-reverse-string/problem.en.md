# Exercise 010 — reverse-string

## Objective

- Implement a JSON-RPC 2.0 method named `reverse` that takes a single string parameter and returns the string reversed.

## Specification

### JSON-RPC fields

- `jsonrpc`: must be the string `"2.0"`.
- `method`: `"reverse"`.
- `params`: positional array with a single string value, e.g. `["hello"]`.
- `result`: the reversed string, e.g. `"olleh"`.

### Behavior and validation

- If the parameter is the empty string, the result is the empty string.
- If the parameter is not provided or is not a string, return `-32602` Invalid params.
- Notifications (no `id`) produce no response.
- Implementations should reverse Unicode code points in a reasonable manner.

## Error handling

- Use standard JSON-RPC error codes where applicable (`-32700`, `-32600`, `-32601`, `-32602`, `-32603`).

## Examples

Request:
```json
{"jsonrpc":"2.0","method":"reverse","params":["hello"],"id":1}
```

Response:
```json
{"jsonrpc":"2.0","result":"olleh","id":1}
```

## Acceptance criteria

- Reverse ASCII and Unicode strings correctly; invalid-type cases should return `-32602`.

## Difficulty

- ⭐⭐
