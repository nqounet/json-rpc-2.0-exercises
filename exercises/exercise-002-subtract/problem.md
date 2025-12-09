# Exercise 002 — `subtract` method (positional + named params)

目的: JSON-RPC 2.0 で `subtract` メソッドを実装し、位置引数（配列）と名前付き引数（オブジェクト）の両方を処理するサーバ/クライアントを作る。

要件:

- `jsonrpc` フィールドは必ず "2.0" であること
- `method` は "subtract" であること
- `params` が配列の場合は [minuend, subtrahend] の順で与えられ、返り値は minuend - subtrahend
- `params` がオブジェクトの場合は `minuend` と `subtrahend` を使い、返り値は minuend - subtrahend
- `id` を含むリクエストには必ず `id` を含むレスポンスを返すこと。通知（id がない）は応答しない
- 不正な JSON パースは -32700 Parse error を返す（id は null）
- 無効なリクエスト・型の不備は -32600（Invalid Request）で返す
- 無効な params は -32602（Invalid params）で返す
- 存在しないメソッドには -32601（Method not found）を返す

受け入れ条件:

- tests ディレクトリ内の fixtures（request/expected）で与えられたケースを満たすこと
- JSON-RPC 2.0 仕様に準拠していること

難易度: ⭐⭐

例:

リクエスト (位置引数):

```json
{"jsonrpc":"2.0","method":"subtract","params":[42,23],"id":1}
```

期待レスポンス:

```json
{"jsonrpc":"2.0","result":19,"id":1}
```

リクエスト（名前付き引数）:

```json
{"jsonrpc":"2.0","method":"subtract","params":{"minuend":42,"subtrahend":23},"id":2}
```

期待レスポンス:

```json
{"jsonrpc":"2.0","result":19,"id":2}
```

