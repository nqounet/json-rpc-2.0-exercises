# json-rpc-2.0-exercises

✅ 練習問題と解答で学ぶ JSON-RPC 2.0 ハンズオン集

このリポジトリは、JSON-RPC 2.0 の仕様理解と実装経験を得るための一連の演習問題 (exercises) とその解答 (solutions) を収める教材リポジトリです。

---

## 目的 🎯
- JSON-RPC 2.0（仕様）を実装・利用するための実践的な演習を通じて理解を深める
- 各種言語・環境でのクライアント・サーバ実装のサンプルとテストを揃える
- 教育・面接対策・自習用のリソースを提供する

## 想定読者 👥
- サーバ/クライアント実装者
- WebRPC やマイクロサービスの学習者
- 面接準備やコーディング演習をしたい方

---

## ディレクトリ構成 📁

```
.
├── exercises/                # 演習問題（解く対象）
│   ├── 001-intro/
│   │   ├── problem.md        # 問題説明・受け入れ基準(acceptance criteria)
│   │   └── hints.md          # ヒント（任意）
│   └── 002-.../
├── solutions/                # 各演習に対する模範解答（言語別サブフォルダ）
│   ├── 001-intro/
│   │   ├── solution.md       # 解説 / 実装方針
│   │   └── code/             # 言語別の実装例（python/, js/, go/ など）
│   └── 002-.../
├── examples/                 # 最小実装のサーバ / クライアント例
├── spec/                     # 参照資料（JSON-RPC 2.0 の軽量まとめ or リンク）
├── tests/                    # 言語非依存のテスト資産 (request/expected fixtures), top-level に配置
│   ├── 001-intro/
│   └── 002-.../
├── tools/                    # ビルド・テスト・ハーネス（例: test-runner）
├── docs/                     # 使い方、学習ロードマップ、FAQ
├── scripts/                  # CI / ローカル実行用スクリプト
└── .github/                  # Issue / PR / Actions （テンプレートやワークフロー）
```

---

## 演習 (exercises) のフォーマット 💡
- problem.md
	- 説明 (context)、要求 (what to implement)、受け入れ条件 (acceptance criteria)

Note: Individual exercises may define their own numeric constraints or limits. For example, `exercises/005-prime-factors/problem.md` uses a maximum allowed value of `2^32 - 1` (`4294967295`).
	- 入出力の例（リクエストと期待されるレスポンス）
- hints.md（任意）
	- 難易度や部分的なヒント
- metadata.json（任意）
	- id, title, difficulty, topics (json-rpc, notifications, batch), estimated_time

### Problem file requirements — `problem.md` / `problem.en.md` の必須項目

新しい演習問題を追加する際、`problem.md`（日本語版）および `problem.en.md`（英語版）は下記の必須セクションを必ず含めてください。将来の整合性のために、このフォーマットをリポジトリ標準とします。

必須セクション:
- 日本語版（`problem.md`）: `要件`, `受け入れ条件`, `難易度` を必ず含めること。
- 英語版（`problem.en.md`）: `Requirements`, `Acceptance criteria`, `Difficulty` を必ず含めること。

目的: 明確な受け入れ基準を定義することで、自動テストやレビューが容易になり、解答実装の品質が保たれます。

推奨フォーマット（テンプレート）:

````markdown
```markdown
# <Exercise Number> — Short title

Context:
- Short description of the scenario and what the student should implement.

Requirements:
- Bullet list of functional requirements (what the implementation must do).

Acceptance criteria:
- Bullet list of concrete acceptance steps (how tests will verify correctness). Include details about input/output, error handling, and expected JSON-RPC behavior.

Difficulty: ⭐ (or 1-5, or other scale)

Examples:
Request:
```json
{ ... }
```

Expected response:
```json
{ ... }
```

```
````

注意事項:
- 見出しは上記と同等の意味であれば日本語/英語どちらでも構いませんが、CI やレビュワーが機械的に判別しやすいように英語版には必ず英語の見出し（`Requirements` / `Acceptance criteria` / `Difficulty`）を含めてください。
- 受け入れ条件は曖昧な表現を避け、テストフィクスチャ（`tests/`）の形式に合わせて明確に書いてください（stdin/stdout、HTTP、通知の扱いなど）。
- 将来的に自動チェックを追加する場合、この README の必須セクションを検証ルールとして利用できるように設計してください。


多言語対応:
- 各演習および解答は日本語と英語の両方の版を含めることを推奨します。
- 日本語版のファイル名: `problem.md` （演習）および `solution.md` （解説）。
- 英語版のファイル名: `problem.en.md` （演習, English）および `solution.en.md` （解説, English）。
- CI やツールはこの命名規則を期待するため、新規追加時は両言語ファイルを用意してください（翻訳が未完の場合は一時的に原文をコピーしても構いません）。

命名規則: `XXX-short-desc`（1-indexed、3桁のゼロ埋め）

---

## 解答 (solutions) の取り扱い ⚖️
- 本リポジトリでは、**解答 (solutions) は main ブランチに含める** 方針です（公開型学習リポジトリを想定）。
- 各演習の解答は `solutions/<exercise>/` に配置し、言語ごとの実装例は `solutions/<exercise>/code/<language>/` に格納します。

重要: この方針は公開学習向けに最適化したもので、もしコンテスト/課題形式で正答を隠す必要があるなら、別ブランチ・プライベートリポジトリを検討してください。

---

## テスト / 実行ガイド 🔧
- 本リポジトリは言語アグノスティックを意図しており、言語非依存のテスト（fixtures）はリポジトリルートの `tests/` に置きます。
- 各言語の実装例は `solutions/*/code/` に置きます。まずは `examples/` や `tools/test-runner` を用いて、言語・実行環境ごとの動作確認を行う計画を推奨します。

### JSON fixtures の書き方

- **プレーンな JSON ファイルのみ**: `tests/` に置く fixture ファイルは Markdown のようにコードフェンス（```）で囲まないでください。ファイルは「純粋な JSON」だけを含む必要があります（例: `request-0001.json`, `expected-0001.json`）。
- **単一の JSON 値**: 各 JSON ファイルは単一の JSON 値（オブジェクトまたは配列）を含めてください。複数の JSON ドキュメントを1ファイルにまとめないでください。
- **エンコーディング / 改行**: UTF-8 で保存し、ファイルの最後に改行を入れてください（POSIX 互換）。
- **命名規則**: リクエストは `request-XXXX.json`、期待値は `expected-XXXX.json`（4 桁の連番ではなく既存のプロジェクト規約に合わせる）を使ってください。ペアが分かりやすいように同じ番号を付けます。
- **バッチ／配列の扱い**: バッチリクエストを表す `request-*.json` は JSON 配列を使い、対応する `expected-*.json` はサーバが返す配列（または通知を含む場合は要件に従う）を置いてください。
- **フォーマット例**: （例示は README 表示用のコードフェンスで示しますが、実際の fixture ファイルにはフェンスを含めないでください）

```json
{
	"jsonrpc": "2.0",
	"method": "multiply",
	"params": [2, 3],
	"id": 1
}
```

```json
{
	"jsonrpc": "2.0",
	"result": 6,
	"id": 1
}
```

上記の例は README 中での表示用です。実際の fixture ファイル（`tests/.../request-....json` など）には上記 JSON をそのまま（コードフェンスなしで）保存してください。

### サンプル言語のデフォルト: Perl
- 本リポジトリのデフォルトのサンプル/参照実装言語は **Perl** に変更しました。理由は次のとおりです:
 	- 既存の演習とソリューションに Perl の実装例が整っていること
 	- `Plack` / `JSON::RPC::Lite` 等の軽量な Web/JSON ランタイムが利用でき、テストハーネスと組み合わせやすい
 	- 教育用途として言語バリエーションを増やすことで多様な受講者に対応できる

信頼度: 高（学習/サンプル用途における選択）

推奨コマンド例（追加ファイルが実装された後）:

```bash
# 言語非依存なテストをルートの fixtures で実行
./scripts/run-tests.sh --lang=perl

追加オプション:
- `--exercises` / `-e` : コンマ区切りで実行する演習を指定（例: `001-intro,002-...`）
- `--host` : テスト内で参照されるホスト名（ソリューションは `TEST_HOST` 環境変数で受け取れます）
- `--port` : テスト内で参照されるポート番号（ソリューションは `TEST_PORT` 環境変数で受け取れます）
 - `--all` : すべての演習を強制実行（`--exercises` の指定や CI の差分検出を上書き）

例:
```bash
# 全テスト（デフォルト）
./scripts/run-tests.sh

# 複数演習を指定して実行
./scripts/run-tests.sh --exercises 001-intro,002-foo

# ホスト/ポートと合わせて実行
# - テスト実行時に `--host`/`--port` を指定すると、Python サンプル実装が `--http` オプションで起動された場合は自動でサーバを起動してテストを実行します。
./scripts/run-tests.sh --host 127.0.0.1 --port 8080
```

ローカル実行例:
```bash
chmod +x ./scripts/run-tests.sh
./scripts/run-tests.sh
```

CI (GitHub Actions):
- GitHub Actions workflow は `.github/workflows/ci.yml` に定義されており、`push` / `pull_request`（main ブランチ）イベントで `scripts/run-tests.sh` を実行します。
 - GitHub Actions workflow は `.github/workflows/ci.yml` に定義されており、`push` / `pull_request`（main ブランチ）イベントで `scripts/run-tests.sh` を実行します。
 - CI は差分のある演習のみを検出し、変化のあった `exercises/*`・`solutions/*`・`tests/*` の変更に基づいて、対応する演習だけを実行するように最適化されています。

### テスト実行のガイドライン（明確化）

このプロジェクトでテストを実行するときに迷わないよう、よく使うコマンドと環境変数、期待される出力の意味を明確にまとめます。

- 実行コマンド（推奨）
  - 単一演習を実行する（例: 009 を Perl 実装で実行）:

```bash
./scripts/run-tests.sh --lang perl -e 009-echo-with-meta
```

  - すべての演習を実行:

```bash
./scripts/run-tests.sh --lang perl
```

  - 直接 Python スクリプトを呼ぶ場合（実行権限がない/シェルの問題がある場合）:

```bash
python3 ./scripts/run-tests.py --exercises 009-echo-with-meta --lang perl
```

- 固定時刻が必要なテスト（タイムスタンプ）
  - 一部の演習はサーバ側で生成される `timestamp` によって期待値が異なります。CI やローカルで determinisitic にテストするため、サーバ実装は `TEST_TIME` 環境変数を参照して固定時刻を返すようにすることを推奨します。
  - 例（期待 fixture の timestamp に合わせる）:

```bash
TEST_TIME="2020-01-01T12:00:00Z" ./scripts/run-tests.sh --lang perl -e 009-echo-with-meta
```

- テスト時に利用される環境変数
  - `TEST_HOST` / `TEST_PORT` : HTTP モードでソリューションを起動する際（`--http` をサポートする実装）に使用されます。runner はこれらを環境変数として渡します。
  - `TEST_TIME` : 上述。オプションだが、タイムスタンプ固定が必要なテストでは必須にすることで差分を防げます。

- 出力の読み方 / 期待される動作
  - ランナーは各 fixture ごとに `OK` / `FAIL` を表示します。失敗した場合は期待値 (`expected`) と実際の出力 (`got`) を JSON で表示します。
  - 標準エラーに出力がある場合、実装側でログや例外が発生しています。`STDERR` の内容を確認してください。
  - 通知（notifications）: リクエストが通知（`id` を含まない）の場合、サーバは応答しないことが期待されます（出力は空）。ランナーは空出力を通知として扱います。

- 終了コード
  - 0 : すべてのテストが合格
  - 2 : 1 件以上のテスト失敗（runner のデフォルト）
  - その他 : 実行環境や依存関係の問題（例: スクリプトの起動失敗）

- 欠損している実装の扱い
  - 指定した言語のソリューションが存在しない場合、ランナーは該当テストを `MISSING-SOLUTION` としてレポートします。実装がない場合は `solutions/<exercise>/code/<language>/server.*` を追加してください。

- よくあるトラブルシューティング
  - `permission denied` エラー: スクリプトに実行権限がない場合があります。`chmod +x ./scripts/run-tests.sh` あるいは `python3 ./scripts/run-tests.py ...` で実行してください。
  - Perl 実装でモジュールが見つからない: 例 `JSON::RPC::Spec` 等。CPAN または cpanminus でインストールしてください（例: `cpanm JSON::RPC::Spec` あるいは `cpan -i JSON::RPC::Spec`）。
  - テストがタイムスタンプで失敗する: `TEST_TIME` を指定して再現性を持たせてください。

- ヒント: ローカルでデバッグするとき
  - 単一の request fixture を stdin から直接渡して実行結果を早く確認できます（Perl 実装の例）:

```bash
cat tests/009-echo-with-meta/request-0001.json | perl solutions/009-echo-with-meta/code/perl/server.pl
```

このガイドラインを守ることで、テストの実行・デバッグが安定して行えるはずです。

---

## Contributing ✍️
- 新しい演習を追加する際は、`exercises/` に `XXX` ディレクトリを作り、`problem.md` と `tests/` を提供してください。`metadata.json` を付けると管理しやすくなります。
- 解答は `solutions/` 以下に配置し、`problem.md` に書かれた受け入れ基準を満たすコード・解説を含めてください。

PR のテンプレート案（`.github/pull_request_template.md`）:
- 目的
- 追加/変更内容
- テスト手順
- 実装言語

---

## 参照 (根拠) 📚
- JSON-RPC 2.0 specification — https://www.jsonrpc.org/specification  (公式仕様)

設計の根拠: 上記公式仕様をベースにし、学習リポジトリとして「演習は可搬性を重視（言語非依存の tests）」を採用することで、受講者が複数言語で学べるようにしています。

信頼度: 高（仕様への直接リンクを参照） — ただし、運用や実装の詳細（ディレクトリ命名規約、`solutions` のブランチ/ディレクトリ）はプロジェクト運営方針に依存します。重要な決定は運営担当者の合意をお願いします。

---

## 次のステップ（提案） 📌
1. この README の構成に同意するか確認してください（特に `solutions` の扱い）
2. CI とテストハーネス（例: `tools/test-runner` / `scripts/run-tests.sh`）の設計を追加する
3. 最初の 3 つの演習（intro, request/response, notifications）を `exercises/` に追加し、`solutions/` に模範実装を追加する

---

Maintainers: @nqounet
License: MIT

---

## ガバナンス — 設計選択の根拠と信頼度 🔎
- すべての大きな設計選択（例: 解答の公開方針、テストの配置、サンプル言語の選択）は、理由と根拠とともに README に記載します。
- 本 README に示した決定の例:
	- サンプル言語: Python — 理由: 教育/サンプルに適合し、CIでの実行が容易（信頼度: 高）
	- テスト: リポジトリルートに配置 — 理由: テストが言語非依存であるべきなので、言語ごとに分散しない（信頼度: 中-高）
	- ソリューション配置: main ブランチに含める — 理由: 学習用公開リポジトリに適しているため（信頼度: 中）
- 重要: 上記は推奨であり、最終的な運用方針（例: ソリューションを隠すか否か）はプロジェクト運営担当者の確認を要します。提案を採用する前に、チームで合意してください。
