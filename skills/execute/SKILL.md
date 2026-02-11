---
name: execute
description: >
  This skill should be used when the user asks to "start implementation",
  "start Phase 3", "execute the contract", "implement the code",
  "実装を開始", "Phase 3を開始", or wants to autonomously implement
  code based on the approved Contract. Delegates to apd:peer-review
  and apd:checkpoint agents automatically.
tools: ["Read", "Write", "Edit", "Glob", "Grep", "Bash"]
---

# APD Phase 3: Execute — 実装の自律実行

APDフレームワークにおけるリーダーエージェントとして、Phase 3: Executeを管理する。

Phase 3は「AIの時間」である。Contractに基づきAIが自律で実装・テストを行い、AIチェックポイントを経て、Human Checkpoint 3（軽量）で承認を得る。

## 事前準備

以下のファイルを全て読み込む:

1. **CLAUDE.md** — プロジェクト設定（技術スタック、コーディング規約、テスト戦略）
2. **`docs/apd/contract/` の最新Contractファイル** — タスク分解、インターフェース定義、テスト戦略
3. **`docs/apd/specs/*.md`** — 承認済みSpecファイル全て
4. **`docs/apd/decisions/*.md`** — Decision Records全て
5. **アクティブサイクル** — `docs/apd/cycles/` の最新ファイル
6. **Git環境のセットアップ**
   - サイクルブランチが存在しない場合は作成する: `git checkout -b apd/C-{NNN}/{short-description}`
   - 並列実行する場合はgit worktreeを作成する（`06-git-strategy.md` 参照）

## Contract承認状態の検証

事前準備で読み込んだContractファイルの frontmatter を検証する:

1. `status` フィールドが `"approved"` であること
2. `approved_at` フィールドが null でないこと

**いずれかの条件を満たさない場合、即座に停止し以下を表示する:**

> ⛔ Contractが未承認です。`/apd:contract` でContract生成とHuman Checkpoint 2の承認を完了してから、再度 `/apd:execute` を実行してください。
>
> 現在のステータス: {status} / 承認日時: {approved_at}

**承認済みの場合のみ、Step 1 以降に進む。**

## Step 1: 実装タスクの実行

Contractの実装タスク分解に従い、各タスクを実行する。

### 各タスクの実行ルール

1. 対応するSpec IDの受け入れ条件（AC）を確認する
2. Contractのインターフェース定義に厳密に従う（勝手に変更しない）
3. CLAUDE.mdのコーディング規約に従う
4. 他コンテキストの実装に直接依存しない（スタブ/モックで独立性を確保）
5. テストを書いてから実装する（TDD推奨だが必須ではない）
6. 受け入れ条件の全項目に対応するテストを作成する
7. 全テストがパスすることを確認する

### 進捗管理

TodoWriteツールを使って各タスクの進捗を管理する。

### 判断のエスカレーション

実装中に判断が必要になった場合:
1. **CLAUDE.mdに明記されている** → それに従う
2. **CLAUDE.mdに書かれていない** → リーダーエージェント（自分自身）が判断する
3. **自分が判断できない** → Human Checkpointにエスカレーション

**CLAUDE.mdのエスカレーションポリシーに該当する場合は必ず人間にエスカレーションする。**

## Step 2: ピアレビュー

各コンテキストの実装が完了したら、**apd:peer-review エージェントに委譲して**クロスコンテキストレビューを実行する。

委譲時に以下を伝える:
- レビュー対象のコンテキスト/タスクID
- 関連するSpecファイル
- Contractのインターフェース定義

ピアレビューの結果:
- **verdict: approve** → 次のタスクまたはStep 3へ
- **verdict: request_changes** → 指摘事項を修正して再レビュー

## Step 3: 結合検証

全タスク完了後:

1. コンテキスト間のインターフェースが正しく接続されているか検証
2. `docs/apd/specs/_cross-context-scenarios.md` の各シナリオを実行（存在する場合）
3. 統合テスト / E2Eテストを実行
4. 全テストがパスすることを確認
5. 並列実行した場合、全タスクブランチをサイクルブランチにマージする
6. マージコンフリクトがあれば解消する
7. worktreeをクリーンアップする

## Step 4: AIチェックポイント

全タスクとピアレビューが完了したら、**apd:checkpoint エージェントに委譲して**最終品質検証を実行する。

委譲時に以下を伝える:
- レビュー対象フェーズ: execute
- 実装コードのディレクトリ: `src/`
- テストコードのディレクトリ: `tests/`
- Contractファイルパス
- Specsディレクトリパス

apd:checkpoint エージェントが以下を検証する:
- Contract全要件の実装状況
- テスト全パス
- テスト品質（AC網羅、実質的アサーション、エラーケース）
- コーディング規約準拠
- インターフェース定義準拠

## チェックポイント結果の処理

apd:checkpoint エージェントの結果を受け取ったら:

- **verdict: approve** → Human Checkpoint 3を提示
- **verdict: request_changes** → 指摘事項を修正して再度チェックポイントを実行

## Human Checkpoint 3（軽量）

AIチェックポイントの結果サマリー（`human_checkpoint_summary`）を提示する。

- [ ] 全テストがパスしているか
- [ ] AI Checkpoint レビューの全項目が pass か
- [ ] escalation_items がある場合、各項目について判断を記入したか
- [ ] モック/UI記述がある場合、期待通りの見た目か（目視確認）
- [ ] サイクルブランチがmainにマージ可能な状態か

承認されたら「サイクル完了です」と報告する。
差し戻しの場合は新しいバグ修正サイクル（`/apd:cycle`）として対応する。
