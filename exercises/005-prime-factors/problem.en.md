# Exercise 005 — prime-factors

## Objective

- Implement a JSON-RPC 2.0 `primeFactors` method that returns the prime factorization of given integers.

## Specification

### JSON-RPC fields

- `jsonrpc`: must be the string `"2.0"` in requests and responses.
- `method`: `"primeFactors"`.
- `params`: a single integer or an array of integers (numeric strings that can be parsed into integers are accepted).
- `result`: for a single integer return an array of prime factors; for an array input return an array-of-arrays of prime factors.

### Behavior and validation

- Accept numeric strings that can be parsed into integers (e.g. `"15"` -> `15`).
- Items must be integers >= 2 and <= 4294967295 (`2^32 - 1`).
- If any item is not an integer in the allowed range, return `-32602` Invalid params with message `Invalid params: items must be integers >= 2` (or the more detailed message used in tests).
- Do not respond to notifications (requests without `id`).

## Error handling

- Use standard JSON-RPC error codes where applicable:
  - `-32700` Parse error — invalid JSON (respond with `id: null`).
  - `-32600` Invalid Request — not a valid Request object.
  - `-32601` Method not found — unknown method.
  - `-32602` Invalid params — missing parameters or wrong types.
  - `-32603` Internal error — server-side exception.

## Edge cases / Notes

- For array inputs return an array of arrays where each sub-array contains the prime factors for the corresponding integer.
- Values outside the allowed range or non-integer values should produce `-32602`.

## Examples

Request:
```json
{"jsonrpc":"2.0","method":"primeFactors","params":60,"id":1}
```

Expected response:
```json
{"jsonrpc":"2.0","result":[2,2,3,5],"id":1}
```

Request:
```json
{"jsonrpc":"2.0","method":"primeFactors","params":[15,21],"id":2}
```

Expected response:
```json
{"jsonrpc":"2.0","result":[[3,5],[3,7]],"id":2}
```

## Acceptance criteria

- Correct `result` for single and array inputs, and appropriate `error` objects for invalid inputs.
- Invalid JSON -> `-32700` with `id: null`.
- Follow JSON-RPC 2.0 error handling rules.

## Difficulty

- ⭐⭐
