# APD Boilerplate — Autopilot Development テンプレート集

> **人間は意思決定だけ、AIが自律で完走する**

Autopilot Development（APD）は、AIエージェントが自律的にソフトウェアを開発し、人間はCheckpoint（確認ポイント）でのみ意思決定を注入する開発フレームワークです。

## ドキュメント

| ファイル | 役割 |
|---------|------|
| `QUICKREF.md` | **クイックリファレンス**。フェーズ早見表、Skills使用フロー、人間がやることの一覧、ファイル命名規則など、日常的に参照するチートシート |
| `APD-FRAMEWORK.md` | **フレームワークの原理原則**。APDの設計哲学、各フェーズの詳細な進め方、AI Checkpointのパターン、Decision Recordの形式などを網羅した理論書。フレームワークを深く理解したいときに参照する |

## 使い方

### 1. プロジェクト初期化

```bash
./scripts/init.sh /path/to/your-project
```

以下がプロジェクトにコピーされます:

- `.claude/rules/apd/` — フレームワーク方針（Claude Codeが自動ロード）
- `.claude/skills/` — スラッシュコマンド
- `.claude/agents/` — カスタムサブエージェント
- `docs/apd/` — ドキュメントツリー（design, specs, contract, decisions, cycles）

### 2. フェーズの進め方

Claude Codeでスラッシュコマンドを使って各フェーズを進めます:

```
/apd-cycle       → サイクル開始（トリガー判定）
/apd-design      → Phase 0: Design文書作成
/apd-spec        → Phase 1: Spec生成
/apd-contract    → Phase 2: Contract生成（AI自律）
/apd-execute     → Phase 3: 実装（AI自律）
/apd-status      → 進行状況の確認
```

詳細なフローは `QUICKREF.md` を参照してください。

## リポジトリ構成

| パス | 内容 |
|------|------|
| `scripts/init.sh` | プロジェクト初期化スクリプト |
| `.claude/rules/apd/` | フレームワーク方針（基本原則、フェーズ定義、サイクルフロー、ドキュメント管理、テスト方針） |
| `.claude/skills/` | スラッシュコマンド（`/apd-design`, `/apd-spec`, `/apd-contract`, `/apd-execute`, `/apd-cycle`, `/apd-status`） |
| `.claude/agents/` | サブエージェント（`apd-checkpoint`, `apd-peer-review`） |
| `examples/prompts/` | 各フェーズのプロンプト原文 |
| `examples/templates/` | YAML成果物のフォーマット定義 |
