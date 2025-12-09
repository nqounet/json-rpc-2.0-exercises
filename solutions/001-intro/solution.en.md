```markdown
# Solution: 001-intro

Overview:

- A minimal Python stdin/stdout-based JSON-RPC 2.0 handler intended for learning purposes.
- Implements the `sum` method: sums the numbers provided in a positional array and returns the sum in `result`.

Implementation notes:

- Parse the input as JSON and validate the `jsonrpc` field and other structural requirements according to the spec.
- Do not respond to notifications (requests without an `id`).
- For inputs that violate the spec, return a JSON-RPC error object in `error`.
  - For parse errors, follow the JSON-RPC 2.0 spec and include `"id": null` in the response.

Dependencies: standard library only

Reference: JSON-RPC 2.0 specification — https://www.jsonrpc.org/specification

```
