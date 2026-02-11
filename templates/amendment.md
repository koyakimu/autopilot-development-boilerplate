<!-- Amendment（差分ドキュメント）テンプレート -->
<!-- 既存ドキュメントを上書きせず、差分として発行する -->

---
amendment_id: "A-{NNN}"
target_document: "{修正対象のドキュメントパス}"
cycle_ref: "C-{NNN}"
created_at: "YYYY-MM-DDTHH:MM:SSZ"
decision_ref: "D-{NNN}"
reason: "{修正理由の概要}"
---

## Changes

### Section: {変更対象のセクション}

**Type**: {add / modify / remove}

**Before**:

```
{変更前の内容（modify / remove の場合）}
```

**After**:

```
{変更後の内容（add / modify の場合）}
```

## Impact

### Affected Specs
- {OM-001}

### Affected Contracts
- {project-contract.v1}

### Affected Tests
- {tests/unit/order-management.test.ts}

### Cascade Amendment Required

{true / false — true の場合、他ドキュメントのAmendmentも必要}
