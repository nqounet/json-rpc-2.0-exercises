# Exercise 002 — subtract (subtraction method)

## Purpose

- Implement the JSON-RPC 2.0 method `subtract`. The method returns the arithmetic difference between two numbers: `minuend - subtrahend`. The implementation must accept both positional parameters (array) and named parameters (object).

## Specification

### JSON-RPC fields

- `jsonrpc`: both request and response MUST be the string `"2.0"`.
- `method`: the method name is `"subtract"`.
- `params`:
  - Positional: an array `[minuend, subtrahend]`.
  - Named: an object `{ "minuend": <number>, "subtrahend": <number> }`.
- `result`: on success return a JSON number equal to `minuend - subtrahend`.

### Types and behavior

- `minuend` and `subtrahend` must be JSON numbers (integer or float). Numeric strings are not accepted in tests.
- The arithmetic follows the host language's numeric semantics (floating-point rounding, overflow, etc.).

## Error handling

- Use standard JSON-RPC error codes where applicable:
  - `-32700` Parse error — invalid JSON (respond with `id: null`).
  - `-32600` Invalid Request — the JSON is valid but not a proper JSON-RPC Request object (e.g., `id` is non-primitive).
  - `-32601` Method not found — method other than `"subtract"`.
  - `-32602` Invalid params — missing parameters, wrong types, or insufficient array length.
  - `-32603` Internal error — server-side error during processing.

- Notifications (requests without an `id` member) MUST NOT produce a response.

- Batch requests (an array of requests): process each element independently; do not produce responses for notification elements. An empty batch `[]` is invalid and should produce a single `-32600` response with `id: null`.

## Edge cases and implementation notes

- If `params` is an array with fewer than two elements, return `-32602`.
- If `params` is neither an array nor an object, return `-32602`.
- If an object param lacks `minuend` or `subtrahend`, or they are not numbers, return `-32602`.
- `id` may be a string, number, or `null`. If `id` is non-primitive (object or array), treat request as `-32600`.
- Duplicate `id` values within a batch may produce multiple responses with the same `id`; clients should handle this accordingly.

## Examples

### Positional parameters

Request:
```json
{"jsonrpc":"2.0","method":"subtract","params":[10,3],"id":1}
```

Response:
```json
{"jsonrpc":"2.0","result":7,"id":1}
```

### Named parameters

Request:
```json
{"jsonrpc":"2.0","method":"subtract","params":{"minuend":5,"subtrahend":8},"id":"req-2"}
```

Response:
```json
{"jsonrpc":"2.0","result":-3,"id":"req-2"}
```

### Invalid params (insufficient)

Request:
```json
{"jsonrpc":"2.0","method":"subtract","params":[5],"id":3}
```

Response:
```json
{"jsonrpc":"2.0","error":{"code":-32602,"message":"Invalid params","data":"expected two numeric parameters: [minuend, subtrahend]"},"id":3}
```

### Notification (no response expected)

Request (notification):
```json
{"jsonrpc":"2.0","method":"subtract","params":[4,1]}
```
No response should be returned by the server for this request.

### Mixed batch example

Request (batch):
```json
[
  {"jsonrpc":"2.0","method":"subtract","params":[20,5],"id":1},
  {"jsonrpc":"2.0","method":"subtract","params":[3,2]},
  {"foo":"bar"}
]
```

(Note: the second element is a notification and should not produce a response; the third element is an invalid request object and should produce `-32600` with `id: null`.)

Possible valid response (order may vary):
```json
[
  {"jsonrpc":"2.0","result":15,"id":1},
  {"jsonrpc":"2.0","error":{"code":-32600,"message":"Invalid Request"},"id":null}
]
```

## Acceptance criteria

- Implementations must read fixture requests from `tests/002-subtract/request-*.json` and produce JSON output matching `tests/002-subtract/expected-*.json`.
- Provide at minimum the three test pairs:
  - `0001` — positional params: `[10,3]` → `7`.
  - `0002` — named params: `{minuend:5, subtrahend:8}` → `-3`.
  - `0003` — invalid params: insufficient or wrong types → error `-32602`.
- Notifications (requests without `id`) must produce no response.
- Batch responses must be an array of responses for non-notification requests; an empty batch is invalid and should produce a single `-32600` response with `id: null`.
- Error responses must include the original `id` (or `null` where appropriate).

## Tests (recommended scenarios)

- Happy path: single positional request `{"jsonrpc":"2.0","method":"subtract","params":[10,3],"id":1}` → `{"jsonrpc":"2.0","result":7,"id":1}`.
- Named params: single request `{"jsonrpc":"2.0","method":"subtract","params":{"minuend":5,"subtrahend":8},"id":"req-2"}` → `{"jsonrpc":"2.0","result":-3,"id":"req-2"}`.
- Invalid params: single request `{"jsonrpc":"2.0","method":"subtract","params":[5],"id":3}` → `{"jsonrpc":"2.0","error":{"code":-32602,"message":"Invalid params"},"id":3}`.
- Notification: `{"jsonrpc":"2.0","method":"subtract","params":[4,1]}` → no output.
- Mixed batch: see Examples above.
- Method not found: `{"jsonrpc":"2.0","method":"add","params":[1,2],"id":5}` → `{"jsonrpc":"2.0","error":{"code":-32601,"message":"Method not found"},"id":5}`.

## Difficulty

- ⭐⭐ (Introductory — requires correct handling of positional/named params and JSON-RPC error/batch semantics)

## Implementation notes

- Parse `params`: if array, take the first two elements as `minuend` and `subtrahend`; if object, read `minuend` and `subtrahend` properties. Otherwise, return `-32602`.
- Validate numeric types strictly (reject `NaN`, `null`, and non-number values).
- For floating-point results, tests compare JSON numeric values; consider rounding only if tests require it.
- Batch response ordering is not guaranteed by the spec—tests should match responses by `id`.
