# APD Boilerplate — Autopilot Development テンプレート集

> **人間は意思決定だけ、AIが自律で完走する**

Autopilot Development（APD）は、AIエージェントが自律的にソフトウェアを開発し、人間はCheckpoint（確認ポイント）でのみ意思決定を注入する開発フレームワークです。

## リポジトリ構成

### ドキュメント

| ファイル | 役割 |
|---------|------|
| `APD-FRAMEWORK.md` | **フレームワークの原理原則**。APDの設計哲学、各フェーズの詳細な進め方、AI Checkpointのパターン、Decision Recordの形式などを網羅した理論書。フレームワークを深く理解したいときに参照する |
| `QUICKREF.md` | **クイックリファレンス**。フェーズ早見表、プロンプト使用フロー、人間がやることの一覧、ファイル命名規則など、日常的に参照するチートシート |

> **ドキュメント間の関係**: `APD-FRAMEWORK.md` が「なぜそうするのか」の理論書、`templates/CLAUDE.md` が「何をするか」のルールブック、`QUICKREF.md` が「今すぐ何をするか」の実行ガイドです。基本ルール（フェーズ定義、エスカレーションポリシー等）は意図的に複数ファイルで重複しており、それぞれの文脈で参照できるようにしています。

### プロンプト (`prompts/`)

各フェーズで使用するプロンプトテンプレートです。Claude Code やチャットインターフェースにコピー&ペーストし、`{{placeholder}}` を実際の値に置き換えて使用します。

| ファイル | フェーズ | 用途 |
|---------|---------|------|
| `prompts/phase-0-design.md` | Phase 0: Design | 人間 + AI対話でDesign文書を作成 |
| `prompts/phase-1-spec.md` | Phase 1: Spec | AIがSpecドラフトを生成 |
| `prompts/phase-2-contract.md` | Phase 2: Contract | AIが自律でContract生成 |
| `prompts/phase-3-execute.md` | Phase 3: Execute | AIが自律で実装・テスト |
| `prompts/cycle-trigger.md` | サイクル開始 | トリガー種別に応じたサイクル定義 |
| `prompts/ai-checkpoint.md` | AI Checkpoint | エージェント間レビュー |

### テンプレート (`templates/`)

プロジェクトで使用するテンプレートです。

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

### スクリプト (`scripts/`)

| ファイル | 用途 |
|---------|------|
| `scripts/init.sh` | プロジェクト初期化スクリプト。新規プロジェクトに必要なディレクトリ構成と `CLAUDE.md`、テンプレート、プロンプトをコピーする |

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

### 3. フェーズ別プロンプトの使い方

`prompts/` のプロンプトを順にAIに渡して各フェーズを進めます。詳細なフローは `QUICKREF.md` を参照してください。

### 4. 初期化後のプロジェクト構成

```
your-project/
├── CLAUDE.md                    ← フレームワーク + プロジェクト設定
├── .apd-templates/              ← YAMLテンプレート（参照用）
├── .apd-prompts/                ← プロンプト（参照用）
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
