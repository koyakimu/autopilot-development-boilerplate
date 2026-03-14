# Changelog

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
- **MVPスコーピング** — Spec (full mode) でDesignの全機能をMVP/Futureに分類し、Future機能はToDoに記録
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
