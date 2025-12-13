# Exercise 006 — matrix-multiply

## Objective

- Implement a JSON-RPC 2.0 `matmul` method that computes matrix multiplication.

## Specification

### JSON-RPC fields

- `jsonrpc`: must be the string `"2.0"` in requests and responses.
- `method`: `"matmul"`.
- `params`: an object containing keys `a` and `b`, each a 2D numeric array (matrix).
- `result`: the matrix product A × B as a 2D array.

### Behavior and validation

- Matrices `a` and `b` must be non-empty 2D numeric arrays with consistent row lengths (no ragged rows).
- Dimensions must be compatible for multiplication (columns of `a` == rows of `b`).
- If elements are non-numeric, matrices are ragged, or dimensions are incompatible, return `-32602` Invalid params with message `Invalid params: matrices must be numeric and dimensions must match`.
- Empty matrices are invalid.
- Do not respond to notifications.

## Error handling

- Use standard JSON-RPC error codes where applicable:
  - `-32700` Parse error — invalid JSON (respond with `id: null`).
  - `-32600` Invalid Request — not a valid Request object.
  - `-32601` Method not found — unknown method.
  - `-32602` Invalid params — missing parameters or wrong types.
  - `-32603` Internal error — server-side exception.

## Edge cases / Notes

- Implementations should validate numeric types and row lengths before attempting multiplication.

## Examples

Request:
```json
{"jsonrpc":"2.0","method":"matmul","params":{"a":[[1,2],[3,4]],"b":[[5,6],[7,8]]},"id":1}
```

Expected response:
```json
{"jsonrpc":"2.0","result":[[19,22],[43,50]],"id":1}
```

## Acceptance criteria

- Correct matrix multiplication for valid inputs; appropriate JSON-RPC errors otherwise.
- For invalid JSON return `-32700` (Parse error) and `id` set to `null`.

## Difficulty

- ⭐⭐⭐
