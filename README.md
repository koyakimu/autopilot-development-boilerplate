# APD Boilerplate — Autopilot Development テンプレート集

> **人間は意思決定だけ、AIが自律で完走する**

Autopilot Development（APD）は、AIエージェントが自律的にソフトウェアを開発し、人間はCheckpoint（確認ポイント）でのみ意思決定を注入する開発フレームワークです。

## リポジトリ構成

### ドキュメント

| ファイル | 役割 |
|---------|------|
| `APD-FRAMEWORK.md` | **フレームワークの原理原則**。APDの設計哲学、各フェーズの詳細な進め方、AI Checkpointのパターン、Decision Recordの形式などを網羅した理論書。フレームワークを深く理解したいときに参照する |
| `QUICKREF.md` | **クイックリファレンス**。フェーズ早見表、Skills使用フロー、人間がやることの一覧、ファイル命名規則など、日常的に参照するチートシート |

> **ドキュメント間の関係**: `APD-FRAMEWORK.md` が「なぜそうするのか」の理論書、`templates/CLAUDE.md` が「何をするか」のルールブック、`QUICKREF.md` が「今すぐ何をするか」の実行ガイドです。基本ルール（フェーズ定義、エスカレーションポリシー等）は意図的に複数ファイルで重複しており、それぞれの文脈で参照できるようにしています。

### プロンプト (`prompts/`)

各フェーズのプロンプト原文です。Skills（`.claude/skills/`）として組み込み済みのため、通常は直接使用する必要はありません。フレームワークの設計意図を理解したいときに参照してください。

| ファイル | フェーズ | 用途 |
|---------|---------|------|
| `prompts/phase-0-design.md` | Phase 0: Design | 人間 + AI対話でDesign文書を作成 |
| `prompts/phase-1-spec.md` | Phase 1: Spec | AIがSpecドラフトを生成 |
| `prompts/phase-2-contract.md` | Phase 2: Contract | AIが自律でContract生成 |
| `prompts/phase-3-execute.md` | Phase 3: Execute | AIが自律で実装・テスト |
| `prompts/cycle-trigger.md` | サイクル開始 | トリガー種別に応じたサイクル定義 |
| `prompts/ai-checkpoint.md` | AI Checkpoint | エージェント間レビュー |

### テンプレート (`templates/`)

YAML成果物のフォーマット定義と、プロジェクトにコピーされる `CLAUDE.md` のボイラープレートです。

| ファイル | 用途 |
|---------|------|
| `templates/CLAUDE.md` | **AIエージェント向け設定ファイル（ボイラープレート）**。フレームワークの実行ルール + プロジェクト固有設定のテンプレート。`init.sh` でプロジェクトにコピーされ、プロジェクトレベル設定をカスタマイズして使う |
| `templates/design.yaml` | Design文書テンプレート |
| `templates/spec.yaml` | Specテンプレート |
| `templates/contract.yaml` | Contractテンプレート |
| `templates/cycle.yaml` | サイクル定義テンプレート |
| `templates/decision.yaml` | Decision Recordテンプレート |
| `templates/amendment.yaml` | Amendment（差分）テンプレート |
| `templates/cross-context-scenarios.yaml` | コンテキスト間シナリオテンプレート |

### Claude Code Skills (`.claude/skills/`)

Claude Codeのスラッシュコマンドとして各フェーズを直接実行できます。`init.sh` で新規プロジェクトに自動コピーされます。

| スキル | 用途 |
|--------|------|
| `/apd-status` | プロジェクトの進行状況を表示し、次のアクションを提案 |
| `/apd-cycle` | 新しいサイクルを開始。トリガー種別を判定しサイクル定義を生成 |
| `/apd-design` | Phase 0: Design文書を対話的に作成 |
| `/apd-spec` | Phase 1: Specを生成（full/add/bugfix の3モード） |
| `/apd-contract` | Phase 2: Contractを自律生成 + AIチェックポイント自動実行 |
| `/apd-execute` | Phase 3: 実装を自律実行 + ピアレビュー + AIチェックポイント |

### Claude Code Agents (`.claude/agents/`)

Skills から自動的に委譲されるカスタムサブエージェントです。

| エージェント | 用途 |
|------------|------|
| `apd-checkpoint` | Phase 2/3のAIチェックポイント専任レビュアー |
| `apd-peer-review` | Phase 3のクロスコンテキストピアレビュー |

### スクリプト (`scripts/`)

| ファイル | 用途 |
|---------|------|
| `scripts/init.sh` | プロジェクト初期化スクリプト。新規プロジェクトに必要なディレクトリ構成と `CLAUDE.md`、Skills、Agentsをコピーする |

### その他

| ファイル | 用途 |
|---------|------|
| `LICENSE` | MITライセンス |

## 使い方

### 1. プロジェクト初期化

```bash
# 新規プロジェクトにボイラープレートをコピー
./scripts/init.sh /path/to/your-project "プロジェクト名"
```

### 2. プロジェクト設定のカスタマイズ

コピーされた `CLAUDE.md` の「プロジェクトレベル設定」セクションを編集します:

- プロジェクト概要
- 技術スタック
- コーディング規約
- テスト戦略
- エスカレーションポリシーの追加
- Git規約

### 3. フェーズの進め方

Claude Codeでスラッシュコマンドを使って各フェーズを進めます:

```
/apd-cycle       → サイクル開始（トリガー判定）
/apd-design      → Phase 0: Design文書作成
/apd-spec        → Phase 1: Spec生成
/apd-contract    → Phase 2: Contract生成（AI自律）
/apd-execute     → Phase 3: 実装（AI自律）
/apd-status      → 進行状況の確認
```

詳細なフローは `QUICKREF.md` を参照してください。プロンプト（`prompts/`）やYAMLテンプレート（`templates/`）はボイラープレートリポジトリ上で参照できます。

### 4. 初期化後のプロジェクト構成

```
your-project/
├── CLAUDE.md                    ← フレームワーク + プロジェクト設定
├── .claude/
│   ├── skills/                  ← APDスラッシュコマンド
│   └── agents/                  ← APDカスタムサブエージェント
├── design/
│   └── (Design文書を配置)
├── specs/
│   └── (Spec文書を配置)
├── contract/
│   └── (Contract文書を配置)
├── decisions/
│   └── (Decision Recordを配置)
├── cycles/
│   └── (サイクル定義を配置)
├── src/
└── tests/
```
