# Exercise 006 — matrix-multiply（日本語）

## Objective

- JSON-RPC 2.0 の `matmul` メソッドを実装し、行列の積を計算するサーバ/クライアントを作成する。

## Specification

### JSON-RPC フィールド

- `jsonrpc`: リクエストとレスポンスで文字列 `"2.0"` とすること。
- `method`: `"matmul"`。
- `params`: オブジェクトで `a` と `b` のキーを持ち、それぞれが数値の二次元配列（行列）であること。
- `result`: 正しい行列積（A × B）を二次元配列として返す。

### 動作と検証

- 行列 `a` と `b` は空でなく、各行が同じ長さを持つ（ragged ではない）数値の二次元配列であること。
- 掛け算可能な次元（`a` の列数 == `b` の行数）であること。
- 要素が数値でない場合、行長が不揃い、次元不一致の場合は `-32602`（Invalid params）を返し、メッセージは `Invalid params: matrices must be numeric and dimensions must match` とする。
- 空の行列は無効とする。
- 通知には応答を返さない。

## エラー処理

- 標準の JSON-RPC エラーコードを使用すること:
  - `-32700` Parse error — 無効な JSON（レスポンスの `id` は `null`）。
  - `-32600` Invalid Request — 有効な JSON だが Request オブジェクトではない。
  - `-32601` Method not found — 未定義のメソッド。
  - `-32602` Invalid params — パラメータ不足や型不正。
  - `-32603` Internal error — サーバ処理中の例外。

## 注意事項 / エッジケース

- 実装は数値型と行長の検証を先に行ってから乗算を実行すること。

## 例

Request:
```json
{"jsonrpc":"2.0","method":"matmul","params":{"a":[[1,2],[3,4]],"b":[[5,6],[7,8]]},"id":1}
```

期待:
```json
{"jsonrpc":"2.0","result":[[19,22],[43,50]],"id":1}
```

## 受け入れ条件

- 正しい行列積を返すこと。エラーは JSON-RPC 2.0 の仕様に従うこと。
- 無効な JSON には `-32700`（Parse error）を返し `id` は `null`。

## 難易度

- ⭐⭐⭐
