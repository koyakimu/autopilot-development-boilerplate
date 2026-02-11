# APD成果物プレビュー

## 概要

実装前に「何ができるか」を可視化し、方向性のズレを早期に検出する。

- Phase 1（Spec）: テキストで完成像の方向性を合意する
- Phase 2（Contract）: 具体的な図・モック・ダイアグラムを生成し、Human Checkpoint 2でレビューする

**プレビュー生成は必須である。** 最低1つ（アーキテクチャ図）はどのプロジェクトでも生成する。
プレビューが存在しない場合、AI Checkpointで fail 判定となる。

## プレビュー対象（最低1つ必須、プロジェクトに応じて追加選択）

| 種別 | フォーマット | 例 |
|------|------------|-----|
| アーキテクチャ図 | Mermaid | システム構成、コンポーネント関係 |
| データモデル | Mermaid (ER図) | テーブル設計、リレーション |
| シーケンス図 | Mermaid | API呼び出しフロー、処理順序 |
| 画面遷移図 | Mermaid (stateDiagram) | ページ間のナビゲーション |
| UIモック | HTML | 静的HTML+CSSによる画面モック |
| API仕様 | Markdown | エンドポイント、リクエスト/レスポンス例 |

## 成果物の配置

```
docs/apd/contract/previews/C-{NNN}/
├── architecture.md          ← Mermaid図を含むMarkdown
├── data-model.md
├── sequence-{name}.md
├── screens/
│   ├── {screen-name}.html   ← HTMLモック
│   └── ...
└── api-spec.md
```

## Phase 1での方向性合意

Specの `ui_description` フィールド（テキスト記述）で完成像の方向性を記述する。
ここでは詳細な図は不要。「どんな画面があるか」「どんなAPIか」をテキストで合意する。

## Phase 2での具体的プレビュー生成

Contract生成時に、プレビューも同時に生成する。
- 生成するプレビューの種類はContractの中で宣言する
- プレビューファイルはContractと同じバージョン管理に従う（イミュータブル、修正はAmendment）

## Human Checkpoint 2でのレビュー

Human Checkpoint 2は以下を含む:
- 従来のAI Checkpointサマリー確認
- プレビューの目視レビュー（生成された場合）

チェック項目:
- [ ] アーキテクチャ図が期待するシステム構成と合致しているか
- [ ] データモデルが業務要件を正しく反映しているか
- [ ] UIモックがある場合、画面レイアウト・操作感が期待通りか
- [ ] API仕様がある場合、エンドポイント設計が妥当か
