# Exercise 008 — merge-objects (English)

Goal:
- Implement a JSON-RPC 2.0 `mergeObjects` method that merges multiple objects with configurable conflict resolution strategies.

Requirements:
- `jsonrpc` must be `"2.0"`.
- `method` must be `"mergeObjects"`.
- `params` must be an object with:
  - `items`: an array of objects to merge (at least one)
  - `strategy` (optional): `"last"`, `"first"`, or `"concat"`. Default: `"last"`.
- Every element in `items` must be an object; otherwise return `-32602` (Invalid params) with an explanatory message.
- Merge rules:
  - `last`: later object values overwrite earlier ones.
  - `first`: earlier object values are kept.
  - `concat`: when conflicting values are arrays, concatenate; if either side is not an array, coerce to array and concatenate.
- Merge nested objects recursively.
- Do not respond to notifications.

Acceptance criteria:
- Objects are merged according to the requested `strategy`.
- Invalid inputs produce `-32602`. Invalid JSON -> `-32700` and `id` null.

Difficulty: 3/5

Example:
```json
{"jsonrpc":"2.0","method":"mergeObjects","params":{"items":[{"a":1,"b":[1]},{"b":[2],"c":3}],"strategy":"concat"},"id":1}
```
Expected response:
```json
{"jsonrpc":"2.0","result":{"a":1,"b":[1,2],"c":3},"id":1}
```
