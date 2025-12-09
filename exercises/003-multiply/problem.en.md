## 003 - multiply (English)

Implement a JSON-RPC 2.0 method named `multiply` that multiplies numbers.

Requirements:
- If `params` is an array, treat it as a list of numbers to multiply.
- If `params` is an object and contains a key `values` (an array), use that array of numbers.
- On success return the product of the numbers as `result`.
- If any item is not a number, return JSON-RPC error `-32602` with message `Invalid params: items must be numbers`.
- If there are no numbers provided, return JSON-RPC error `-32602` with message `Invalid params: at least one number required`.
- Support notifications (requests without `id`) by not returning a response.

Acceptance criteria:
- The implementation returns the correct `result` or an appropriate `error` for each fixture in `tests/003-multiply`.
- Invalid JSON must produce `-32700` (Parse error) with `"id": null`.
- The implementation follows JSON-RPC 2.0 rules for invalid requests and unknown methods.

Difficulty: ⭐⭐

Behavior:
- If `params` is an array, treat it as a list of numbers to multiply.
- If `params` is an object and contains a key `values` (an array), use that array of numbers.
- On success return the product of the numbers as `result`.
- If any item is not a number, return JSON-RPC error `-32602` with message `Invalid params: items must be numbers`.
- If there are no numbers provided, return JSON-RPC error `-32602` with message `Invalid params: at least one number required`.
- Support notifications (requests without `id`) by not returning a response.

Follow the JSON-RPC 2.0 rules for `jsonrpc` version, parse errors, invalid requests, and unknown methods.

Examples and tests are provided in the `tests/003-multiply` directory.
