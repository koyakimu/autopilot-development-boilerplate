#!/usr/bin/env bash
# Verify that an APD project has been migrated from 0.x to 1.x layout.
#
# Usage:
#   cd /path/to/your/project
#   bash <path-to-apd-plugin>/scripts/verify-migration.sh
#
# Returns exit 0 if the project's docs/apd/ structure is in the expected
# 1.x flat layout. Returns exit 1 if any issues are detected, listing them.
#
# This is a CHECK ONLY script. It does not move or rewrite anything.
# The actual migration is done by the /apd:migrate skill (AI-driven).

set -uo pipefail

if [[ ! -d "docs/apd" ]]; then
  echo "Error: docs/apd/ not found. Run this from your project root."
  exit 1
fi

FAILED=0
PASSED=0
WARNINGS=()

pass() {
  PASSED=$((PASSED + 1))
  echo "  [PASS] $1"
}

fail() {
  FAILED=$((FAILED + 1))
  echo "  [FAIL] $1"
}

warn() {
  WARNINGS+=("$1")
}

echo "=== APD 1.x Migration Verification ==="
echo ""

# ----------------------------------------------------------------------
# Check 1: Old subdirectories should not exist
# ----------------------------------------------------------------------

echo "Check 1: Old subdirectories removed"
for sub in design specs decisions cycles previews; do
  if [[ -d "docs/apd/${sub}" ]]; then
    fail "docs/apd/${sub}/ still exists (should be flattened)"
  else
    pass "docs/apd/${sub}/ absent"
  fi
done
echo ""

# ----------------------------------------------------------------------
# Check 2: New flat files use expected naming
# ----------------------------------------------------------------------

echo "Check 2: New naming conventions"

if [[ -f "docs/apd/design.md" ]]; then
  pass "docs/apd/design.md exists"
else
  warn "docs/apd/design.md not found (OK if project never had a Design)"
fi

spec_count=$(find docs/apd -maxdepth 1 -name "spec-*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
if [[ "$spec_count" -gt 0 ]]; then
  pass "${spec_count} spec-*.md file(s) at docs/apd/ root"
else
  warn "No spec-*.md files found (OK if project has no Specs yet)"
fi

old_amend=$(find docs/apd -maxdepth 1 -name "*.A-*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
if [[ "$old_amend" -gt 0 ]]; then
  fail "Found ${old_amend} file(s) with old amendment naming (*.A-*.md)"
  find docs/apd -maxdepth 1 -name "*.A-*.md" -type f 2>/dev/null | sed 's/^/    /'
else
  pass "No old amendment-style filenames (*.A-*.md)"
fi

old_vers=$(find docs/apd -maxdepth 1 -name "*.v[0-9]*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
if [[ "$old_vers" -gt 0 ]]; then
  fail "Found ${old_vers} file(s) with old version-suffix naming (*.v{N}.md)"
  find docs/apd -maxdepth 1 -name "*.v[0-9]*.md" -type f 2>/dev/null | sed 's/^/    /'
else
  pass "No old version-suffix filenames (*.v{N}.md)"
fi

old_decision=$(find docs/apd -maxdepth 1 -name "D-*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
if [[ "$old_decision" -gt 0 ]]; then
  fail "Found ${old_decision} file(s) with old decision naming (D-*.md, should be decision-*.md)"
  find docs/apd -maxdepth 1 -name "D-*.md" -type f 2>/dev/null | sed 's/^/    /'
else
  pass "No old decision naming (D-*.md)"
fi

echo ""

# ----------------------------------------------------------------------
# Check 3: Frontmatter field updates
# ----------------------------------------------------------------------

echo "Check 3: Frontmatter fields"

amendment_id_files=$(grep -l "^amendment_id:" docs/apd/*.md 2>/dev/null | wc -l | tr -d ' ')
if [[ "$amendment_id_files" -gt 0 ]]; then
  fail "${amendment_id_files} file(s) still have 'amendment_id:' frontmatter (should be 'patch_id:')"
  grep -l "^amendment_id:" docs/apd/*.md 2>/dev/null | sed 's/^/    /'
else
  pass "No 'amendment_id:' frontmatter"
fi

cycle_ref_files=$(grep -l "^cycle_ref:" docs/apd/*.md 2>/dev/null | wc -l | tr -d ' ')
if [[ "$cycle_ref_files" -gt 0 ]]; then
  fail "${cycle_ref_files} file(s) still have 'cycle_ref:' frontmatter (should be 'issue_ref:')"
  grep -l "^cycle_ref:" docs/apd/*.md 2>/dev/null | sed 's/^/    /'
else
  pass "No 'cycle_ref:' frontmatter"
fi

echo ""

# ----------------------------------------------------------------------
# Check 4: Body references to old paths
# ----------------------------------------------------------------------

echo "Check 4: Body references to old paths"

old_path_refs=$(grep -rEl 'docs/apd/(design|specs|decisions|cycles|previews)/' docs/apd 2>/dev/null | wc -l | tr -d ' ')
if [[ "$old_path_refs" -gt 0 ]]; then
  fail "${old_path_refs} file(s) reference old subdirectory paths in their body"
  grep -rEl 'docs/apd/(design|specs|decisions|cycles|previews)/' docs/apd 2>/dev/null | sed 's/^/    /'
else
  pass "No body references to old subdirectory paths"
fi

if [[ -f "CLAUDE.md" ]]; then
  if grep -qE 'docs/apd/(design|specs|decisions|cycles|previews)/' CLAUDE.md 2>/dev/null; then
    warn "CLAUDE.md references old subdirectory paths"
  fi
  if grep -qE '/apd:(build|cycle|progress)' CLAUDE.md 2>/dev/null; then
    warn "CLAUDE.md references deprecated skills (/apd:build, /apd:cycle, /apd:progress)"
  fi
fi

echo ""

# ----------------------------------------------------------------------
# Check 5: Backup directory exists (recommended)
# ----------------------------------------------------------------------

echo "Check 5: Backup retention"
backup_count=$(find . -maxdepth 2 -type d -name "apd.backup-*" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$backup_count" -gt 0 ]]; then
  pass "Backup directory present (recommended to keep for several cycles)"
  find . -maxdepth 2 -type d -name "apd.backup-*" 2>/dev/null | sed 's/^/    /'
else
  warn "No backup directory found (expected docs/apd.backup-{timestamp}/). If you did the migration, consider keeping the backup for a few cycles."
fi

echo ""

# ----------------------------------------------------------------------
# Summary
# ----------------------------------------------------------------------

echo "==================================================="
echo "Summary: ${PASSED} passed, ${FAILED} failed, ${#WARNINGS[@]} warning(s)"
echo "==================================================="

if [[ ${#WARNINGS[@]} -gt 0 ]]; then
  echo ""
  echo "Warnings (not failures):"
  for w in "${WARNINGS[@]}"; do
    echo "  ! $w"
  done
fi

if [[ "$FAILED" -gt 0 ]]; then
  echo ""
  echo "Migration verification FAILED. Review the items marked [FAIL] above."
  echo "Run /apd:migrate to apply remaining migration steps, or fix manually."
  exit 1
fi

echo ""
echo "Migration verification passed."
exit 0
