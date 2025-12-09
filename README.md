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

## 推奨ディレクトリ構成 (提案) 📁

```
.
├── exercises/                # 演習問題（解く対象）
│   ├── exercise-001-intro/
│   │   ├── problem.md        # 問題説明・受け入れ基準(acceptance criteria)
│   │   ├── tests/            # 言語非依存のテスト資産 (example requests/responses, fixtures)
│   │   └── hints.md          # ヒント（任意）
│   └── exercise-002-.../
├── solutions/                # 各演習に対する模範解答（言語別サブフォルダ）
│   ├── exercise-001-intro/
│   │   ├── solution.md       # 解説 / 実装方針
│   │   └── code/             # 言語別の実装例（python/, js/, go/ など）
├── examples/                 # 最小実装のサーバ / クライアント例
├── spec/                     # 参照資料（JSON-RPC 2.0 の軽量まとめ or リンク）
├── tools/                    # ビルド・テスト・ハーネス（例: test-runner）
├── docs/                     # 使い方、学習ロードマップ、FAQ
├── scripts/                  # CI / ローカル実行用スクリプト
└── .github/                  # Issue / PR / Actions （テンプレートやワークフロー）
```

---

## 演習 (exercises) のフォーマット案 💡
- problem.md
	- 説明 (context)、要求 (what to implement)、受け入れ条件 (acceptance criteria)
	- 入出力の例（リクエストと期待されるレスポンス）
- tests/
	- JSON 形式の fixtures や統合テスト（ex: request/expected_response）
- hints.md（任意）
	- 難易度や部分的なヒント
- metadata.json（任意）
	- id, title, difficulty, topics (json-rpc, notifications, batch), estimated_time

命名規則: `exercise-XXX-short-desc`（1-indexed、3桁のゼロ埋め）

---

## 解答 (solutions) の取り扱い ⚖️
- ソルーションを同一リポジトリの `solutions/` 以下に置くか、別ブランチ（例: `solutions` ブランチ）として管理するかを選べます。
	- 教育目的で公開するなら `solutions/` を置くのが便利
	- 自習用・挑戦用に先に答えを隠したい場合は `solutions` ブランチを利用することを推奨

重大な決定: ソリューションの公開方法（同ブランチ or ブランチ分離）については、運用方針の確定が必要です。人間による最終確認をお願いします。

---

## テスト / 実行ガイド 🔧
- 本リポジトリは言語アグノスティックを意図しているため、各言語の実装例は `solutions/*/code/` に置きます。
- まずは `examples/` や `tools/test-runner` を用いて、言語・実行環境ごとの動作確認を行う計画を推奨します。

推奨コマンド例（追加ファイルが実装された後）:

```bash
# 言語別テストランナーの例
./scripts/run-tests.sh --exercise exercises/exercise-001-intro
```

---

## Contributing ✍️
- 新しい演習を追加する際は、`exercises/` に `exercise-XXX` ディレクトリを作り、`problem.md` と `tests/` を提供してください。`metadata.json` を付けると管理しやすくなります。
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
License: Apache-2.0

---
