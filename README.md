# APD Boilerplate — Autopilot Development テンプレート集

> **人間は意思決定だけ、AIが自律で完走する**

## 使い方

### 1. プロジェクト初期化

```bash
# 新規プロジェクトにボイラープレートをコピー
./scripts/init.sh /path/to/your-project "プロジェクト名"
```

### 2. フェーズ別プロンプトの使い方

各フェーズのプロンプトは `prompts/` ディレクトリにあります。  
Claude Code やチャットインターフェースにコピー&ペーストし、`{{placeholder}}` を実際の値に置き換えて使用します。

| ファイル | フェーズ | 用途 |
|---------|---------|------|
| `prompts/phase-0-design.md` | Phase 0: Design | 人間 + AI対話でDesign文書を作成 |
| `prompts/phase-1-spec.md` | Phase 1: Spec | AIがSpecドラフトを生成 |
| `prompts/phase-2-contract.md` | Phase 2: Contract | AIが自律でContract生成 |
| `prompts/phase-3-execute.md` | Phase 3: Execute | AIが自律で実装・テスト |
| `prompts/cycle-trigger.md` | サイクル開始 | トリガー種別に応じたサイクル定義 |
| `prompts/ai-checkpoint.md` | AI Checkpoint | エージェント間レビュー |

### 3. ドキュメントテンプレート

`templates/` ディレクトリに YAML テンプレートがあります。

| ファイル | 用途 |
|---------|------|
| `templates/design.yaml` | Design文書テンプレート |
| `templates/spec.yaml` | Specテンプレート |
| `templates/contract.yaml` | Contractテンプレート |
| `templates/cycle.yaml` | サイクル定義テンプレート |
| `templates/decision.yaml` | Decision Recordテンプレート |
| `templates/amendment.yaml` | Amendment（差分）テンプレート |

### 4. プロジェクト構成

初期化後のディレクトリ構成:

```
your-project/
├── CLAUDE.md                    ← フレームワーク + プロジェクト設定
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
