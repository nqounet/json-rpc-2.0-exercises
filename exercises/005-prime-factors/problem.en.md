# Exercise 005 — prime-factors (English)

Goal:
- Implement a JSON-RPC 2.0 `primeFactors` method that returns the prime factorization of given integers.

Requirements:
- The `jsonrpc` field must be the string `"2.0"`.
- `method` must be `"primeFactors"`.
- `params` may be a single integer or an array of integers.
- When a single integer is provided, return its prime factors as an array in `result`.
- When an array is provided, return an array-of-arrays where each sub-array contains the prime factors for the corresponding integer.
- Accept numeric strings that can be parsed into integers (e.g. `"15"` -> `15`).
- If any item is not an integer >= 2 (floats, non-numeric strings that cannot be parsed, objects, etc.), return a JSON-RPC error `-32602` (Invalid params) with message: `Invalid params: items must be integers >= 2`.
- Do not respond to notifications (requests without `id`).

Acceptance criteria:
- Correct `result` for single and array inputs, and appropriate `error` objects for invalid inputs.
- For invalid JSON, return `-32700` (Parse error) with `id` set to `null`.
- Follow JSON-RPC 2.0 error handling rules for version mismatch, invalid request, and unknown methods.

Difficulty: 2/5

Example:
Single request:
```json
{"jsonrpc":"2.0","method":"primeFactors","params":60,"id":1}
```
Expected response:
```json
{"jsonrpc":"2.0","result":[2,2,3,5],"id":1}
```
