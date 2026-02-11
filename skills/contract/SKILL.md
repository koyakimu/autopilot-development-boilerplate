---
name: contract
description: >
  This skill should be used when the user asks to "generate contract",
  "start Phase 2", "create implementation contract", "Contractを生成",
  "Phase 2を開始", or wants to autonomously generate the technical
  Contract from approved Specs. Automatically delegates to the
  apd:checkpoint agent for cross-review.
tools: ["Read", "Write", "Glob", "Grep", "Bash"]
---

# APD Phase 2: Contract — 実装契約の自律生成

APDフレームワークにおけるリーダーエージェントとして、Phase 2: Contractを自律実行する。

Phase 2は「AIの時間」である。AIが自律でContractを生成し、AIチェックポイントを経て、Human Checkpoint 2（軽量）で承認を得る。

## 事前準備

以下のファイルを全て読み込む:

1. **CLAUDE.md** — プロジェクト設定（技術スタック、テスト戦略、コーディング規約、エスカレーションポリシー、インターフェースフォーマット）
2. **`docs/apd/design/product-design.md`** — Design文書
3. **`docs/apd/specs/*.md`** — 承認済みSpecファイル全て
4. **`docs/apd/decisions/*.md`** — Decision Records全て
5. **アクティブサイクル** — `docs/apd/cycles/` の最新ファイル

## Contract生成

### 必須項目

以下の6セクションを含むContractを生成する:

#### 1. 技術アーキテクチャ
- Specの全要件に対する技術的実現方法
- 使用する技術スタック（技術選定Decision Recordsの決定結果に基づく。CLAUDE.mdの設定がある場合はそれに従う）
- 各技術選定の根拠として対応するDecision Record ID（D-{NNN}）を参照する
- ディレクトリ構成

#### 2. コンテキスト間境界（インターフェース定義）
- CLAUDE.mdの `interface_format` に従った形式で記述
- 各コンテキスト間のデータフローを具体的な型/スキーマで定義
- `_cross-context-scenarios.md` の各シナリオに対する技術的実現方法

#### 3. 実装タスク分解
- Phase 3で並列実行可能な単位にタスクを分解
- 各タスクの:
  - 担当コンテキスト
  - 入力（他タスクへの依存があれば明記）
  - 出力（成果物）
  - 参照するSpec ID
  - 完了条件

#### 4. テスト戦略
- CLAUDE.mdのテスト戦略設定に従う
- Specの受け入れ条件との対応表（どのテストがどのACをカバーするか）
- 単体テスト / 統合テスト / E2Eテストの範囲と方針
- コンテキスト間結合検証の方法

#### 5. 並列実行計画
- 並列化の単位（どのタスクを同時実行できるか）
- 独立性の確保方法（スタブ/モック戦略）
- 結合検証のタイミングと方法
- 並列化する場合のgit worktree作成計画（タスクブランチ名の命名、`06-git-strategy.md` 参照）

#### 6. 成果物プレビュー（必須）

Specの `ui_description` やコンテキスト境界の記述を元に、具体的なプレビューを生成する。

##### プレビュー種別の判定

| 条件 | 必須プレビュー |
|------|---------------|
| UIを持つプロジェクト | HTMLモック（`screens/*.html`）|
| APIを提供するプロジェクト | API仕様書（`api-spec.md`）|
| 複数コンポーネントがある | アーキテクチャ図（Mermaid, `architecture.md`）|
| データベースを使用する | データモデル図（Mermaid ER図, `data-model.md`）|

**最低1つ（アーキテクチャ図）は全プロジェクトで必須。**

##### 出力先・宣言

- `docs/apd/contract/previews/C-{NNN}/` に配置する（`05-deliverable-preview.md` 参照）
- Contract末尾の「Deliverable Previews」セクションで一覧を宣言する
- AIチェックポイントに進む前にプレビューファイルが存在しなければならない

### 出力

`docs/apd/contract/project-contract.v{N}.md` にMarkdown形式（YAML frontmatter付き）で書き出す。
既存Contractがある場合はバージョンをインクリメントする。

## AIチェックポイント

Contract生成後、**apd:checkpoint エージェントに委譲して**、Spec⇔Contractのクロスレビューを実行する。

委譲時に以下を伝える:
- レビュー対象フェーズ: contract
- Contract ファイルパス
- Specs ディレクトリパス

apd:checkpoint エージェントが以下の観点で検証する:
1. **Spec網羅性**: 全Specの全受け入れ条件がContractのどこかでカバーされているか
2. **整合性**: タスク間の依存関係に循環がないか、インターフェース定義が双方で一致しているか
3. **テスト妥当性**: テスト戦略がSpecの受け入れ条件を十分にカバーしているか
4. **並列化可能性**: 並列実行計画が実際に独立して実行可能か

## チェックポイント結果の処理

apd:checkpoint エージェントの結果を受け取ったら:

- **verdict: approve** → Human Checkpoint 2を提示
- **verdict: request_changes** → 指摘事項を修正してContractを更新し、再度チェックポイントを実行

## Human Checkpoint 2

AIチェックポイントの結果サマリー（`human_checkpoint_summary`）を提示する。

- [ ] AI Checkpoint の全項目が pass になっているか
- [ ] escalation_required が false であるか
- [ ] escalation_items がある場合、各項目について判断を記入したか
- [ ] 成果物プレビューが期待通りか
- [ ] 技術選定Decision Recordsの決定結果が反映されているか

### 承認処理

ユーザーが承認した場合、以下を **全て** 実行する:

1. **Contract のステータス更新**:
   - `status: "draft"` → `status: "approved"`
   - `approved_at: null` → `approved_at: "{現在のISO 8601タイムスタンプ}"`
2. **サイクルファイルの更新**:
   - `phases.contract.status: "completed"`
   - `phases.contract.checkpoint_at: "{現在のISO 8601タイムスタンプ}"`
3. 「`/apd:execute` を実行してPhase 3に進んでください」と案内する

差し戻しの場合は指摘に基づきContractを修正し、再度チェックポイントから実行する。

**重要: Contract の `status` が `approved` に更新されるまで、Phase 3 に進むことはできない。**
