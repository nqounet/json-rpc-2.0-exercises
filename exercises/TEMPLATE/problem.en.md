# Exercise NNN — <Short title>

## Objective

- Briefly describe the goal: what JSON-RPC 2.0 method(s) the exercise asks to implement and what behavior is expected.

## Specification

### JSON-RPC fields

- `jsonrpc`: must be the string `"2.0"` in requests and responses.
- `method`: the method name(s) to implement, e.g. `"method_name"`.
- `params`: describe required parameter types and formats (positional or named).
- `result`: describe the expected successful response content and type.

### Error handling

- List the error codes and conditions to return them (use standard JSON-RPC codes when applicable):
  - `-32700` Parse error: invalid JSON
  - `-32600` Invalid Request: not a valid JSON-RPC object
  - `-32601` Method not found: unknown method
  - `-32602` Invalid params: params missing or wrong type
  - `-32603` Internal error: server error while processing
- Describe behavior for notifications (requests without `id`): must produce no response.

## Edge cases / Notes

- Note important edge cases implementers should consider (empty arrays, `null` id, large numbers, duplicate params, mixed batch requests, etc.).
- Mention any acceptable implementation assumptions or language-specific constraints.

## Examples

### Request

```json
{"jsonrpc":"2.0","method":"method_name","params":[/* ... */],"id":1}
```

### Response

```json
{"jsonrpc":"2.0","result":/* ... */,"id":1}
```

## Acceptance criteria

- The solution reads JSON `request-*.json` files and produces JSON responses matching `expected-*.json` fixtures under `tests/NNN-name/`.
- At least 3 test pairs must be provided for the exercise: `0001` (happy), `0002` (edge), `0003` (malicious/invalid).
- Tests use `request-XXXX.json` and `expected-XXXX.json` naming; batch responses are arrays and may be unordered (document in `*.meta.json` when order is not required).

## Tests

- Place test pairs under `tests/NNN-name/`.
- Include `request-0001.json` / `expected-0001.json` (happy path).
- Include `request-0002.json` / `expected-0002.json` (edge case).
- Include `request-0003.json` / `expected-0003.json` (invalid/malicious case such as invalid params, invalid JSON, or method not found).
- Additional tests (`0004`, `0005`, ...) are encouraged to cover notifications, empty batches, mixed batches, and `id` edge cases (`null`, non-primitive, duplicate ids in batch).

## Difficulty

<difficulty, e.g. ⭐★>

## Files to create for an implementation (suggested)

- `solutions/NNN-name/solution.en.md` — explanation and notes
- `solutions/NNN-name/code/*` — reference implementation (optional)

## Notes for exercise authors

- Keep the problem statement concise and unambiguous.
- Prefer small, self-contained behaviors that can be validated by the JSON fixtures.
- When expecting nondeterministic outputs, provide a `.meta.json` describing acceptable variations.
