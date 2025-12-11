**json-rpc-ideas: Exercises & Test Generation**

指示を簡潔化しました。要点:

- エージェントは JSON-RPC 2.0 仕様に準拠した練習問題とテストを生成すること（仕様参照: https://www.jsonrpc.org/specification）。

- 出力先（想定）:
  - `exercises/<NNN-name>/problem.en.md` and `exercises/<NNN-name>/problem.ja.md` (both English and Japanese)
  - `solutions/<NNN-name>/solution.en.md` （任意）
  - `tests/<NNN-name>/request-XXXX.json`
  - `tests/<NNN-name>/expected-XXXX.json` (`*.meta.json` は任意の注記／順序ルール用)

- 最低ルール:
  - 1エクササイズにつき最低 3 件の `request/expected` ペアを生成する: `0001`=happy, `0002`=edge, `0003`=malicious
  - ファイル命名は既存の `tests/` 構造に合わせること
  - テストは JSON レスポンス本体（`result`/`error` と `id`）で判定すること
  - バッチ応答は配列。順不同を許容する場合は `*.meta.json` に記載すること

- 優先的に含めるべきエッジケース（抜粋）:
  - 無効 JSON (Parse error)
  - Invalid Request (`jsonrpc` 欄欠落等)
  - Method not found
  - Invalid params
  - Notification (no `id`)
  - Mixed batch (通知 + 正常 + 無効)
  # json-rpc-ideas: Exercises & Test Generation (Merged)

  目的

  - エージェント `json-rpc-ideas` が JSON-RPC 2.0 に準拠した練習問題と機械実行可能なテストを一貫して生成できるようにするためのルールをまとめる。参照: https://www.jsonrpc.org/specification

  Output Locations

  - `exercises/<NNN-name>/problem.en.md`（任意で `problem.ja.md`／`problem.md` を併置）
  - `solutions/<NNN-name>/solution.en.md` と `solutions/<NNN-name>/code/`（サンプル実装がある場合）
  - `tests/<NNN-name>/request-XXXX.json` / `tests/<NNN-name>/expected-XXXX.json`
  - 必要に応じて `*.meta.json`（例: `expected-0003.meta.json`）で順序や実装依存の注記を付与する

  必須の理解項目

  - メッセージ形: `jsonrpc:\"2.0\"`, `method`, `params`（位置引数または名前引数）, `id`
  - 標準エラーコード: `-32700` (Parse error), `-32600` (Invalid Request), `-32601` (Method not found), `-32602` (Invalid params), `-32603` (Internal error)
  - `id` の扱い:
    - 許容される型: 文字列、数値、`null`（ただし実装差があるためテストで明示すること）
    - 明示的な `\"id\": null` は有効な id と見なしてサーバはそのままエコーすることを基本とする
    - `id` 欠落は通知（notification）であり、サーバはレスポンスを返してはならない
    - 実装依存の挙動（例: `id:null` を通知と扱う実装など）は `*.meta.json` で注記してテストする
  - バッチ:
    - バッチ入力（配列）への応答は配列。すべて通知のみのバッチではレスポンスを返さない。
    - 応答配列の順序は実装依存になり得るため、順序を問わない場合は `*.meta.json` に `order: unordered` を付記する

  生成ルール（必須）

  - 各エクササイズは最低 3 件の `request/expected` ペアを生成:
    - `0001` — Happy path（正常系）
    - `0002` — Edge case（型ミスマッチや不足パラメータ等）
    - `0003` — Malicious/tricky（パースエラー、混合バッチ、通知、無効 `jsonrpc`、未定義メソッド等）
  - ファイル命名: `request-0001.json` / `expected-0001.json`。追加は `0004`, `0005`, ... と連番
  - テストは HTTP ステータスではなく JSON-RPC レスポンス本文（`result` / `error` と `id`）で判定する
  - バッチ系テストは期待レスポンスを配列で表現し、順不同を許容する場合は隣接の `*.meta.json` で明示する

  優先的に含めるエッジケース

  - 無効な JSON（Parse error → `-32700`）
  - Invalid Request（トップレベルが不正、`jsonrpc` 欄欠落 → `-32600`）
  - Method not found (`-32601`)
  - Invalid params (`-32602`)
  - Notification（`id` 欠落）：レスポンスなし
  - Mixed batch（通知 + 正常 + 無効）
  - Empty batch（推奨デフォルト: `-32600` を期待。実装差がある場合は別テストで明示）
  - `id` に関する特殊ケース：`null`、重複、非プリミティブ（オブジェクト/配列）

  フォーマットとメタ情報

  - すべての `expected-*.json` は有効な JSON-RPC レスポンスオブジェクトまたはオブジェクト配列であること（期待値ファイル自体を不正 JSON にしない）
  - 実装依存や順序許容などは `expected-*.meta.json` で表現する（例: `{"order":"unordered","notes":"..."}` ）
  - テストハーネスは `result` / `error` の内容と `id` の一致で判定する仕様とする

  運用上の注意

  - 生成物はリポジトリのハーネス（`run-tests.py` / `run-tests.sh`）で実行可能な形にすること。特別な手順が必要な場合は `exercises/<NNN-name>/README.md` に手順を記載する
  - エージェントのプロンプト／テンプレートは `.github/agents/json-rpc-ideas.agent.md` に置き、ルールの参照先としてルート `AGENTS.md` を示すこと

  例（簡潔）

  - リクエスト: `{"jsonrpc":"2.0","method":"add","params":[1,2],"id":1}`
    - 期待: `{"jsonrpc":"2.0","result":3,"id":1}`
  - パースエラー例（切れた JSON）
    - 期待: `{"jsonrpc":"2.0","error":{"code":-32700,"message":"Parse error"},"id":null}`

  品質基準

  - 各エクササイズは 1–2 文の学習目的と最低 3 件のテストを持つこと
  - 自動実行可能で機械判定しやすい期待値（`result`/`error` と `id`）を優先する

  補足ノート

  - `id:null` と `id` 欠落（通知）の違いを明確にする（デフォルト規則を文書化）。実装差をテストする場合は `*.meta.json` で明示。
  - 空バッチのデフォルト期待値は `-32600` を推奨するが、代替挙動を検証する追加テストは許容する。

  ---

  このファイルはマージ草案です。レビュー後、ルート `AGENTS.md` を上書きするか、必要に応じて `.github/agents/json-rpc-ideas.agent.md` を更新します。
