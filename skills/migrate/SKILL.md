---
name: migrate
description: >
  Migrates an existing APD project to the current living-document
  layout. Folds Patch files into their Spec, consolidates per-file
  Decision Records into a single decisions.md, flattens any old
  subdirectories, and updates frontmatter. Use when the user asks
  to migrate APD, upgrade APD, run /apd:migrate, or has just updated
  the APD plugin and needs to convert their `docs/apd/`.
disable-model-invocation: true
argument-hint: "[--dry-run]"
---

# APD Migrate — 既存プロジェクトを「生きたドキュメント」構造へ移行

このスキルは **AI 判断ベースで** 既存 APD プロジェクトを現行モデルに移行する。現行モデルの要点:

- ドキュメントは生きた 1 枚（差分を別ファイルで積まない、git が正史）
- 3 ファイル種別: `design.md` / `decisions.md` / `spec-{feature}.md`
- Patch ファイルは廃止 → 親 Spec に畳む
- Decision は per-file をやめて単一 `decisions.md` に集約
- Preview は任意
- 人間の確認面は GitHub（PR + issue）

検証は `scripts/verify-migration.sh` で行う（プラグイン同梱）。

## 移行元の 2 パターン

プロジェクトの現状を見て、どちらか（or 両方）を適用する:

- **0.x（サブディレクトリ構造）**: `docs/apd/{design,specs,decisions,cycles,previews}/` がある
- **1.0.x（フラット + Patch ファイル）**: `docs/apd/spec-*-patch-*.md` や `decision-*.md` が並んでいる

## 責務

- 既存 `docs/apd/` を読んで現状を把握する
- 現行モデルへの移行プランを立てる
- ユーザーに確認を取る
- バックアップを取った上で移行を実行する
- 機械的に変換できない箇所は **手動レビュー項目として明示** する
- 完了後に `scripts/verify-migration.sh` を実行して検証する

## 手順

### 1. 前提確認

- git working tree が clean（or 専用ブランチ）であること。clean でなければ実行せず、commit/stash/別ブランチを促す
- `docs/apd/` が存在すること
- 既に現行モデル（`design.md` あり、`spec-*-patch-*.md` と `decision-*.md` と旧サブディレクトリがいずれも無い）なら "already migrated" と返して終了

### 2. 現状把握

`docs/apd/` 配下を Glob + Read で全把握する:

- 旧サブディレクトリ（`design/`, `specs/`, `decisions/`, `cycles/`, `previews/`）の有無
- `spec-{x}-patch-{NNN}.md`（フラット Patch ファイル）一覧と、対応する親 `spec-{x}.md`
- `decision-{NNN}.md`（per-file Decision）一覧
- `preview-*/` 一覧
- 命名規約に合わないファイル

### 3. 移行プランの提示と確認

以下のような形式でプランを提示し、合意を得る:

````markdown
## 移行プラン

### バックアップ
- `docs/apd/` を `docs/apd.backup-{timestamp}/` に複製

### サブディレクトリの flat 化（0.x からの場合）
- `design/product-design.md` → `design.md`
- `specs/{name}.v{N}.md` → `spec-{name}.md`（最新 version）
- `decisions/D-{NNN}.md` → `decisions.md` に集約
- `previews/C-{NNN}/` → `preview-C-{NNN}/`
- `cycles/` → backup のみ

### Patch ファイルの畳み込み
- `spec-auth-patch-001.md` の内容を `spec-auth.md` に反映し version を上げる
- 反映後 patch ファイルを削除
- 反映内容の要約をコミットメッセージに残す

### Decision の集約
- `decision-001.md` … `decision-NNN.md` を `decisions.md` に 1 ファイルへ統合
- 各ファイルを decisions.md のセクションに変換（新しい番号を上に）
- 元の per-file は削除

### frontmatter 更新
- 全 Spec: `cycle_ref` → `issue_ref`（実 issue があれば番号、なければ null）
- Patch 由来: `amendment_id` / `patch_id` フィールドは畳み込みで消える

### 手動レビューが必要なもの
- {命名規約に合わないファイル}
- CLAUDE.md の旧スキル言及（`/apd:build` 等）

進めてよいですか? (yes / dry-run / abort)
````

`--dry-run` 引数があれば、プラン提示と「実行した場合に何が起こるか」だけ出力する（fs 操作なし）。

### 4. 実行

ユーザー合意後、Bash + Edit で順番に実行する。各ステップ後に**何をしたか**を会話に surface する:

1. **バックアップ**: `cp -R docs/apd docs/apd.backup-{timestamp}`（絶対消さない）
2. **サブディレクトリ flat 化**（0.x の場合）: `git mv` でファイル移動
3. **Patch 畳み込み**: 各 patch ファイルを Read → 親 Spec を Edit して内容反映 + `version` 加算 → patch ファイルを `git rm`
4. **Decision 集約**: 各 `decision-*.md` を Read → `decisions.md` に追記（番号降順）→ 元ファイルを `git rm`
5. **frontmatter 更新**: Edit で各 Spec の `cycle_ref` → `issue_ref` 等

**Patch 畳み込みの判断**: patch の内容が親 Spec のどの AC に対応するかを読み解いて、該当 AC を編集 or 新 AC として追加する。単純な追記では二重定義になるので、文脈を見て統合する。

### 5. 検証

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/verify-migration.sh"
```

FAIL があれば修正する。

### 6. レポート

完了したらレポートを出す:

````markdown
## 移行完了

### Patch 畳み込み (N 件)
- spec-auth-patch-001.md → spec-auth.md (version 1→2)

### Decision 集約 (N 件 → decisions.md)
- decision-001..003.md → decisions.md

### flat 化 (N 件) ※0.x からの場合
- ...

### frontmatter 更新 (N ファイル)
- ...

### 手動レビュー必要 (N 件)
- ...

### バックアップ
- docs/apd.backup-{timestamp}/

### 次のステップ
1. /apd:init で .claude/rules/apd/ を最新版に更新
2. 手動レビュー項目を対応
3. git add -A && git commit -m "chore: migrate to APD living-document model"
4. 動作確認後、別 PR で backup ディレクトリを削除
````

## 安全原則

- **バックアップを取らずに変更しない**
- **判断に迷ったら手動レビュー項目に倒す**
- **Patch 畳み込みは内容を読んでから**: patch を機械的に末尾追記せず、対応 AC に統合する
- **Decision 集約は順序を保つ**: 元の番号・日付を保持して decisions.md に積む
- **cycles の取り扱い**: backup のみに残す前に、重要な意思決定が書かれていないか Read で確認。あれば decisions.md に救出する

## このスキルが意図的にやらないこと

- `.claude/rules/apd/` の更新 — `/apd:init` の責務
- プロジェクト固有の src/tests/ の path 更新 — 手動レビュー項目に倒す

## ロールバック

```bash
rm -rf docs/apd
mv docs/apd.backup-{timestamp} docs/apd
git checkout -- .
```
