**json-rpc-ideas: Exercises & Test Generation**

- **目的**: `json-rpc-ideas` エージェント（ファイル: `.github/agents/json-rpc-ideas.agent.md`）を使って練習問題とそれに対応するテストケースを自動生成できるようにするための指示をまとめます。

- **期待する成果物**:
  - 各練習問題に対する説明（英語/日本語いずれでも可）。
  - 実装用の簡単なメソッド仕様（例: `add`, `subtract`, `multiply` など）。
  - サーバのJSON-RPC 2.0準拠を確認するためのテストリクエスト（リクエストJSON）と期待されるレスポンス（期待JSON）。
  - 悪意のある／境界ケースのリクエスト（仕様違反、ミックスドバッチ、通知、無効なid型など）。

- **前提**: `json-rpc-ideas` は JSON-RPC 2.0 仕様を完全に理解していること。参考: https://www.jsonrpc.org/specification

- **必須の理解項目（エージェントが内部的に満たすこと）**
  - リクエスト/レスポンスの基本構造（`jsonrpc`=`"2.0"`, `method`, `params`, `id`）。
  - エラーコードと意味: `-32700` (Parse error), `-32600` (Invalid Request), `-32601` (Method not found), `-32602` (Invalid params), `-32603` (Internal error)。
  - `id` の扱い: 文字列、数値、`null` を含む許容される型、サーバは受け取った `id` をそのまま返すこと。通知（`id` が欠落している／`null` ではない? 注: 仕様ではIDがない＝通知）に対してはレスポンスを返さないこと。バッチ内の通知のみの場合、サーバはレスポンスを返さないこと。
  - バッチ処理: リクエスト配列に対してのレスポンスは配列（ただし、すべて通知なら何も返さない）。レスポンス配列はリクエスト配列の順序に依存しないが、各応答はそれぞれの `id` に対応しなければならない。
  - 不正なJSON（パース不可）は `-32700` を返す（トップレベルで単一のエラーオブジェクト）。
  - 余分なキーや未定義フィールドの扱い、型ミスマッチ、`jsonrpc` フィールドの不一致などに対する適切なエラー処理。

- **エージェントに指示する生成ルール**
  - 各エクササイズは "happy path"（通常の正しい呼び出し）と複数の "edge / malicious" ケースを含めること。
  - テストケースのペアは `request-*.json` と `expected-*.json` という名前で出力すること（既存テスト構造に合わせてください）。
  - 各テストは期待する HTTP ステータスコードではなく、JSON-RPC レスポンス本体で合否を判定すること（つまり `result` と `error` の内容および `id` の有無を検証）。
  - バッチ関連のテストでは、期待レスポンスを配列（順不同でも合格と判定できることを明示）として提供するか、明示的に順序を要求する注記を付けること。

- **推奨するトリッキー／悪意のあるリクエスト例（必ずいくつか含めること）**
  - 無効な JSON（例: 途中で切れた JSON）。期待: `-32700` 単一エラーオブジェクト。
  - トップレベルが配列でない、または期待されるオブジェクトではないケース。期待: `-32600`。
  - `jsonrpc` フィールドが欠落、または `"2.0"` でない。期待: `-32600`。
  - `method` フィールドが欠落、あるいは型が文字列でない。期待: `-32600`。
  - 存在しないメソッド呼び出し。期待: `-32601`。
  - `params` の形式や型が不正（位置引数 vs 名前引数の不一致、必須パラメータの欠落）。期待: `-32602`。
  - `id` に不正な型（オブジェクトや配列）を使った場合の振る舞い（サーバ実装依存だが、仕様に準拠するエラーを求めるテストを用意）。
  - 通知（`id` がない）に対してレスポンスが返されないことを確認するケース。
  - バッチ: 正常リクエストと通知、無効リクエストが混在するバッチ。期待: 無効リクエストはエラーオブジェクトで応答、通知には応答なし、正常リクエストには結果が返る（配列）。
  - バッチが空配列（仕様上は Invalid Request と見なす実装が多い）に対する処理。
  - 同じ `id` が複数回出現するバッチの扱い（サーバの一貫性をチェックするケース）。
  - `id` が `null` の扱い（リクエストとして扱うべきか通知か、実装差があるので期待値を明示的に指定）。

- **テスト作成のフォーマット例**
  - `tests/<exercise>/request-0001.json` — リクエストペイロード（単一またはバッチ）
  - `tests/<exercise>/expected-0001.json` — 期待レスポンス（`result` か `error` を含むか、空 = 期待なし）
  - 各期待ファイルにはメタ情報をコメント（または隣接する `*.meta.json`）で提供しても良い: 期待される `id` の扱い、順序の許容、部分的なマッチ許可など。

- **運用上の注意**
  - エージェントは公式仕様（https://www.jsonrpc.org/specification）を参照すること。ローカルの `solutions/`、`tests/` ディレクトリ構造に合わせた出力を行うこと。
  - 生成するテストは自動実行（既存の `run-tests.py` / `run-tests.sh` により）できる形式を優先すること。

- **例：代表的テストケースの短いサンプル（説明用）**
  - Parse error:
    - Request: `{"jsonrpc":"2.0", "method": "add", "params": [1,2]` (途中で終わる)
    - Expected: `{"jsonrpc":"2.0", "error": {"code": -32700, "message": "Parse error"}, "id": null}`
  - Notification:
    - Request: `{"jsonrpc":"2.0", "method": "notify_sum", "params": [1,2]}` (no `id`)
    - Expected: (no response)
  - Batch mix:
    - Request: `[ {"jsonrpc":"2.0","method":"sum","params":[1,2,4],"id":"1"}, {"jsonrpc":"2.0","method":"notify_hello","params":[7]}, {"foo":"bar"}, {"jsonrpc":"2.0","method":"subtract","params":[42,23],"id":2} ]`
    - Expected: Array with responses for id `"1"` and `2`, plus an error object for the invalid entry; no entry for the notification.

---
エージェント実装側: `.github/agents/json-rpc-ideas.agent.md` を読み込み、上記ルールに従ってエクササイズとテストを生成してください。

**詳細要件（実装者向け）**

- **出力場所**: エージェントは次の場所へファイルを生成することを想定してください。
  - 練習問題説明: `exercises/<NNN-name>/problem.en.md`（必要なら `problem.md` も）
  - 参照解答（任意）: `solutions/<NNN-name>/solution.en.md` と `solutions/<NNN-name>/code/`（サンプル実装がある場合）
  - テストデータ: `tests/<NNN-name>/request-XXXX.json` / `tests/<NNN-name>/expected-XXXX.json`

- **メタ情報と検証ルール**
  - すべての `expected-*.json` は JSON-RPC レスポンスオブジェクトまたはオブジェクト配列を含む。空ファイルや不正なJSONを期待値にしない。
  - テストハーネスは `expected-*.json` の `result` と `error` の整合性および `id` の一致で判定する。HTTP ステータスやヘッダは評価対象外。
  - バッチ応答は配列で返す。順序依存でない場合は `*.meta.json` に `order: unordered` を付けること。

**生成ルール（厳密）**

- 1エクササイズ当たり最低 3 件の `request/expected` ペアを生成すること:
  - `0001` — Happy path（正しい `jsonrpc` / `method` / `params` / `id`）
  - `0002` — Edge case（型ミスマッチや不足パラメータなど）
  - `0003` — Malicious/tricky（パースエラー、バッチ混在、通知、無効 `jsonrpc`、存在しないメソッド等）

- 追加のテストを生成する場合は、`0004`, `0005`... と連番で追加し、テストの意図を `*.meta.json` で説明すること。

**期待出力のサンプル（ファイル単位）**

- 例: `tests/001-intro/request-0001.json` (happy path)

  {"jsonrpc":"2.0","method":"add","params":[1,2],"id":1}

- 例: `tests/001-intro/expected-0001.json`

  {"jsonrpc":"2.0","result":3,"id":1}

- 例: `tests/001-intro/request-0002.json` (invalid params)

  {"jsonrpc":"2.0","method":"add","params":{"a":1},"id":2}

- 例: `tests/001-intro/expected-0002.json`

  {"jsonrpc":"2.0","error":{"code":-32602,"message":"Invalid params"},"id":2}

- 例: `tests/001-intro/request-0003.json` (batch with notification and invalid entry)

  [
    {"jsonrpc":"2.0","method":"sum","params":[1,2,4],"id":"1"},
    {"jsonrpc":"2.0","method":"notify_hello","params":[7]},
    {"foo":"bar"},
    {"jsonrpc":"2.0","method":"subtract","params":[42,23],"id":2}
  ]

- 例: `tests/001-intro/expected-0003.json` (応答配列、順不同許容 を示すメタファイルあり)

  [
    {"jsonrpc":"2.0","result":7,"id":"1"},
    {"jsonrpc":"2.0","result":19,"id":2},
    {"jsonrpc":"2.0","error":{"code":-32600,"message":"Invalid Request"},"id":null}
  ]

- 例: `tests/001-intro/expected-0003.meta.json`

  {"order":"unordered","notes":"notification has no response; invalid object produced Invalid Request error with id null"}

**ヒント: エッジケースの優先リスト（作成優先順）**

1. 無効 JSON（Parse error）
2. Invalid Request（トップレベルが不正なオブジェクト、`jsonrpc` 欄の欠落）
3. Method not found
4. Invalid params（型/形式）
5. Notification（no id）
6. Mixed batch（通知、正常、無効入り混じり）
7. Empty batch
8. `id` が `null` / 重複 / 非プリミティブ（オブジェクト/配列）

**生成された練習問題の品質基準**

- 各練習問題は、学習目的を表す短い説明（1-2文）と、API の動作を検証するための最低 3 つのテストケースを持つこと。
- テストはローカルの `run-tests.py` で実行できる形式にし、特別なランナーが必要な場合は `exercises/<NNN-name>/README.md` に手順を記載すること。

---
追記済み: `AGENTS.md` に詳細要件と具体的なテストファイル例を追加しました。

