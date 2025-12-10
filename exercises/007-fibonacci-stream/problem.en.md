# Exercise 007 — fibonacci-stream (English)

Goal:
- Implement a JSON-RPC 2.0 `fibStream` method. The twist: behave differently for notifications vs normal requests (no response for notifications).

Requirements:
- `jsonrpc` must be `"2.0"`.
- `method` must be `"fibStream"`.
- `params` must be an object containing `start` (integer, default 0) and `count` (positive integer).
- For requests with an `id`, return an array of `count` Fibonacci numbers starting at index `start` in `result`.
- For notifications (no `id`), send no response. The problem statement may mention that the server could log or enqueue work internally, but the test verifies no response is emitted.
- If `start` or `count` are invalid (non-integer or `count` <= 0), return `-32602` (Invalid params) with an appropriate message.
- Document an allowed maximum `count` (e.g., 1000) to avoid resource exhaustion in implementations.

Acceptance criteria:
- Normal requests return correct arrays; notifications produce no response.
- Invalid JSON -> `-32700` (Parse error) and `id` set to `null`.

Difficulty: 2/5

Example:
```json
{"jsonrpc":"2.0","method":"fibStream","params":{"start":0,"count":6},"id":1}
```
Expected response:
```json
{"jsonrpc":"2.0","result":[0,1,1,2,3,5],"id":1}
```
