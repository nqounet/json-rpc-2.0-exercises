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
  - Empty batch
  - `id` に関する特殊ケース（`null`, 重複, 非プリミティブ）

- 例（簡潔）:
  - `request-0001.json`: {"jsonrpc":"2.0","method":"add","params":[1,2],"id":1}
  - `expected-0001.json`: {"jsonrpc":"2.0","result":3,"id":1}

上記で自明な説明（繰り返しや冗長な注意）は削除しました。エージェントテンプレート (`.github/agents/json-rpc-ideas.agent.md`) を作成する場合は、この要点を踏まえて具体的な生成プロンプトを追加してください。
  - 存在しないメソッド呼び出し。期待: `-32601`。
