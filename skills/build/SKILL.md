---
name: build
description: >
  This skill should be used when the user asks to "start build",
  "start Phase 2", "start implementation", "implement the code",
  "ビルドを開始", "実装を開始", "Phase 2を開始", or wants to
  autonomously implement code based on approved Specs. Delegates to
  apd:peer-review and apd:checkpoint agents automatically.
tools: ["Read", "Write", "Edit", "Glob", "Grep", "Bash"]
---

# APD Phase 2: Build — 計画・実装の自律実行

APDフレームワークにおけるリーダーエージェントとして、Phase 2: Buildを管理する。

Phase 2は「AIの時間」である。承認済みSpecに基づき、AIが自律で計画・プレビュー生成・実装・テストを行い、AIチェックポイントを経て、Human Checkpoint 2（軽量）で承認を得る。

## 事前準備

以下のファイルを全て読み込む:

1. **CLAUDE.md** — プロジェクト設定（技術スタック、コーディング規約、テスト戦略）
2. **`docs/apd/design/product-design.md`** — Design文書
3. **`docs/apd/specs/*.md`** — 承認済みSpecファイル全て
4. **`docs/apd/decisions/*.md`** — Decision Records全て
5. **アクティブサイクル** — `docs/apd/cycles/` の最新ファイル
6. **Git環境のセットアップ**
   - サイクルブランチが存在しない場合は作成する: `git checkout -b apd/C-{NNN}/{short-description}`
   - 並列実行する場合はgit worktreeを作成する（`06-git-strategy.md` 参照）

## Step 1: 成果物プレビューの生成

実装開始前に、Specの `Deliverable Previews` セクションと `UI Description` セクションを元に、具体的なプレビューを生成する。

### プレビュー種別の判定

| 条件 | 必須プレビュー |
|------|---------------|
| UIを持つプロジェクト | HTMLモック（`screens/*.html`）|
| APIを提供するプロジェクト | API仕様書（`api-spec.md`）|
| 複数コンポーネントがある | アーキテクチャ図（Mermaid, `architecture.md`）|
| データベースを使用する | データモデル図（Mermaid ER図, `data-model.md`）|

**最低1つ（アーキテクチャ図）は全プロジェクトで必須。**

### 出力先

`docs/apd/previews/C-{NNN}/` に配置する（`05-deliverable-preview.md` 参照）。

## Step 2: 実装タスクの計画

Specの要件を分析し、実装タスクを内部的に計画する。この計画はドキュメントとして永続化せず、AIの作業管理として扱う。

### 計画内容

1. **タスク分解** — Specの各ACを実現するための実装タスクを特定する
2. **並列化判定** — 独立して実行可能なタスクを特定する
3. **テスト戦略** — SpecのAC Coverageテーブルに基づき、テスト方針を決定する
4. **技術判断** — Decision Recordsの決定に従う。CLAUDE.mdの設定がある場合はそれに従う

TodoWriteツールを使って各タスクの進捗を管理する。

## Step 3: 実装タスクの実行

### 各タスクの実行ルール

1. 対応するSpec IDの受け入れ条件（AC）を確認する
2. CLAUDE.mdのコーディング規約に従う
3. 他コンテキストの実装に直接依存しない（スタブ/モックで独立性を確保）
4. **SpecのGiven/When/Then形式の受け入れ条件（AC）から直接テストコードを生成する**（ACがそのままテストケースになる）
5. テストを書いてから実装する（TDD推奨だが必須ではない）
6. 全テストがパスすることを確認する

### ToDo記録

実装中に「現サイクルのスコープ外だが将来対応すべき改善点・アイデア」を発見した場合、`docs/apd/todo.md` にToDoとして追記する。

- 起源は `Phase 2 Build中` とする
- 経緯には発見した状況と背景を記録する
- 現サイクルの実装には含めない

### 判断のエスカレーション

実装中に判断が必要になった場合:
1. **CLAUDE.mdに明記されている** → それに従う
2. **CLAUDE.mdに書かれていない** → リーダーエージェント（自分自身）が判断する
3. **自分が判断できない** → Human Checkpointにエスカレーション

**CLAUDE.mdのエスカレーションポリシーに該当する場合は必ず人間にエスカレーションする。**

## Step 4: ピアレビュー

各コンテキストの実装が完了したら、**apd:peer-review エージェントに委譲して**クロスコンテキストレビューを実行する。

委譲時に以下を伝える:
- レビュー対象のコンテキスト/タスクID
- 関連するSpecファイル

ピアレビューの結果:
- **verdict: approve** → 次のタスクまたはStep 5へ
- **verdict: request_changes** → 指摘事項を修正して再レビュー

## Step 5: 結合検証

全タスク完了後:

1. コンテキスト間のインターフェースが正しく接続されているか検証
2. `docs/apd/specs/_cross-context-scenarios.md` の各シナリオを実行（存在する場合）
3. 統合テスト / E2Eテストを実行
4. 全テストがパスすることを確認
5. 並列実行した場合、全タスクブランチをサイクルブランチにマージする
6. マージコンフリクトがあれば解消する
7. worktreeをクリーンアップする

## Step 6: AIチェックポイント

全タスクとピアレビューが完了したら、**apd:checkpoint エージェントに委譲して**最終品質検証を実行する。

委譲時に以下を伝える:
- レビュー対象フェーズ: build
- 実装コードのディレクトリ: `src/`
- テストコードのディレクトリ: `tests/`
- Specsディレクトリパス
- プレビューディレクトリパス

apd:checkpoint エージェントが以下を検証する:
- Spec全要件の実装状況
- テスト全パス
- テスト品質（AC網羅、実質的アサーション、エラーケース）
- コーディング規約準拠
- 成果物プレビューの存在

## チェックポイント結果の処理

apd:checkpoint エージェントの結果を受け取ったら:

- **verdict: approve** → Human Checkpoint 2を提示
- **verdict: request_changes** → 指摘事項を修正して再度チェックポイントを実行

## Human Checkpoint 2（完成品確認）

AIチェックポイントの結果サマリーと合わせて、**完成品を確認するためのチェックリスト**を提示する。

人間に求めるのは「動く成果物が意図通りか」の確認であり、コードレビューではない。

- [ ] 成果物プレビュー（UI/CLI/API等）が期待通りの動作をするか
- [ ] Design文書の Success Criteria を満たしているか
- [ ] 全テストがパスしているか（サマリーのみ確認）
- [ ] escalation_items がある場合、各項目について判断を記入したか

**コードを読むかどうかは人間の判断に任せる。フレームワークとしては求めない。**

承認されたら「サイクル完了です」と報告する。
差し戻しの場合は新しいバグ修正サイクル（`/apd:cycle`）として対応する。
