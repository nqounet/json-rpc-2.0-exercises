# Exercise 007 — fibonacci-stream

## Objective

- Implement a JSON-RPC 2.0 `fibStream` method that returns a sequence of Fibonacci numbers.

## Specification

### JSON-RPC fields

- `jsonrpc`: must be the string `"2.0"` in requests and responses.
- `method`: `"fibStream"`.
- `params`: an object containing `start` (integer, default 0) and `count` (positive integer).
- `result`: an array of `count` Fibonacci numbers starting at index `start` when the request includes an `id`.

### Behavior and validation

- For requests with an `id`, return an array of `count` Fibonacci numbers starting at index `start` in `result`.
- For notifications (no `id`), send no response.
- `start` must be an integer >= 0; `count` must be a positive integer. If invalid, return `-32602` Invalid params.
- Implementations should document and enforce a reasonable maximum `count` (e.g., 1000) to avoid resource exhaustion.

## Error handling

- Standard JSON-RPC error codes apply (`-32700`, `-32600`, `-32601`, `-32602`, `-32603`).
- Notifications MUST NOT produce a response.

## Edge cases / Notes

- Tests validate that notifications produce no response and that normal requests return the expected sequence.

## Examples

Request:
```json
{"jsonrpc":"2.0","method":"fibStream","params":{"start":0,"count":6},"id":1}
```

Expected response:
```json
{"jsonrpc":"2.0","result":[0,1,1,2,3,5],"id":1}
```

## Acceptance criteria

- Normal requests return correct arrays; notifications produce no response.
- Invalid JSON -> `-32700` (Parse error) and `id` set to `null`.

## Difficulty

- ⭐⭐
