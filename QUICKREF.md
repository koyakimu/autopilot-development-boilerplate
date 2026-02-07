# APD クイックリファレンス

## フェーズ早見表

| Phase | 誰の時間 | やること | 成果物 | Checkpoint |
|-------|---------|---------|--------|------------|
| **0: Design** | 人間+AI | 対話でDesign文書作成 | `design/product-design.yaml` | Human CP 0 |
| **1: Spec** | 人間+AI | AIドラフト→人間FB | `specs/*.yaml` + `decisions/*.yaml` | Human CP 1 |
| **2: Contract** | AI自律 | 技術仕様を自動生成 | `contract/*.yaml` | AI CP → Human CP 2（軽量）|
| **3: Execute** | AI自律 | 実装+テスト | `src/` + `tests/` | AI CP → Human CP 3（軽量）|

## プロンプト使用フロー

```
① 変更が発生
   └→ prompts/cycle-trigger.md でサイクル定義を作成

② Phase 0（new_product のみ）
   └→ prompts/phase-0-design.md で Design 文書を対話的に作成

③ Phase 1
   └→ prompts/phase-1-spec.md で Spec ドラフトを生成
   └→ 確認依頼リストだけレビュー → フィードバック → 承認

④ Phase 2
   └→ prompts/phase-2-contract.md を AI に渡して自律実行
   └→ AI Checkpoint 結果のサマリーだけ確認 → 承認

⑤ Phase 3
   └→ prompts/phase-3-execute.md を AI に渡して自律実行
   └→ AI Checkpoint 結果のサマリーだけ確認 → 承認
```

## 人間がやること（だけ）

### Phase 0-1: しっかり関与
- Design文書の対話的作成
- Specドラフトの確認依頼箇所をレビュー
- Decision Record の判断を記入

### Phase 2-3: 軽量レビュー
- AI Checkpoint サマリーを読む（2-5分）
- escalation_items があれば判断を記入
- 問題なければ承認

## 判断フロー

```
CLAUDE.md に書いてある？
  ├─ Yes → それに従う
  └─ No → リーダーエージェントが判断できる？
              ├─ Yes → リーダーが判断
              └─ No → Human Checkpoint にエスカレーション
```

## ファイル命名規則

| 種類 | パターン | 例 |
|------|---------|-----|
| Design | `design/product-design.yaml` | — |
| Spec | `specs/{context}.v{N}.yaml` | `specs/order-management.v1.yaml` |
| Amendment | `specs/{context}.v{N}.A-{NNN}.yaml` | `specs/order-management.v1.A-005.yaml` |
| Contract | `contract/project-contract.v{N}.yaml` | `contract/project-contract.v1.yaml` |
| Decision | `decisions/D-{NNN}.yaml` | `decisions/D-001.yaml` |
| Cycle | `cycles/C-{NNN}.yaml` | `cycles/C-001.yaml` |
