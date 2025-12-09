# Exercise 001 — Intro: `sum` method

Objective: Implement a simple server/client that responds to basic single-request JSON-RPC 2.0 calls.

Requirements:

- The `jsonrpc` field must be the string `"2.0"`.
- When `method` is `"sum"`, the `params` value will be an array of numbers; the server should return the sum of those numbers in the `result` field.
- For requests that include an `id`, the response must include the same `id`. Notifications (requests without an `id`) must not produce a response.

Acceptance criteria:

- The solution reads each test `request` from stdin and writes the expected `expected` JSON to stdout so that the fixture matches.
- The implementation follows the JSON-RPC 2.0 specification (https://www.jsonrpc.org/specification).

Difficulty: ⭐
