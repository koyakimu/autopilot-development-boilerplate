<!-- サイクル定義テンプレート -->

---
cycle_id: "C-{NNN}"
trigger: "{new_product / feature_addition / bug_fix / tech_change}"
title: "{変更のタイトル}"
design_ref: "docs/apd/design/product-design.md"
started_at: "YYYY-MM-DDTHH:MM:SSZ"
completed_at: null
phases:
  design:
    status: "{skipped / completed}"
    checkpoint_at: null
  spec:
    status: "{skipped / completed}"
    checkpoint_at: null
  contract:
    status: "{skipped / completed}"
    checkpoint_at: null
  execute:
    status: "{pending / in_progress / completed}"
    checkpoint_at: null
---

## Spec Changes

### {new_spec / amendment}

- **ID**: {SPEC_ID}
- **Target**: {既存SPEC_ID} _(amendment の場合)_
- **Amendment ID**: A-{NNN} _(amendment の場合)_
- **Context**: {コンテキスト名}

## Contract Changes

### {new / amendment}

- **Amendment ID**: C-{NNN} _(amendment の場合)_
- **Change**: {変更概要}

## Decisions

| Decision ID | Summary |
|-------------|---------|
| D-{NNN} | {判断の要約} |
