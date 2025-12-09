# Solution: 001-intro

概要:

- Python で stdin/stdout 経由の簡易 JSON-RPC 2.0 ハンドラを実装しています。これは学習目的の最小実装です。
- `sum` メソッドを実装しており、引数配列の数値を合計して `result` を返します。

実装方針:

- 入力を JSON としてパースし、仕様に従って `jsonrpc` と `id` の処理を行う
- 通知（id フィールドがない）には応答しない
- 仕様に反した入力については JSON-RPC のエラーオブジェクト（`error`）を返す
	- Parse error の場合、JSON-RPC 2.0 仕様に従ってレスポンスに `"id": null` を含めます

依存性: 標準ライブラリのみ

参考: JSON-RPC 2.0 仕様 — https://www.jsonrpc.org/specification
