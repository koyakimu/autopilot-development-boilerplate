---
name: apd-contract
description: >
  This skill should be used when the user asks to "generate contract",
  "start Phase 2", "create implementation contract", "Contractを生成",
  "Phase 2を開始", or wants to autonomously generate the technical
  Contract from approved Specs. Automatically delegates to the
  apd-checkpoint agent for cross-review.
tools: ["Read", "Write", "Glob", "Grep", "Bash"]
---

# APD Phase 2: Contract — 実装契約の自律生成

APDフレームワークにおけるリーダーエージェントとして、Phase 2: Contractを自律実行する。

Phase 2は「AIの時間」である。AIが自律でContractを生成し、AIチェックポイントを経て、Human Checkpoint 2（軽量）で承認を得る。

## 事前準備

以下のファイルを全て読み込む:

1. **CLAUDE.md** — プロジェクト設定（技術スタック、テスト戦略、コーディング規約、エスカレーションポリシー、インターフェースフォーマット）
2. **`design/product-design.yaml`** — Design文書
3. **`specs/*.yaml`** — 承認済みSpecファイル全て
4. **`decisions/*.yaml`** — Decision Records全て
5. **アクティブサイクル** — `cycles/` の最新ファイル

## Contract生成

### 必須項目

以下の5セクションを含むContractを生成する:

#### 1. 技術アーキテクチャ
- Specの全要件に対する技術的実現方法
- 使用する技術スタック（CLAUDE.mdのプロジェクトレベル設定に従う）
- ディレクトリ構成

#### 2. コンテキスト間境界（インターフェース定義）
- CLAUDE.mdの `interface_format` に従った形式で記述
- 各コンテキスト間のデータフローを具体的な型/スキーマで定義
- `_cross-context-scenarios.yaml` の各シナリオに対する技術的実現方法

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

### 出力

`contract/project-contract.v{N}.yaml` にYAML形式で書き出す。
既存Contractがある場合はバージョンをインクリメントする。

## AIチェックポイント

Contract生成後、**apd-checkpoint エージェントに委譲して**、Spec⇔Contractのクロスレビューを実行する。

委譲時に以下を伝える:
- レビュー対象フェーズ: contract
- Contract ファイルパス
- Specs ディレクトリパス

apd-checkpoint エージェントが以下の観点で検証する:
1. **Spec網羅性**: 全Specの全受け入れ条件がContractのどこかでカバーされているか
2. **整合性**: タスク間の依存関係に循環がないか、インターフェース定義が双方で一致しているか
3. **テスト妥当性**: テスト戦略がSpecの受け入れ条件を十分にカバーしているか
4. **並列化可能性**: 並列実行計画が実際に独立して実行可能か

## チェックポイント結果の処理

apd-checkpoint エージェントの結果を受け取ったら:

- **verdict: approve** → Human Checkpoint 2を提示
- **verdict: request_changes** → 指摘事項を修正してContractを更新し、再度チェックポイントを実行

## Human Checkpoint 2（軽量）

AIチェックポイントの結果サマリー（`human_checkpoint_summary`）を提示する。

通常は数分で通過する:
- [ ] AI Checkpoint の全項目が pass になっているか
- [ ] escalation_required が false であるか
- [ ] escalation_items がある場合、各項目について判断を記入したか

承認されたら「`/apd-execute` を実行してPhase 3に進んでください」と案内する。
差し戻しの場合は指摘に基づきContractを修正する。
