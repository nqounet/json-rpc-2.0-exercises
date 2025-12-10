# Exercise 006 — matrix-multiply (English)

Goal:
- Implement a JSON-RPC 2.0 `matmul` method that computes matrix multiplication.

Requirements:
- The `jsonrpc` field must be `"2.0"`.
- `method` must be `"matmul"`.
- `params` must be an object containing keys `a` and `b`, each a 2D numeric array (matrix).
- Compute the matrix product A × B and return it in `result`.
- If elements are non-numeric, matrices are ragged (rows of different lengths), or dimensions are incompatible for multiplication, return `-32602` (Invalid params) with message: `Invalid params: matrices must be numeric and dimensions must match`.
- Empty matrices are invalid.
- Do not respond to notifications.

Acceptance criteria:
- Correct matrix multiplication for valid inputs; appropriate JSON-RPC errors otherwise.
- For invalid JSON return `-32700` (Parse error) and `id` set to `null`.

Difficulty: 3/5

Example:
```json
{"jsonrpc":"2.0","method":"matmul","params":{"a":[[1,2],[3,4]],"b":[[5,6],[7,8]]},"id":1}
```
Expected response:
```json
{"jsonrpc":"2.0","result":[[19,22],[43,50]],"id":1}
```
