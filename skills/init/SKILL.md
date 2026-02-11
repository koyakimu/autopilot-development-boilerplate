---
name: init
description: >
  This skill should be used when the user asks to "initialize APD",
  "set up APD", "start APD in this project", "APDを初期化",
  "APDをセットアップ", or wants to set up the APD framework
  in their project. Copies rules and creates the document directory tree.
tools: ["Read", "Write", "Glob", "Grep", "Bash"]
---

# APD Init — プロジェクト初期化

APDフレームワークをプロジェクトに初期化する。ルールファイルのコピーとドキュメントディレクトリツリーの作成を行う。

## 手順

### 1. 既存状態の確認

以下を確認する:
- `.claude/rules/apd/` が既に存在するか
- `docs/apd/` が既に存在するか

既に存在する場合はユーザーに確認する:
- 「既にAPDが初期化されています。ルールファイルを最新版に更新しますか？」

### 2. ルールファイルのコピー

プラグインに同梱されているルールファイルをプロジェクトにコピーする。

以下のBashコマンドを実行する:

```bash
# ルールディレクトリの作成
mkdir -p .claude/rules/apd

# プラグインからルールファイルをコピー
cp "${CLAUDE_PLUGIN_ROOT}/rules/apd/00-principles.md" .claude/rules/apd/
cp "${CLAUDE_PLUGIN_ROOT}/rules/apd/01-phases.md" .claude/rules/apd/
cp "${CLAUDE_PLUGIN_ROOT}/rules/apd/02-cycle-flow.md" .claude/rules/apd/
cp "${CLAUDE_PLUGIN_ROOT}/rules/apd/03-documents.md" .claude/rules/apd/
cp "${CLAUDE_PLUGIN_ROOT}/rules/apd/04-testing.md" .claude/rules/apd/
cp "${CLAUDE_PLUGIN_ROOT}/rules/apd/05-deliverable-preview.md" .claude/rules/apd/
cp "${CLAUDE_PLUGIN_ROOT}/rules/apd/06-git-strategy.md" .claude/rules/apd/
```

### 3. ドキュメントディレクトリツリーの作成

```bash
mkdir -p docs/apd/{design,specs,contract/previews,decisions,cycles}
```

### 4. 完了メッセージ

以下を出力する:

```
## APD 初期化完了

コピーされたもの:
  - .claude/rules/apd/  — APDフレームワーク方針（Claude Codeが自動ロード）

作成されたディレクトリ:
  - docs/apd/design/     — Design文書
  - docs/apd/specs/      — Spec文書
  - docs/apd/contract/   — Contract文書
  - docs/apd/decisions/  — Decision Records
  - docs/apd/cycles/     — サイクル定義

次のステップ:
  /apd:cycle でサイクルを開始（または /apd:design でDesign文書を作成）
```

## 注意事項

- ルールファイルは `.claude/rules/apd/` にコピーされ、Claude Codeが自動でコンテキストにロードする
- `docs/apd/` は空のディレクトリツリーが作成される（既存ファイルは上書きしない）
- 次回のセッションからAPDフレームワークのルールが自動適用される
