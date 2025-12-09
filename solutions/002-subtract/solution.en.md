```markdown
# Solution — Exercise 002: subtract

This is a small reference implementation: the `subtract` method supports both positional parameters (array) and named parameters (object). When positional parameters are used, they are expected in the order `[minuend, subtrahend]`. When named parameters are used, the method expects the `minuend` and `subtrahend` keys.

Error handling guidance:
- A parse error for invalid JSON should return `-32700` (Parse error).
- If `jsonrpc` is not `2.0`, or `method` is not a string, return `-32600` (Invalid Request).
- If `params` is not in the expected form or the values are not numbers, return `-32602` (Invalid params).
- Unknown or unimplemented methods should return `-32601` (Method not found).

This file provides a minimal example implementation aligned with the README and test acceptance criteria.

```
