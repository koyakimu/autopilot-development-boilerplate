# APD Plugin — Autopilot Development Framework

> **人間は意思決定だけ、AI が自律で完走する**

Autopilot Development（APD）は、AI エージェントが自律的にソフトウェアを開発し、人間は Acceptance（実機で動かして受け入れる場）でのみ判断を下す開発フレームワークです。Claude Code プラグインとして提供されます。

## フェーズ

```
Intent     ← 人間+AI（意図を固める）
   ↓
Spec       ← AI ドラフト + 人間が読む
   ↓
Build      ← AI 自律（/goal に委譲）
   ↓
Acceptance ← 人間が実機で触って受け入れ
```

人間は **意図を決める**（Intent / Spec）と **動く成果物を受け入れる**（Acceptance）の2点のみ担当する。Build 中の進行管理・並列化・タスク追跡・品質ゲートは Claude Code 本体の機能（`/goal`、subagent、agent teams、hooks）に委譲する。APD は薄い規約レイヤに留まる。

## インストール

```bash
# マーケットプレース追加
/plugin marketplace add koyakimu/autopilot-development-boilerplate

# プラグインインストール
/plugin install apd@apd-marketplace
```

## プロジェクトへの初期化

プロジェクトディレクトリで:

```
/apd:init
```

これにより:

- `.claude/rules/apd/` にフレームワーク方針がコピーされる（Claude Code が自動ロード）
- `docs/apd/` ディレクトリが作成される（フラット構造）
- `gh` が使える環境では GitHub issue を一次 backlog として案内、使えない環境では `docs/apd/todo.md` をフォールバックとして作成

## スキル

| コマンド | 役割 |
|---------|------|
| `/apd:init`   | プロジェクト初期化 |
| `/apd:design` | Design 文書（北極星）の対話的作成 |
| `/apd:spec`   | Spec ドラフト生成（full / add / bugfix モード） |
| `/apd:start`  | Build 開始（Spec の AC から `/goal` condition を組み立てて自律ループに委譲） |

詳細は `QUICKREF.md`、設計原理は `APD-FRAMEWORK.md` を参照。

## プラグイン構成

| パス | 内容 |
|------|------|
| `.claude-plugin/plugin.json` | プラグインマニフェスト |
| `skills/` | スラッシュコマンド（`init`, `design`, `spec`, `start`） |
| `agents/` | サブエージェント（`apd:peer-review`） |
| `rules/apd/` | フレームワーク方針（`/apd:init` でプロジェクトにコピー） |
| `templates/` | ドキュメントテンプレート |

## ライセンス

MIT
