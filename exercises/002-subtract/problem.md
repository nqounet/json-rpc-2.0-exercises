# 演習 002 — subtract（引き算メソッド）

## 目的

- JSON-RPC 2.0 のメソッド `subtract` を実装します。`subtract` は 2 つの数値（minuend と subtrahend）を受け取り、結果として minuend - subtrahend を返します。位置引数（配列）と名前付き引数（オブジェクト）の両方をサポートすることを目的とします。

## 仕様

### JSON-RPC フィールド

- `jsonrpc`: リクエスト・レスポンスともに文字列 `"2.0"` を使用すること。  
- `method`: 実装対象のメソッド名は `"subtract"`。  
- `params`: 位置引数の場合は配列 `[minuend, subtrahend]`。名前付き引数の場合はオブジェクト `{"minuend": <number>, "subtrahend": <number>}`。  
- `result`: 正常時は数値（minuend - subtrahend）を返す。

### 型・振る舞い

- `minuend` と `subtrahend` は数値（整数または浮動小数点）であること。文字列で表現された数値はテストでは扱わない（実装で拡張しても良いがフィクスチャは数値型を想定）。
- 引き算の結果はホスト言語の数値表現に従う（浮動小数点の丸めやオーバーフローに注意）。

## エラー処理

実装は JSON-RPC 2.0 の標準エラーコードを使用することを推奨します。

- `-32700` Parse error — 無効な JSON（この場合レスポンスの `id` は `null`）。
- `-32600` Invalid Request — JSON は有効だが JSON-RPC Request オブジェクトの要件を満たさない場合（例: `id` が非プリミティブ）。
- `-32601` Method not found — `method` が `"subtract"` でない場合。
- `-32602` Invalid params — `params` が欠落、配列／オブジェクトでない、要素数不足、または要素が数値でない場合。
- `-32603` Internal error — 処理中の内部エラー。

通知（`id` が欠落するリクエスト）はレスポンスを返してはならない。

バッチ処理について:
- リクエストが配列（バッチ）の場合、各要素を個別に処理し、通知要素には応答しない。  
- 空のバッチ `[]` は無効と見なされ、単一の `-32600` 応答（`id: null`）を返すことを推奨します。  

## 注意点 / エッジケース

- `minuend` や `subtrahend` が 0、負数、大きな数、浮動小数点の場合は通常の数値演算規則に従う。  
- 配列パラメータが長さ 2 未満のときは `-32602`。  
- `params` が配列でもオブジェクトでもない場合は `-32602`。  
- バッチ内で同一 `id` が複数存在する場合、それぞれ独立に応答が返る可能性があることをドキュメントに明記してください。

## 例

### 位置引数（positional）

Request:
```json
{"jsonrpc":"2.0","method":"subtract","params":[10,3],"id":1}
```

Response:
```json
{"jsonrpc":"2.0","result":7,"id":1}
```

### 名前付き引数（named）

Request:
```json
{"jsonrpc":"2.0","method":"subtract","params":{"minuend":5,"subtrahend":8},"id":"req-2"}
```

Response:
```json
{"jsonrpc":"2.0","result":-3,"id":"req-2"}
```

### 無効なパラメータ（不足）

Request:
```json
{"jsonrpc":"2.0","method":"subtract","params":[5],"id":3}
```

Response:
```json
{"jsonrpc":"2.0","error":{"code":-32602,"message":"Invalid params","data":"expected two numeric parameters: [minuend, subtrahend]"},"id":3}
```

### 通知（no response expected）

Request (notification):
```json
{"jsonrpc":"2.0","method":"subtract","params":[4,1]}
```

サーバーはこのリクエストに対してレスポンスを返しません。

### 混合バッチ（notification + valid + invalid）

Request (batch):
```json
[
  {"jsonrpc":"2.0","method":"subtract","params":[20,5],"id":1},
  {"jsonrpc":"2.0","method":"subtract","params":[3,2]},
  {"foo":"bar"}
]
```

(2 番目の要素は通知 — `id` が無いため応答は不要。3 番目の要素は無効なリクエストオブジェクトであり、サーバーはその要素に対して `-32600` を `id: null` で返します。)

Possible Response（順序は実装依存）:
```json
[
  {"jsonrpc":"2.0","result":15,"id":1},
  {"jsonrpc":"2.0","error":{"code":-32600,"message":"Invalid Request"},"id":null}
]
```

## 受け入れ条件

1. `subtract` は位置引数と名前付き引数の両方を受け付け、正しい結果（minuend - subtrahend）を返すこと。  
2. 無効なパラメータ（不足や型不正）は `-32602` を返す。  
3. 通知リクエスト（`id` が無い）にはレスポンスを返さない。  
4. バッチリクエストに対して、通知を除く要素ごとに適切な応答を返す。無効要素は `-32600`（`id: null`）で応答する。  
5. `id` が string/number/null の場合はそのまま返す。非プリミティブな `id` は `-32600` とする。

## テスト

最低限のテストシナリオ（例）:

1) Happy path — 位置引数
- Request: `{"jsonrpc":"2.0","method":"subtract","params":[10,3],"id":1}`
- Expected Response: `{"jsonrpc":"2.0","result":7,"id":1}`

2) Named parameters — 名前付きパラメータ
- Request: `{"jsonrpc":"2.0","method":"subtract","params":{"minuend":5,"subtrahend":8},"id":"req-2"}`
- Expected Response: `{"jsonrpc":"2.0","result":-3,"id":"req-2"}`

3) Invalid params — パラメータ不足
- Request: `{"jsonrpc":"2.0","method":"subtract","params":[5],"id":3}`
- Expected Response: `{"jsonrpc":"2.0","error":{"code":-32602,"message":"Invalid params"},"id":3}`

推奨追加テスト:
- Notification: `{"jsonrpc":"2.0","method":"subtract","params":[4,1]}` → no response
- Mixed batch: see Examples
- Method not found: `{"jsonrpc":"2.0","method":"add","params":[1,2],"id":5}` → `{"jsonrpc":"2.0","error":{"code":-32601,"message":"Method not found"},"id":5}`

## 難易度

⭐⭐（入門〜中級）

## 実装者向けメモ

- パラメータの判定: まず `params` が配列かオブジェクトか判定する。配列なら先頭2要素を `minuend`/`subtrahend` と見なす。オブジェクトなら `minuend` と `subtrahend` を取り出す。その他は `-32602`。
- 型チェック: `NaN` や `null`、文字列は無効とする。ホスト言語の標準的な数値判定を使う。
- 浮動小数点: 必要ならテスト側で許容誤差を定義する。デフォルトでは JSON の数値表現で比較する。
- バッチの応答順序は仕様で厳密には保証されないため、テストは `id` を鍵に比較することを推奨する。
