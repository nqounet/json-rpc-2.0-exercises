# Exercise 003 — multiply（日本語）

目的:
- JSON-RPC 2.0 の `multiply` メソッドを実装し、与えられた数値の積を返すサーバ/クライアントを作成する。

要件:
- `jsonrpc` フィールドは文字列で `"2.0"` であること。
- `method` は `"multiply"` であること。
- `params` が配列の場合、その配列内の数値をすべて掛け合わせること。
- `params` がオブジェクトで `values` キーに配列がある場合、その配列を使って積を計算すること。
- 要素のいずれかが数値でない場合は、JSON-RPC エラー `-32602`（Invalid params）を返し、メッセージを `Invalid params: items must be numbers` とすること。
- 数値が一つも渡されなかった場合は、JSON-RPC エラー `-32602` を返し、メッセージを `Invalid params: at least one number required` とすること。
- 通知（`id` がないリクエスト）には応答を返さないこと。

受け入れ条件:
- 入力の形式に応じて正しい `result` または適切な `error` を返し、`tests/003-multiply` にある全ての fixture に一致すること。
- 無効な JSON に対しては `-32700`（Parse error）を返し、レスポンスの `id` は `null` にすること。
- `jsonrpc` バージョンや不正リクエスト、未定義メソッドなど JSON-RPC 2.0 の仕様に従ったエラー処理を行うこと。

難易度: ⭐⭐

例:
Request (配列):
```json
{"jsonrpc":"2.0","method":"multiply","params":[2,3,4],"id":1}
```

期待レスポンス:
```json
{"jsonrpc":"2.0","result":24,"id":1}
```

Request (オブジェクト):
```json
{"jsonrpc":"2.0","method":"multiply","params":{"values":[5,6]},"id":2}
```

期待レスポンス:
```json
{"jsonrpc":"2.0","result":30,"id":2}
```

```
