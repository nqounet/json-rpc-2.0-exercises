# Exercise 009 — echo-with-meta（日本語）

## Objective

- JSON-RPC 2.0 の `echoWithMeta` メソッドを実装し、受け取ったペイロードをそのまま返しつつ、サーバ側で付与するメタ情報を付加して返す。クライアントの `meta` 内のアンダースコアで始まるキーはレスポンスに含めない。

## Specification

### JSON-RPC フィールド

- `jsonrpc`: リクエストとレスポンスで文字列 `"2.0"` とすること。
- `method`: `"echoWithMeta"`。
- `params`: オブジェクトで、少なくとも `payload` キーを含む（任意の JSON 値）。オプションで `meta`（オブジェクト）を受け取れる。
- `result`: オブジェクトで、`payload`（入力をそのまま返す）と `meta`（クライアントのメタをフィルタしてサーバ `timestamp` を追加したもの）を含む。

### 動作と検証

- `payload` をそのまま `result.payload` として返す。
- `params.meta` が存在する場合はオブジェクトでないと `-32602`（Invalid params）を返す。
- クライアントが送った `meta` のキーでアンダースコア (`_`) で始まるものはレスポンスの `meta` に含めない。
- サーバは必ず `timestamp`（ISO 8601 文字列）を `meta` に追加する。
- 通知には応答を返さない。

## エラー処理

- 標準の JSON-RPC エラーコードを使用する（`-32700`、`-32600`、`-32601`、`-32602`、`-32603`）。

## 注意事項 / エッジケース

- `timestamp` はサーバ生成のためテストでは固定値ではない。ISO 8601 形式の文字列であることを想定する。

## 例

Request:
```json
{"jsonrpc":"2.0","method":"echoWithMeta","params":{"payload":{"x":1},"meta":{"user":"alice","_token":"secret"}},"id":1}
```

期待:
```json
{"jsonrpc":"2.0","result":{"payload":{"x":1},"meta":{"user":"alice","timestamp":"2020-01-01T12:00:00Z"}},"id":1}
```
(注: `timestamp` はサーバが生成するため固定値ではない)

## 受け入れ条件

- `payload` を正確に返し、`meta` のフィルタリングとサーバ付加 `timestamp` を含むこと。
- 無効な JSON は `-32700`（Parse error）、`id` は `null`。

## 難易度

- ⭐⭐
