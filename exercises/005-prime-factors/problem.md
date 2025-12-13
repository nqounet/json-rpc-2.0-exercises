# Exercise 005 — prime-factors（日本語）

## Objective

- JSON-RPC 2.0 の `primeFactors` メソッドを実装し、与えられた整数の素因数分解を返すサーバ/クライアントを作成する。

## Specification

### JSON-RPC フィールド

- `jsonrpc`: リクエストとレスポンスで文字列 `"2.0"` とすること。
- `method`: `"primeFactors"`。
- `params`: 単一の整数または整数の配列。数値文字列は整数に変換できる場合に受け入れる。
- `result`: 単一入力なら素因数の配列、配列入力なら各整数に対応する素因数配列の配列を返す。

### 動作と検証

- 文字列で渡された数値は整数に変換して受け入れる（例: `"15"` -> `15`）。
- 要素は整数であり、範囲は >= 2 かつ <= 4294967295 (`2^32 - 1`) とする。
- 範囲外または整数でない要素があれば `-32602`（Invalid params）を返す。テストで使うメッセージ `Invalid params: items must be integers >= 2 and <= 4294967295` を使うこと。
- 通知（`id` がない）には応答を返さない。

## エラー処理

- 標準の JSON-RPC エラーコードを使用すること:
  - `-32700` Parse error — 無効な JSON（レスポンスの `id` は `null`）。
  - `-32600` Invalid Request — 有効な JSON だが Request オブジェクトではない。
  - `-32601` Method not found — 未定義のメソッド。
  - `-32602` Invalid params — パラメータ不足や型不正。
  - `-32603` Internal error — サーバ処理中の例外。

## 注意事項 / エッジケース

- 配列入力では、各整数に対する素因数配列を順に返すこと。
- 0,1,負数、浮動小数点、解析不能な文字列は無効とする。
- 最大許容値は `4294967295` を上限とする。

## 例

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

## 受け入れ条件

- 単一入力と配列入力の両方に対して正しい `result` を返し、`tests/005-prime-factors` にある全ての fixture と一致すること。
- 無効な JSON には `-32700`（Parse error）を返し、`id` は `null` にすること。
- JSON-RPC 2.0 の仕様に従うエラー処理を行うこと。

## 難易度

- ⭐⭐
