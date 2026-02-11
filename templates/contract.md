<!-- Contractテンプレート -->

---
contract_id: "project-contract"
version: 1
cycle_ref: "C-{NNN}"
status: "draft"
approved_at: null
decision_refs:
  - "{D-NNN}"
created_at: "YYYY-MM-DDTHH:MM:SSZ"
spec_refs:
  - "{SPEC_ID_1}"
  - "{SPEC_ID_2}"
---

## Architecture

### Tech Stack

| Component | Technology |
|-----------|-----------|
| Language | {言語} |
| Framework | {フレームワーク} |
| Database | {データベース} |
| Infrastructure | {インフラ} |

> 各技術選定の根拠は Decision Records を参照: {D-NNN}, {D-NNN}

### Directory Structure

```
src/
├── {ディレクトリ構成を記述}
└── ...
```

### Design Patterns

- **{パターン名}**: {適用箇所と理由}

## Interfaces

### {インターフェース名}

- **From**: {発信元コンテキスト} → **To**: {受信先コンテキスト}
- **Spec Ref**: {対応するSpec ID}

```typescript
{インターフェース定義（TypeScript型定義 / OpenAPI / etc.）}
```

## Implementation Tasks

### T-001: {タスクタイトル}

- **Context**: {コンテキスト名}
- **Spec Refs**: {SPEC_ID}
- **Parallelizable**: Yes/No

{タスクの詳細}

**Inputs**:
- {入力・依存するもの}

**Outputs**:
- {成果物}

**Completion Criteria**:
- {完了条件1}
- {完了条件2}

## Test Strategy

### AC Coverage

| Spec ID | AC ID | Test Type | Description |
|---------|-------|-----------|-------------|
| {SPEC_ID} | AC-001 | unit / integration / e2e | {テスト内容} |

### Unit Tests

**Scope**: {単体テストの範囲}

- {ガイドライン1}

### Integration Tests

**Scope**: {統合テストの範囲}

- {ガイドライン1}

### E2E Tests

**Scope**: {E2Eテストの範囲}

- {ガイドライン1}

## Parallel Execution

### Group G-001

**Tasks**: T-001, T-002
**Stub Strategy**: {スタブ/モック戦略}

### Integration Phase

**Trigger**: 全グループ完了後

- {結合検証項目1}
- {結合検証項目2}

## Deliverable Previews

| Preview | Path | Status |
|---------|------|--------|
| {プレビュー種別} | docs/apd/contract/previews/C-{NNN}/{filename} | generated |
