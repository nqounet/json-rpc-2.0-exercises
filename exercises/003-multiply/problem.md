# Exercise 003 — multiply（日本語）

## Objective

- JSON-RPC 2.0 の `multiply` メソッドを実装し、与えられた数値の積を返すサーバ/クライアントを作成する。

## Specification

### JSON-RPC フィールド

- `jsonrpc`: リクエストとレスポンスで文字列 `"2.0"` とすること。
- `method`: `"multiply"`。
- `params`:
  - 配列（位置引数）: 配列内の数値をすべて掛け合わせる。
  - オブジェクト（名前付き）: `values` キーに配列がある場合、その配列を使用する。
- `result`: 成功時に数値（積）を返す。

### 動作と検証

- `params` が配列の場合、その配列内の数値をすべて掛け合わせる。
- `params` がオブジェクトで `values` キーに配列がある場合、その配列で積を計算する。
- 要素のいずれかが数値でない場合は、JSON-RPC エラー `-32602`（Invalid params）を返し、メッセージは `Invalid params: items must be numbers` とする。
- 数値が一つも渡されなかった場合は `-32602` を返し、メッセージは `Invalid params: at least one number required` とする。
- 通知（`id` を含まないリクエスト）には応答を返さない。

## エラー処理

- 標準の JSON-RPC エラーコードを使用すること:
  - `-32700` Parse error — 無効な JSON（レスポンスの `id` は `null`）。
  - `-32600` Invalid Request — 有効な JSON だが JSON-RPC Request オブジェクトではない。
  - `-32601` Method not found — 未定義のメソッド。
  - `-32602` Invalid params — パラメータ不足や型不正。
  - `-32603` Internal error — サーバ処理中の例外。
- 通知はレスポンスを返してはいけない。
- バッチリクエスト: 各要素を独立して処理し、通知要素はレスポンスを生成しない。空のバッチ `[]` は無効で `-32600`（`id: null`）を返すこと。

## 注意事項 / エッジケース

- 数値の文字列は拒否する。
- 浮動小数点の丸め等はホスト言語の動作に従う。

## 例

Request:
```json
{"jsonrpc":"2.0","method":"multiply","params":[2,3,4],"id":1}
```

Response:
```json
{"jsonrpc":"2.0","result":24,"id":1}
```

Request:
```json
{"jsonrpc":"2.0","method":"multiply","params":{"values":[5,6]},"id":2}
```

Response:
```json
{"jsonrpc":"2.0","result":30,"id":2}
```

## 受け入れ条件

- `tests/003-multiply` にある fixture と一致する結果または適切なエラーを返すこと。
- 無効な JSON は `-32700`（Parse error）を返し、`id` は `null` にすること。
- JSON-RPC 2.0 の仕様に従うこと。

## 難易度

- ⭐⭐

## テスト

- `tests/003-multiply/` に最低限 `request-0001.json` / `expected-0001.json`（ハッピー）、`0002`（エッジ）、`0003`（無効）を用意すること。
