# 004 — Divide

コンテキスト:
- `divide` メソッドを実装し、被除数(dividend) と 除数(divisor) による除算を提供してください。

要件:
- メソッド名は `divide`。
- パラメータは配列（位置引数）またはハッシュ（名前付き引数）の両方を受け付ける。
  - 位置引数例: `[dividend, divisor]`
  - 名前付き例: `{ "dividend": <数値>, "divisor": <数値> }`
- 引数は数値（整数または浮動小数点）であること。
- 正常時は `dividend / divisor` を返す（浮動小数点を許容）。

受け入れ条件:
- 位置引数・名前付き引数それぞれの呼び出しで正しい結果が返ること。
- 除数が `0` の場合はエラーを返すこと（`Invalid params: division by zero`、エラーコード `-32602` を想定）。
- 引数が不足、または型が不正な場合は `Invalid params`（`-32602`）を返すこと。
- 通知（`id` を含まないリクエスト）はレスポンスを返さないこと。
- バッチリクエストでは通知をレスポンス配列に含めないこと。

難易度: ⭐⭐

Examples:

Request:
```json
{ "jsonrpc": "2.0", "method": "divide", "params": [10, 2], "id": 1 }
```

Expected response:
```json
{ "jsonrpc": "2.0", "result": 5, "id": 1 }
```
