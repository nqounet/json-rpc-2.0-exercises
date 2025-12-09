# Exercise 002 — `subtract` method (positional + named params)

Objective: Implement a `subtract` JSON-RPC 2.0 method that accepts both positional (array) and named (object) parameters.

Requirements:

- The `jsonrpc` field must be the string `"2.0"`.
- The `method` must be `"subtract"`.
- If `params` is an array, it will be provided as `[minuend, subtrahend]` and the result should be `minuend - subtrahend`.
- If `params` is an object, it should contain `minuend` and `subtrahend` keys and the result should be `minuend - subtrahend`.
- Requests that include an `id` must receive a response including the same `id`. Notifications (no `id`) must not be answered.
- A parse error for invalid JSON should return `-32700` (Parse error) and must include `"id": null` in the response.
- Invalid request structure or wrong types should return `-32600` (Invalid Request).
- Invalid parameters should return `-32602` (Invalid params).
- Unknown methods should return `-32601` (Method not found).

Acceptance criteria:

- The solution must satisfy the fixtures in the `tests` directory (request/expected pairs).
- The implementation must conform to the JSON-RPC 2.0 specification.

Difficulty: ⭐⭐

Examples:

Request (positional params):

```json
{"jsonrpc":"2.0","method":"subtract","params":[42,23],"id":1}
```

Expected response:

```json
{"jsonrpc":"2.0","result":19,"id":1}
```

Request (named params):

```json
{"jsonrpc":"2.0","method":"subtract","params":{"minuend":42,"subtrahend":23},"id":2}
```

Expected response:

```json
{"jsonrpc":"2.0","result":19,"id":2}
```
