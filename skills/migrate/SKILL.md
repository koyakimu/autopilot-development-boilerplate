---
name: migrate
description: >
  Migrates an existing APD project from 0.x (subdirectory) layout
  to 1.x (flat) layout. Inspects existing files, plans moves and
  rewrites, asks for confirmation, then applies. Use when the user
  asks to migrate APD, upgrade APD, run /apd:migrate, or has just
  updated the APD plugin and needs to convert their `docs/apd/`.
disable-model-invocation: true
argument-hint: "[--dry-run]"
---

# APD Migrate — 0.x プロジェクトを 1.x flat 構造に移行

このスキルは **AI 判断ベースで** 既存 APD プロジェクトを新方針に移行する。ファイル移動だけでなく、frontmatter フィールド名・本文中のパス参照・CLAUDE.md の旧スキル言及も読み解いて更新する。

検証は別途 `scripts/verify-migration.sh` で行う (プラグインに同梱)。

## 責務

- 既存 `docs/apd/` を読んで現状を把握する
- 新 flat 構造への移行プランを立てる
- ユーザーに確認を取る
- バックアップを取った上で移行を実行する
- 機械的に変換できない箇所 (内容判断が必要なもの) は **手動レビュー項目として明示** する
- 完了後に `scripts/verify-migration.sh` を実行して結果を検証する

## 手順

### 1. 前提確認

- カレントは git working tree が clean (or 専用ブランチ) であること
- `docs/apd/` が存在すること
- 既に 1.x 構造 (`docs/apd/design.md` あり & `docs/apd/design/` なし) なら "already migrated" と返して終了

clean でない場合は移行を**実行しない**。ユーザーに stash か commit か別ブランチでの作業を促す。

### 2. 現状把握

`docs/apd/` 配下を Glob + Read で全把握する。最低限以下を識別する:

- 旧 `design/product-design.md` の有無
- 旧 `specs/{name}.v{N}.md` の context 名一覧と version
- 旧 `specs/{name}.v{N}.A-{NNN}.md` (Amendment) 一覧
- 旧 `specs/_cross-context-scenarios.md` の有無
- 旧 `decisions/D-{NNN}.md` 一覧
- 旧 `previews/C-{NNN}/` 一覧
- 旧 `cycles/` の中身 (単一ファイル or ディレクトリ形式)
- 命名規約に合わない files (`random.md` 等)
- `docs/apd/todo.md` の有無

### 3. 移行プランの提示と確認

以下のような形式でユーザーに移行プランを提示し、合意を得る:

````markdown
## 移行プラン

### 自動でやること
- `docs/apd/` を `docs/apd.backup-{timestamp}/` にバックアップ
- ファイル移動・リネーム:
  - `design/product-design.md` → `design.md`
  - `specs/order-management.v2.md` → `spec-order-management.md` (v1 は backup のみ)
  - `specs/order-management.v1.A-005.md` → `spec-order-management-patch-005.md`
  - `specs/_cross-context-scenarios.md` → `spec-cross-context.md`
  - `decisions/D-001.md` → `decision-001.md`
  - `previews/C-001/` → `preview-C-001/`
- frontmatter 更新:
  - 全 Spec で `cycle_ref` → `issue_ref` (値は判断: 該当 issue があれば番号、なければ null)
  - 全 Patch (旧 Amendment) で `amendment_id` → `patch_id` (値の A-NNN は P-NNN に変更)
- 本文中のパス参照を新 flat に置換 (確実に置換できるものに限る)
- `cycles/` ディレクトリは backup のみに保存 (新 APD は GH issue で代替)

### 手動レビューが必要なもの
- `specs/random.md` — 命名規約に合わない。用途を判断
- `decisions/notes.md` — 同上
- `CLAUDE.md` の `/apd:build` `/apd:cycle` 言及 — プロジェクト固有のため AI が機械的に書き換えるとリスク
- 古い version の Spec (`order-management.v1.md`) — backup には残るが、flat には持ち込まない

進めてよいですか? (yes / dry-run / abort)
````

`--dry-run` 引数があれば、確認なしで「上記プランを実行した場合に何が起こるか」だけ出力する (実 fs 操作なし)。

### 4. 実行

ユーザーの合意後、Bash で順番に実行する:

1. **バックアップ**: `cp -R docs/apd docs/apd.backup-{timestamp}` (絶対消さない)
2. **ファイル移動**: `git mv` を優先 (履歴保持)。git 外なら `mv`
3. **frontmatter 更新**: Edit ツールで各ファイルを書き換え
4. **本文参照更新**: Grep で旧パス参照を特定し、文脈を確認しながら Edit で置換
5. **cycles/ 削除**: `git rm -r docs/apd/cycles`

各ステップ後に **何をしたか** を会話に surface する (`/goal` の評価器原則と同じ理由)。

### 5. 検証

`scripts/verify-migration.sh` を実行して結果を出力する:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/verify-migration.sh"
```

verify は pass/fail と問題箇所を返す。fail があれば修正する。

### 6. レポート

完了したらレポートを出す:

````markdown
## 移行完了

### 移動・リネーム (N 件)
- ...

### frontmatter 更新 (N ファイル)
- ...

### 本文参照更新 (N 箇所)
- ...

### 手動レビュー必要 (N 件)
- `specs/random.md`: 用途不明、判断してください
- `CLAUDE.md`: `/apd:build` の言及あり、フレーズを置き換えるか確認してください

### バックアップ
- `docs/apd.backup-{timestamp}/`

### 次のステップ
1. /apd:init で `.claude/rules/apd/` を最新版に更新
2. 手動レビュー項目を対応
3. `git add -A && git commit -m "chore: migrate to APD 1.x"`
4. 動作確認後、別 PR で backup ディレクトリを削除
````

## 安全原則

- **バックアップを取らずに移動しない**。最初のステップで必ず backup を作る
- **判断に迷ったら手動レビュー項目に倒す**。AI 判断で書き換えるより、ユーザーに渡す方が安全
- **frontmatter の値変換は文脈次第**: `cycle_ref: "C-001"` を `issue_ref: null` にするか実 issue 番号にするかは、関連 issue があるかを `gh issue list` で確認した上で判断する
- **本文参照の置換は文脈確認後**: 例えば `docs/apd/specs/auth.v1.md` のような参照が本文に出てきたら、それが何の文脈で書かれているかを確認した上で `docs/apd/spec-auth.md` に置換する。リンク以外の文脈 (履歴的言及等) なら触らない
- **cycles の取り扱い**: 単純にディレクトリを削除する前に「重要な意思決定や history が cycle に書かれていないか」を Read して確認する。あれば backup から `docs/apd/decision-{NNN}.md` 形式に救出することも検討する

## このスキルが意図的にやらないこと

- `.claude/rules/apd/` の更新 — `/apd:init` の責務
- 旧スキル (`/apd:build` 等) の呼び出し削除 — そもそも削除済みのスキルは呼べないので不要
- プロジェクト固有の src/tests/ の path 更新 — APD の責務外。手動レビュー項目に倒す

## 失敗時のロールバック

ユーザーが「やっぱり戻したい」と言ったら:

```bash
rm -rf docs/apd
mv docs/apd.backup-{timestamp} docs/apd
git checkout -- .  # frontmatter 等の edit が staged されている場合
```

または `/plugin install apd@apd-marketplace --version 0.5.1` で旧プラグインに戻す。
