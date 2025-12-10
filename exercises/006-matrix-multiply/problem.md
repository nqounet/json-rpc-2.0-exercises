# Exercise 006 — matrix-multiply（日本語）

目的:
- JSON-RPC 2.0 の `matmul` メソッドを実装し、行列の積を計算するサーバ/クライアントを作成する。

要件:
- `jsonrpc` は `"2.0"`。
- `method` は `"matmul"`。
- `params` はオブジェクトで `a` と `b` のキーを持ち、それぞれが数値の二次元配列（行列）であること。
- 正しい行列積（A × B）を計算して `result` に返すこと。
- 要素が数値でない場合、または行列の次元が乗算不可能（列数が一致しない）な場合は `-32602`（Invalid params）を返し、メッセージを `Invalid params: matrices must be numeric and dimensions must match` とすること。
- 空の行列や ragged（不揃いな行長）な行列は無効とする。
- 通知には応答を返さないこと。

受け入れ条件:
- 正しい行列積を返すこと。エラーは JSON-RPC 2.0 の仕様に従うこと。
- 無効な JSON には `-32700`（Parse error）を返し `id` は `null`。

難易度: ⭐⭐⭐

例:
```json
{"jsonrpc":"2.0","method":"matmul","params":{"a":[[1,2],[3,4]],"b":[[5,6],[7,8]]},"id":1}
```
期待:
```json
{"jsonrpc":"2.0","result":[[19,22],[43,50]],"id":1}
```
