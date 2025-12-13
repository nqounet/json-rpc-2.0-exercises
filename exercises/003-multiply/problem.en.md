# Exercise 003 — multiply

## Objective

- Implement a JSON-RPC 2.0 method named `multiply` that multiplies numbers.

## Specification

### JSON-RPC fields

- `jsonrpc`: must be the string `"2.0"` in requests and responses.
- `method`: `"multiply"`.
- `params`:
  - Positional: an array of numbers to multiply.
  - Named: an object containing a key `values` whose value is an array of numbers.
- `result`: on success return a JSON number equal to the product of the numbers.

### Behavior and validation

- If `params` is an array, treat it as a list of numbers to multiply.
- If `params` is an object and contains a key `values` (an array), use that array of numbers.
- If any item is not a number, return JSON-RPC error `-32602` with message `Invalid params: items must be numbers`.
- If there are no numbers provided, return JSON-RPC error `-32602` with message `Invalid params: at least one number required`.
- Support notifications (requests without `id`) by not returning a response.

## Error handling

- Use standard JSON-RPC error codes where applicable:
  - `-32700` Parse error — invalid JSON (respond with `id: null`).
  - `-32600` Invalid Request — not a valid Request object.
  - `-32601` Method not found — unknown method.
  - `-32602` Invalid params — missing parameters or wrong types.
  - `-32603` Internal error — server-side exception.
- Notifications MUST NOT produce a response.
- Batch requests: process each element independently; omit responses for notifications. An empty batch `[]` is invalid and should produce a single `-32600` response with `id: null`.

## Edge cases / Notes

- Reject non-number items (including numeric strings).
- Treat floating-point semantics according to the host language.

## Examples

Request:
```json
{"jsonrpc":"2.0","method":"multiply","params":[2,3,4],"id":1}
```

Response:
```json
{"jsonrpc":"2.0","result":24,"id":1}
```

Request:
```json
{"jsonrpc":"2.0","method":"multiply","params":{"values":[5,6]},"id":2}
```

Response:
```json
{"jsonrpc":"2.0","result":30,"id":2}
```

## Acceptance criteria

- The implementation returns correct `result` or appropriate `error` for each fixture in `tests/003-multiply`.
- Invalid JSON must produce `-32700` (Parse error) with `id: null`.
- Follow JSON-RPC 2.0 rules for invalid requests and unknown methods.

## Difficulty

- ⭐⭐

## Tests

- Provide fixtures under `tests/003-multiply/` including at least `request-0001.json` / `expected-0001.json` (happy), `0002` (edge), and `0003` (invalid).
