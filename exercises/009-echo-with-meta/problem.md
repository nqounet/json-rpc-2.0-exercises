# Exercise 009 — echo-with-meta（日本語）

目的:
- JSON-RPC 2.0 の `echoWithMeta` メソッドを実装し、受け取ったペイロードをそのまま返しつつ、サーバ側で付与するメタ情報を付加して返す。少し変わったルールとして、`meta` オブジェクト内のアンダースコアで始まるキーはレスポンスに含めない。

要件:
- `jsonrpc` は `"2.0"`。
- `method` は `"echoWithMeta"`。
- `params` はオブジェクトで、少なくとも `payload` キーを含む（任意の JSON 値）。オプションで `meta`（オブジェクト）を受け取れる。
- レスポンスの `result` はオブジェクトで、少なくとも以下を含むこと:
  - `payload`: 入力の `payload` をそのまま返す
  - `meta`: サーバが付加するメタ情報をマージしたオブジェクト。ただし、クライアントが送った `meta` 内のキーでアンダースコアで始まる（`_secret` のような）ものは、レスポンスの `meta` には含めない。
  - サーバ付加のメタ情報として `timestamp`（ISO 8601 文字列）を必ず含む。
- `params.meta` がオブジェクトでない場合は `-32602`（Invalid params）を返す。
- 通知は応答しない。

受け入れ条件:
- `payload` を正確に返し、`meta` のフィルタリングとサーバ付加 `timestamp` を含むこと。
- 無効な JSON は `-32700`（Parse error）、`id` は `null`。
- JSON-RPC 2.0 の仕様に従うエラー処理。

難易度: ⭐⭐

例:
```json
{"jsonrpc":"2.0","method":"echoWithMeta","params":{"payload":{"x":1},"meta":{"user":"alice","_token":"secret"}},"id":1}
```
期待:
```json
{"jsonrpc":"2.0","result":{"payload":{"x":1},"meta":{"user":"alice","timestamp":"2020-01-01T12:00:00Z"}},"id":1}
```
(注: `timestamp` はサーバが生成するため固定値ではない)
