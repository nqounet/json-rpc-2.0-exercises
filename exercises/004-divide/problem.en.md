# Exercise 004 — divide

## Objective

- Implement a JSON-RPC 2.0 method named `divide` that performs division.

## Specification

### JSON-RPC fields

- `jsonrpc`: must be the string `"2.0"` in requests and responses.
- `method`: `"divide"`.
- `params`:
  - Positional: `[dividend, divisor]`.
  - Named: `{ "dividend": <number>, "divisor": <number> }`.
- `result`: on success return `dividend / divisor` (allow floating-point results).

### Behavior and validation

- Both `dividend` and `divisor` must be numbers (integer or float).
- Division by zero must return `-32602` Invalid params with a message starting with `Invalid params: division by zero`.
- Missing or invalid parameter types return `-32602`.
- Notifications (requests without an `id`) produce no response.

## Error handling

- Use standard JSON-RPC error codes where applicable:
  - `-32700` Parse error — invalid JSON (respond with `id: null`).
  - `-32600` Invalid Request — not a valid Request object.
  - `-32601` Method not found — unknown method.
  - `-32602` Invalid params — missing parameters or wrong types.
  - `-32603` Internal error — server-side exception.
- Notifications MUST NOT produce a response.
- Batch requests must follow JSON-RPC 2.0 rules; omit notifications from the response array. An empty batch `[]` is invalid and should produce a single `-32600` response with `id: null`.

## Edge cases / Notes

- Floating-point semantics follow the host language.
- Clearly document behavior for division by zero and parameter validation.

## Examples

Request:
```json
{ "jsonrpc": "2.0", "method": "divide", "params": [10, 2], "id": 1 }
```

Expected response:
```json
{ "jsonrpc": "2.0", "result": 5, "id": 1 }
```

## Acceptance criteria

- Successful calls with positional and named parameters return correct `result` values.
- Division by zero returns `-32602` with message starting with `Invalid params: division by zero`.
- Missing or invalid parameter types return `-32602`.
- Notifications produce no response.
- Batch requests follow JSON-RPC 2.0 rules.

## Difficulty

- ⭐⭐
