# APDサイクル型統一フロー

## サイクル型統一フロー

すべての変更を「サイクル」として統一する。修正は新しいサイクルで行う（出戻りではなく前進）。

| トリガー | フロー |
|---------|--------|
| 新プロダクト / 大きな方向転換 | Design → Spec → Contract → Execute（フルサイクル）|
| 新機能追加 | Spec（既存Design参照）→ Contract差分 → Execute |
| バグ修正 / 小さな改善 | Spec Amendment → Execute（Contract変更なし）|
| 技術的変更（リファクタ等）| Contract Amendment → Execute（Spec変更なし）|

## バグのトリアージ

バグ報告・テスト失敗が来たとき、AIがまず原因を判定する:
- **Spec起因**（仕様漏れ・曖昧さ）→ 人間にエスカレーション → Spec Amendmentサイクルへ
- **Execute起因**（実装がSpecと合っていない）→ AI自律で修正 → 人間に上げない
