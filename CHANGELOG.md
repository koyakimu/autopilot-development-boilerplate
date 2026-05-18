# Changelog

## [0.7.0] - 2026-05-18

### Changed
- **用語**: `Amendment` → `Spec Patch` に変更（差分ドキュメントの呼称）
- **ディレクトリ構造**: `docs/apd/` をフラット化。`design/` `specs/` `decisions/` `cycles/` `previews/` サブディレクトリを廃止し、prefix 命名で分類する方針へ（`design.md`, `spec-{slug}.md`, `decision-{NNN}.md`, `preview-{slug}/`）
- **rules/apd/*.md** を新方針に全面改訂:
  - `Human Checkpoint 2` → `Acceptance` に用語変更
  - `AI Checkpoint` 機構を廃止し、Build の収束判定を Claude Code の `/goal` 評価器に委譲
  - handoff document（コンテキストリセット引き継ぎ用ファイル）の規定を削除
  - 3 点突合（評価軸 × evidence × toolcall）の規定を削除
  - サイクル別ディレクトリ構造（`cycles/C-{NNN}/{handoffs,evidence}/`）を廃止
  - サイクル ID（C-{NNN}）採番規定を削除、issue 番号や slug を推奨
  - ブランチ命名規約を `apd/C-{NNN}/*` から Conventional Commits 系（`feat/{issue#}-{slug}` 等）へ
  - 並列実行は Claude Code の subagent / agent teams / `/batch` を使う旨を明記
- **Handoff の場所**: ファイル化せず PR 本文の「## 試し方」セクションに記載する方針に変更
- **skills/init**: フラット構造で `docs/apd/` のみ作成。`gh` 検出時は `todo.md` をスキップして GitHub issue を一次 backlog として案内
- **skills/design**: 出力先を `docs/apd/design/product-design.md` → `docs/apd/design.md` に変更、`Human Checkpoint 0` 用語を削除
- **skills/spec**: パスを新フラット構造に対応、`Amendment` → `Spec Patch` に変更、最終案内を `/apd:build` → `/apd:start` に変更、issue 番号からの Spec 生成サポート追加（`gh issue view`）

### Removed
- `templates/amendment.md` → `templates/spec-patch.md` にリネーム

### Notes
- 旧スキル `/apd:build` `/apd:cycle` `/apd:progress` および `apd:checkpoint` agent は本 PR では削除せず、PR-3 でまとめて整理する
- `README.md` `QUICKREF.md` `APD-FRAMEWORK.md` の改訂も PR-3 で実施（旧スキル削除と同時の方が記述に一貫性が出るため）

## [0.6.0] - 2026-05-18

### Added
- `skills/start/` — `/apd:start` スキルを追加。Spec の Acceptance Criteria から Claude Code の `/goal` コマンド向け condition を組み立て、自律 build ループを `/goal` に委譲する薄いラッパー。既存の `/apd:build` と並存させた状態で新方針 (`/goal` 中心化) の動作を実環境で検証するプロトタイプ

## [0.4.0] - 2026-03-14

### Changed
- **Contract廃止・Phase統合** — Phase 2 (Contract) と Phase 3 (Execute) を Phase 2 (Build) に統合。Contractドキュメントを廃止し、SpecにTest StrategyとDeliverable Previewsセクションを吸収
- **フェーズ構成を3フェーズに簡素化** — Design → Spec → Build（旧: Design → Spec → Contract → Execute）
- **成果物プレビューの配置を変更** — `docs/apd/contract/previews/` → `docs/apd/previews/`
- **tech_changeフローの簡素化** — Contract Amendment → Execute から Decision Record → Build に変更
- **Checkpointエージェントを簡素化** — Phase 2 (Contract) レビューチェックリストを廃止し、Build用の統合チェックリストに変更
- **Peer ReviewからContract/Interface Compliance観点を除去** — Spec Complianceに集約

### Removed
- `skills/contract/` — Contractスキルを廃止
- `skills/execute/` — Executeスキルを廃止（`skills/build/` に統合）
- `templates/contract.md` — Contractテンプレートを廃止
- `docs/apd/contract/` — Contractディレクトリをドキュメントツリーから廃止

### Added
- `skills/build/` — Build スキル（旧Contract + Execute の統合）
- Specテンプレートに `Test Strategy` セクション（AC Coverageテーブル）を追加
- Specテンプレートに `Deliverable Previews` セクションを追加

## [0.3.1] - 2026-03-08

### Removed
- **SessionStartフック (`check-init.sh`) を削除** — 未初期化プロジェクト検知フックを廃止し、`hooks/hooks.json` を空に変更

## [0.3.0] - 2026-03-08

### Changed
- **Human Checkpoint 2 (Contract) を廃止** — AI Checkpoint通過後に自動承認する方式に変更。エスカレーション項目がある場合のみ人間に確認
- **Human Checkpoint 3 を「完成品確認」に変更** — 動く成果物が意図通りか確認する。コードレビューはフレームワークとして求めない
- **Peer Reviewに対立的検証（Adversarial Testing）を追加** — 積極的に壊しにいく視点で障害ケースを探索する観点を追加
- **ExecuteスキルにBDDテスト自動生成の指示を追加** — SpecのGiven/When/Then ACから直接テストコードを生成

### Updated
- `rules/apd/01-phases.md` — フェーズ定義とCheckpoint原則を新方針に更新
- `agents/checkpoint.md` — サマリー出力形式を新方針に合わせて更新
- `agents/peer-review.md` — 対立的検証の観点を追加
- `APD-FRAMEWORK.md` — 全面改訂（Mermaid図追加、新方針反映）
- `QUICKREF.md` — 新フロー・ToDo管理を反映

## [0.2.0] - 2026-03-08

### Added
- **ToDo管理の仕組み** — `docs/apd/todo.md` でサイクル横断のバックログをappend-onlyで管理
- **スコーピング** — Spec (full mode) でDesignの全機能を今回のスコープ/スコープ外に分類し、スコープ外の機能はToDoに記録
- **ToDoテンプレート** — `templates/todo.md` を追加

### Changed
- Design/Executeスキルに対話・実装中のToDo記録指示を追加
- Cycleスキルにtodo.md参照を追加（未着手ToDoを提示して次の作業を提案）
- Initスキルにtodo.md初期化を追加

## [0.1.0] - 2026-03-08

### Added
- **バージョンバンプスクリプト** — `scripts/bump-version.sh` で `plugin.json` と `marketplace.json` を一括更新
- **CLAUDE.md** — バージョン管理ルールを記載

### Changed
- 初期バージョンを `0.1.0` に設定（`1.0.0` から変更）

### Fixed
- **Phase 0 Designスキルに技術選定の混入防止ガードレールを追加** — ユーザーから技術スタック情報が提供された場合にDesign文書に含めず、Phase 1に移管する仕組みを導入
