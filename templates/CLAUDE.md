# CLAUDE.md — Autopilot Development Framework

> このファイルはAPDフレームワークのボイラープレートからコピーされたものです。
> 「プロジェクトレベル設定」セクションをプロジェクトに合わせてカスタマイズしてください。

---

## フレームワークレベル（変更不可）

### 基本原則

- **人間の時間とAIの時間を分離する。** Phase 0〜1は人間の時間（対話的）、Phase 2〜3はAIの時間（自律実行）
- **AIフェーズの途中では人間の介入をゼロにする。** モック・ユーザーストーリー・テストを含め、人間の意図した通りの機能実装がAIで完走する
- **ドキュメントは上書きしない。** 修正が必要な場合はAmendment（差分ドキュメント）を発行する
- **判断に迷ったら自己判断せずリーダーに聞く。** 聞きすぎるほうが暴走するより安全

### 判断のエスカレーションフロー

1. **このCLAUDE.mdに明記されている** → それに従う
2. **このCLAUDE.mdに書かれていない** → リーダーエージェントに判断を仰ぐ
3. **リーダーエージェントが判断できない** → Human Checkpointにエスカレーション

頻出の判断はこのCLAUDE.mdに昇格させて自律範囲を広げていく。

### フェーズ定義

```
Phase 0: Design ── 人間 + AI 対話（並列化しない）
  成果物: プロジェクトデザイン文書（北極星）
  ─────────────── Human Checkpoint 0 ───────────────

Phase 1: Spec ── AIドラフト + 人間フィードバック（並列化しない）
  成果物: スペック集 + Decision Records
  ─────────────── Human Checkpoint 1 ───────────────
  ここから先、人間は基本介入しない

Phase 2: Contract ── AI自律
  成果物: プロジェクト契約
  AI Checkpoint → Human Checkpoint 2（軽量）

Phase 3: Execute ── AI自律・並列実行
  成果物: 実装 + テスト全パス
  AI Checkpoint → Human Checkpoint 3（軽量）
```

### Checkpointの原則

- **Human Checkpoint**: フェーズ境界に置く。方向性を確認して必要なら調整する確認ポイント
- **AI Checkpoint**: Human Checkpointの手前に置く。エージェント間クロスチェック
- Human Checkpointに上がる時点で、AIレビューサマリー + 要判断項目リストが付く
- 人間は「全量レビュー」ではなく「例外レビュー」を行う

### サイクル型統一フロー

すべての変更を「サイクル」として統一する。修正は新しいサイクルで行う（出戻りではなく前進）。

| トリガー | フロー |
|---------|--------|
| 新プロダクト / 大きな方向転換 | Design → Spec → Contract → Execute（フルサイクル）|
| 新機能追加 | Spec（既存Design参照）→ Contract差分 → Execute |
| バグ修正 / 小さな改善 | Spec Amendment → Execute（Contract変更なし）|
| 技術的変更（リファクタ等）| Contract Amendment → Execute（Spec変更なし）|

### イミュータブルなドキュメント管理

- ドキュメントは上書きしない。修正はAmendment（差分ドキュメント）を発行する
- 全サイクルの軌跡が時系列で参照可能
- AIの作業記録: Gitコミットログ + AI Checkpointレビューサマリー
- 人間の判断記録: Decision Record

### ドキュメントツリー

```
project/
├── CLAUDE.md
├── design/
│   └── product-design.yaml          ← 北極星（滅多に変わらない）
├── specs/
│   ├── {context}.v{N}.yaml          ← イミュータブル
│   ├── {context}.v{N}.A-{NNN}.yaml  ← Amendment
│   └── _cross-context-scenarios.yaml
├── contract/
│   ├── project-contract.v{N}.yaml   ← イミュータブル
│   └── project-contract.v{N}.C-{NNN}.yaml ← Amendment
├── decisions/
│   └── D-{NNN}.yaml                 ← 時系列で積み上がる
├── cycles/
│   └── C-{NNN}.yaml
└── src/ + tests/
```

### AI Checkpointエスカレーションポリシー（デフォルト）

**Human Checkpoint必須:**
- 新しいビジネスルール（既存Specにないドメインロジック）
- 外部システムとのインターフェース変更
- セキュリティ・認証に関わる変更
- データモデルの破壊的変更
- パフォーマンス要件の緩和

**AI Checkpoint完結:**
- UI調整（Design文書の範囲内）
- 既存ビジネスルール内のバリエーション追加
- リファクタリング（振る舞い変更なし）
- テストカバレッジ補強
- ドキュメント文言修正

### バグのトリアージ

バグ報告・テスト失敗が来たとき、AIがまず原因を判定する:
- **Spec起因**（仕様漏れ・曖昧さ）→ 人間にエスカレーション → Spec Amendmentサイクルへ
- **Execute起因**（実装がSpecと合っていない）→ AI自律で修正 → 人間に上げない

### デフォルトのスペックフォーマット

```yaml
spec_id: "{CONTEXT_ID}-{NNN}"
context: "{コンテキスト名}"
version: 1
cycle_ref: "C-{NNN}"

title: ""
user_story:
  as_a: ""       # 誰が
  i_want: ""     # 何を
  so_that: ""    # なぜ

acceptance_criteria:
  - id: "AC-001"
    given: ""
    when: ""
    then: ""

ui_description: ""   # モック or UI記述（該当する場合）

context_boundary:
  inputs: []
  outputs: []
  dependencies: []

notes: ""
```

### デフォルトのテスト方針

- テストが全パスしていることが必須
- 何をどうテストするかはContractでリーダーエージェントが定めるか、プロジェクトレベル設定で指定する
- テストの品質評価基準:
  - テストが受け入れ条件をカバーしているか
  - 形だけのテスト、何も検証していないアサーションがないか
  - エラーケース・境界条件のテストがあるか

---

## プロジェクトレベル設定（カスタマイズ対象）

> ⚠️ 以下をプロジェクトに合わせて編集してください

### プロジェクト概要

```yaml
project_name: "{{プロジェクト名}}"
description: "{{プロジェクトの概要}}"
design_ref: "design/product-design.yaml"
```

### 技術スタック

```yaml
language: "{{TypeScript / Python / etc.}}"
framework: "{{Next.js / FastAPI / etc.}}"
database: "{{PostgreSQL / DynamoDB / etc.}}"
infrastructure: "{{AWS / GCP / etc.}}"
package_manager: "{{npm / pnpm / pip / etc.}}"
```

### コーディング規約

- {{規約1: 例 — 関数名はcamelCase}}
- {{規約2: 例 — コンポーネントはPascalCase}}
- {{規約3: 例 — エラーハンドリングはResult型を使用}}

### テスト戦略（プロジェクト固有）

```yaml
unit_test:
  framework: "{{vitest / pytest / etc.}}"
  coverage_target: "{{80%}}"
  location: "tests/unit/"

integration_test:
  framework: "{{vitest / pytest / etc.}}"
  location: "tests/integration/"

e2e_test:
  framework: "{{playwright / cypress / etc.}}"
  location: "tests/e2e/"
```

### エスカレーションポリシー（プロジェクト固有の追加）

デフォルトポリシーに加え、以下のルールを追加する:

**Human Checkpoint必須（追加）:**
- {{例: 課金に関わるロジックの変更}}
- {{例: 個人情報の取り扱いに関する変更}}

**AI Checkpoint完結（追加）:**
- {{例: ログ出力の追加・変更}}

### スペックフォーマット（カスタマイズ）

デフォルトフォーマットに加え、以下のフィールドを追加する:
- {{例: performance_requirement — レスポンスタイム要件}}
- {{例: security_notes — セキュリティ考慮事項}}

### コンテキスト間インターフェース形式

```yaml
interface_format: "{{TypeScript type definitions / OpenAPI / Protocol Buffers / etc.}}"
```

### Git規約

```yaml
branch_naming: "{{cycle/C-{NNN}-{short-description}}}"
commit_prefix: "{{[C-{NNN}] / feat: / fix: / etc.}}"
```
