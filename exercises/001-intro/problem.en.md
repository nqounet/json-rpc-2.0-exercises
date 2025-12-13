# Exercise 001 — Introduction — sum

## Purpose

- Implement the JSON-RPC 2.0 method `sum`. `sum` accepts a single positional parameter: an array of numbers, and returns their arithmetic sum. The exercise teaches basic request/response handling, notifications, error responses, and batch behavior under JSON-RPC 2.0.

## Specification

### JSON-RPC fields

- `jsonrpc`: both request and response MUST be the string `"2.0"`.
- `method`: the method name is `"sum"`.
- `params`: a single positional parameter — an array of numbers (e.g. `[1, 2, 3]`). Named parameters MAY be supported by an implementation but tests use positional parameters only.
- `result`: on success return a single numeric value equal to the sum of the input numbers.

### Types and behavior

- The server MUST expect `params` to be an array whose elements are all numbers (integers or floating point).  
- For an empty array, return `0`.  
- The result type is a JSON number. Floating point semantics and overflow behavior follow the host language; tests use values that fit typical numeric ranges.

## Error handling

- Use standard JSON-RPC error codes where applicable:

  - `-32700` Parse error — invalid JSON (no `id` can be determined; use `id: null` in response).
  - `-32600` Invalid Request — the JSON is valid but not a JSON-RPC Request object.
  - `-32601` Method not found — method other than `"sum"`.
  - `-32602` Invalid params — missing `params`, `params` not an array, or any array element is not a number.
  - `-32603` Internal error — implementation failure during processing.

- Notifications (requests without an `id` member) MUST NOT produce a response.

## Edge cases and implementation notes

- Empty array: return `0`.
- `id: null`: valid request id; responses must include `id: null`.
- Missing `params` or `params` of wrong type → return error `-32602` with `id` from the request (or `null` if request contains `id: null`).
- Arrays containing non-numeric members (e.g. `null`, strings, objects, arrays) → `-32602`.
- Mixed batches: a request may be a batch (an array of request objects). The implementation must handle each element independently and return an array of responses for non-notifications. Notifications inside a batch produce no entry in the response array.
- Empty batch (i.e., an empty array) is invalid per JSON-RPC 2.0 and should produce a single `-32600` Invalid Request response with `id: null`.
- The order of responses to a batch is not significant; test harnesses may accept any order or supply a `.meta.json` to indicate order insensitivity.

## Examples

### 1) Happy path

Request:
```json
{"jsonrpc":"2.0","method":"sum","params":[1,2,3],"id":1}
```

Response:
```json
{"jsonrpc":"2.0","result":6,"id":1}
```

### 2) Edge — empty array

Request:
```json
{"jsonrpc":"2.0","method":"sum","params":[],"id":2}
```

Response:
```json
{"jsonrpc":"2.0","result":0,"id":2}
```

### 3) Invalid params — non-numeric member (Invalid params: -32602)

Request:
```json
{"jsonrpc":"2.0","method":"sum","params":[1,"x",3],"id":3}
```

Response (example):
```json
{"jsonrpc":"2.0","error":{"code":-32602,"message":"Invalid params","data":"params must be an array of numbers"},"id":3}
```

### 4) Notification (no response expected)

Request (notification):
```json
{"jsonrpc":"2.0","method":"sum","params":[1,2,3]}
```
No response should be returned for this request.

### 5) Mixed batch example (illustrates batch semantics)

Request (batch):
```json
[
  {"jsonrpc":"2.0","method":"sum","params":[1,2,3],"id":1},
  {"jsonrpc":"2.0","method":"sum","params":[],"id":2},
  {"jsonrpc":"2.0","method":"sum","params":[1,"bad",3],"id":3},
  {"jsonrpc":"2.0","method":"sum","params":[4,5]}
]
```

(The last entry in the example batch above is a notification — it has no `id`.)

Possible valid response (order may vary; notifications produce no response element):
```json
[
  {"jsonrpc":"2.0","result":6,"id":1},
  {"jsonrpc":"2.0","result":0,"id":2},
  {"jsonrpc":"2.0","error":{"code":-32602,"message":"Invalid params"},"id":3}
]
```

## Acceptance criteria

- Implementations read fixture requests from `tests/001-intro/request-*.json` and produce JSON output that matches `tests/001-intro/expected-*.json`.
- Provide at minimum the three test pairs:
  - `0001` — happy path: positional array `[1,2,3]` → `6`.
  - `0002` — edge: empty array `[]` → `0`.
  - `0003` — invalid params: non-number element → error `-32602`.
- Notifications (requests without `id`) must produce no response; corresponding `expected-*.json` files must not include a response for those requests.
- Batch responses (if multiple requests are sent in one JSON array) must be an array containing responses for non-notification requests; an empty batch is invalid and should produce a single `-32600` response with `id: null`.
- Error responses must include the original `id` (or `null` if the request contained `id: null` or `id` cannot be determined for parse errors).

## Tests (recommended scenarios)

- Happy path: single request with `params` `[1,2,3]` and `id:1` → `result:6`.
- Edge: single request with `params` `[]` and `id:2` → `result:0`.
- Invalid params (error): single request with `params` containing a non-number (e.g. `[1,"x",3]`) and `id:3` → `error.code:-32602`.
- Notification: a request without `id` (e.g. `{"jsonrpc":"2.0","method":"sum","params":[1,2]}`) → no output.
- Mixed batch: batch containing notifications, valid requests, and invalid-params requests → response array with results/errors only for non-notifications.
- Empty batch: request body `[]` → single `{"jsonrpc":"2.0","error":{ "code": -32600, "message": "Invalid Request" }, "id": null }`.

## Difficulty

- ⭐ (Introductory)

## Implementation notes

- Validate `params` strictly: present, an array, and each element a JSON number.
- Return informative `error.data` where helpful, but keep `error.code` and `error.message` per JSON-RPC standard.
- For batch requests, accumulate responses for only the non-notification entries and return them as a JSON array. If there are no responses (e.g. a batch of only notifications), return nothing.
- Keep outputs deterministic for the provided tests; if response ordering in batch is not significant, document that in a `.meta.json` file accompanying tests.
