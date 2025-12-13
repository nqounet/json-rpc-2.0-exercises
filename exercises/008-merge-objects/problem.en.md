# Exercise 008 — merge-objects

## Objective

- Implement a JSON-RPC 2.0 `mergeObjects` method that merges multiple objects with configurable conflict resolution strategies.

## Specification

### JSON-RPC fields

- `jsonrpc`: must be the string `"2.0"` in requests and responses.
- `method`: `"mergeObjects"`.
- `params`: an object with:
  - `items`: an array of objects to merge (at least one)
  - `strategy` (optional): `"last"`, `"first"`, or `"concat"`. Default: `"last"`.
- `result`: the merged object according to the chosen strategy.

### Behavior and validation

- Every element in `items` must be an object; otherwise return `-32602` Invalid params.
- Merge rules:
  - `last`: later object values overwrite earlier ones.
  - `first`: earlier object values are kept.
  - `concat`: when conflicting values are arrays, concatenate; if either side is not an array, coerce to array and concatenate.
- Merge nested objects recursively.
- Do not respond to notifications.

## Error handling

- Use standard JSON-RPC error codes where applicable (`-32700`, `-32600`, `-32601`, `-32602`, `-32603`).

## Edge cases / Notes

- When `strategy` is `concat` and values are not arrays, coerce to arrays before concatenation.
- Document any language-specific behavior for object ordering if relevant.

## Examples

Request:
```json
{"jsonrpc":"2.0","method":"mergeObjects","params":{"items":[{"a":1,"b":[1]},{"b":[2],"c":3}],"strategy":"concat"},"id":1}
```

Expected response:
```json
{"jsonrpc":"2.0","result":{"a":1,"b":[1,2],"c":3},"id":1}
```

## Acceptance criteria

- Objects are merged according to the requested `strategy`.
- Invalid inputs produce `-32602`. Invalid JSON -> `-32700` and `id` null.

## Difficulty

- ⭐⭐⭐
