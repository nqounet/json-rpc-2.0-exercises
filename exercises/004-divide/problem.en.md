# 004 — Divide

Context:
- Implement a JSON-RPC 2.0 method named `divide` that performs division.

Requirements:
- The method name must be `divide`.
- Accepts parameters either as an array (positional) or an object (named):
  - Positional: `[dividend, divisor]`
  - Named: `{ "dividend": <number>, "divisor": <number> }`
- Both `dividend` and `divisor` must be numbers (integers or floats).
- On success return `dividend / divisor` (allow floating-point results).

Acceptance criteria:
- Successful calls with positional and named parameters return correct `result` values.
- Division by zero must return an error with code `-32602` and message starting with `Invalid params: division by zero`.
- Missing or invalid parameter types return `Invalid params` (`-32602`).
- Notifications (requests without an `id`) produce no response.
- Batch requests must follow the JSON-RPC 2.0 rules: notifications are omitted from the response array.

Difficulty: ⭐⭐

Examples:

Request:
```json
{ "jsonrpc": "2.0", "method": "divide", "params": [10, 2], "id": 1 }
```

Expected response:
```json
{ "jsonrpc": "2.0", "result": 5, "id": 1 }
```
