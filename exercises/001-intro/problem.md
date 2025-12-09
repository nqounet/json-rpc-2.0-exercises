# Exercise 001 — Intro: `sum` method

目的: JSON-RPC 2.0 の基本的な単一リクエストに応答するサーバ/クライアントを実装する。

要件:

- `jsonrpc` フィールドは `"2.0"` であること
- `method` が `"sum"` の場合、`params` は配列（数値）であり、合計した値を `result` として返すこと
- `id` を含むリクエストに対しては必ずレスポンスに `id` を含め、通知（id がない）に対してはレスポンスを返さない

受け入れ条件:

- テストケースの `request` を solution が stdin 経由で受け取り、期待される `expected` を stdout に出力して一致すること
- JSON-RPC 2.0 仕様 (https://www.jsonrpc.org/specification) に準拠していること

難易度: ⭐
