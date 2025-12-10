# Exercise 005 — prime-factors（日本語）

目的:
- JSON-RPC 2.0 の `primeFactors` メソッドを実装し、与えられた整数の素因数分解を返すサーバ/クライアントを作成する。

要件:
- `jsonrpc` フィールドは文字列で `"2.0"` であること。
- `method` は `"primeFactors"` であること。
- `params` が単一の数値（整数）または数値の配列を受け取れること。
- 単一の整数が渡された場合は、その整数の素因数の配列を `result` として返す。
- 整数の配列が渡された場合は、各整数に対応する素因数配列の配列（配列の配列）を `result` として返す。
- 文字列が渡された場合、整数に変換できる（例: `"15"` -> `15`）なら受け入れる。
- 要素が整数でない（浮動小数点、非数文字列、オブジェクトなど）場合は、JSON-RPC エラー `-32602`（Invalid params）を返し、メッセージを `Invalid params: items must be integers >= 2` とすること。
- 2 未満の整数（0,1,負数）は無効とし、同じ `-32602` を返す。
- 通知（`id` がないリクエスト）には応答を返さないこと。

受け入れ条件:
- 単一入力と配列入力の両方に対して正しい `result` を返し、`tests/005-prime-factors` にある全ての fixture に一致すること。
- 無効な JSON に対しては `-32700`（Parse error）を返し、レスポンスの `id` は `null` にすること。
- JSON-RPC 2.0 仕様に従ったエラー処理を行うこと。

難易度: ⭐⭐

例:
Request (単一):
```json
{"jsonrpc":"2.0","method":"primeFactors","params":60,"id":1}
```
期待レスポンス:
```json
{"jsonrpc":"2.0","result":[2,2,3,5],"id":1}
```

Request (配列):
```json
{"jsonrpc":"2.0","method":"primeFactors","params":[15,21],"id":2}
```
期待レスポンス:
```json
{"jsonrpc":"2.0","result":[[3,5],[3,7]],"id":2}
```
