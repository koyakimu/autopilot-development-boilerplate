# APD Plugin — Autopilot Development Framework

> **人間は意思決定だけ、AIが自律で完走する**

Autopilot Development（APD）は、AIエージェントが自律的にソフトウェアを開発し、人間はCheckpoint（確認ポイント）でのみ意思決定を注入する開発フレームワークです。

Claude Codeプラグインとして提供され、`claude plugin install` で簡単に導入できます。

## インストール

### 1. マーケットプレースを追加

```bash
/plugin marketplace add koyakimu/autopilot-development-boilerplate
```

### 2. プラグインをインストール

```bash
/plugin install apd@apd-marketplace
```

### ローカルで開発・テスト

```bash
claude --plugin-dir /path/to/autopilot-development-boilerplate
```

### プロジェクトへの初期化

インストール後、プロジェクトディレクトリで以下を実行:

```
/apd:init
```

これにより:
- `.claude/rules/apd/` にフレームワーク方針がコピーされる（Claude Codeが自動ロード）
- `docs/apd/` にドキュメントディレクトリツリーが作成される

## ドキュメント

| ファイル | 役割 |
|---------|------|
| `QUICKREF.md` | クイックリファレンス。フェーズ早見表、Skills使用フロー、チートシート |
| `APD-FRAMEWORK.md` | フレームワークの原理原則。設計哲学、各フェーズの詳細な進め方 |

## フェーズの進め方

Claude Codeでスラッシュコマンドを使って各フェーズを進めます:

```
/apd:cycle       → サイクル開始（トリガー判定）
/apd:design      → Phase 0: Design文書作成
/apd:spec        → Phase 1: Spec生成
/apd:contract    → Phase 2: Contract生成（AI自律）
/apd:execute     → Phase 3: 実装（AI自律）
/apd:status      → 進行状況の確認
```

詳細なフローは `QUICKREF.md` を参照してください。

## プラグイン構成

| パス | 内容 |
|------|------|
| `.claude-plugin/plugin.json` | プラグインマニフェスト |
| `skills/` | スラッシュコマンド（`/apd:init`, `/apd:design`, `/apd:spec`, `/apd:contract`, `/apd:execute`, `/apd:cycle`, `/apd:status`） |
| `agents/` | サブエージェント（`apd:checkpoint`, `apd:peer-review`） |
| `hooks/` | SessionStartフック（未初期化プロジェクトの検知） |
| `rules/apd/` | フレームワーク方針（`/apd:init` でプロジェクトにコピーされる） |
| `templates/` | ドキュメントテンプレート |

## 既存ボイラープレートからの移行

以前のボイラープレート版（`scripts/init.sh` で配布）から移行する場合:

1. プラグインをインストール
2. `/apd:init` を実行してルールファイルを最新版に更新
3. プロジェクトの `.claude/skills/apd-*` と `.claude/agents/apd-*` を削除（プラグインが代替）
4. `.claude/rules/apd/` はそのまま維持

## ライセンス

MIT
