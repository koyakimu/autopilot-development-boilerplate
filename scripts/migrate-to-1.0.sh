#!/usr/bin/env bash
# Migrate an APD project from pre-1.0 directory layout to 1.x flat layout.
#
# Usage:
#   cd /path/to/your/project
#   bash <path-to-apd-plugin>/scripts/migrate-to-1.0.sh [--dry-run]
#
# What it does:
#   1. Backs up docs/apd/ to docs/apd.backup-{timestamp}/
#   2. Flattens directory structure (design/, specs/, decisions/, previews/ → flat)
#   3. Renames files to new convention (amendments → patches, D-NNN → decision-NNN)
#   4. Archives docs/apd/cycles/ (not brought forward; GH issues replace them)
#   5. Prints a report of what changed and what needs manual review
#
# What it does NOT do (manual review required, see MIGRATION.md):
#   - Update frontmatter field names (amendment_id → patch_id, etc.)
#   - Update inline path references inside document bodies
#   - Update CLAUDE.md if it references old APD paths
#   - Refresh .claude/rules/apd/ — run /apd:init from Claude Code after this script

set -euo pipefail

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
  echo "=== DRY RUN: no filesystem changes will be made ==="
  echo ""
fi

# ----------------------------------------------------------------------
# Preflight
# ----------------------------------------------------------------------

if [[ ! -d "docs/apd" ]]; then
  echo "Error: docs/apd/ not found in current directory."
  echo "Run this script from your project root."
  exit 1
fi

# Detect already-migrated state
if [[ -f "docs/apd/design.md" ]] && [[ ! -d "docs/apd/design" ]]; then
  echo "docs/apd/ appears to already be migrated (design.md exists, design/ subdir does not)."
  echo "Nothing to do."
  exit 0
fi

IN_GIT=0
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  IN_GIT=1
  if [[ -n "$(git status --porcelain docs/apd 2>/dev/null)" ]]; then
    echo "Warning: docs/apd/ has uncommitted changes."
    echo "Commit or stash them first, or run on a clean branch."
    read -r -p "Continue anyway? [y/N] " ans
    case "$ans" in
      [yY]*) ;;
      *) echo "Aborted."; exit 1 ;;
    esac
  fi
fi

# ----------------------------------------------------------------------
# Helpers
# ----------------------------------------------------------------------

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="docs/apd.backup-${TIMESTAMP}"
MOVED=()
SKIPPED=()
WARNINGS=()

run() {
  # Echo and execute, honoring DRY_RUN
  echo "  \$ $*"
  if [[ $DRY_RUN -eq 0 ]]; then
    eval "$@"
  fi
}

move() {
  # Move a file or directory, using git mv if in git
  local src="$1"
  local dst="$2"
  if [[ ! -e "$src" ]]; then
    return 0
  fi
  if [[ -e "$dst" ]]; then
    WARNINGS+=("destination already exists, skipping: $src → $dst")
    return 0
  fi
  mkdir -p "$(dirname "$dst")" 2>/dev/null || true
  if [[ $IN_GIT -eq 1 ]]; then
    run "git mv \"$src\" \"$dst\""
  else
    run "mv \"$src\" \"$dst\""
  fi
  MOVED+=("$src → $dst")
}

# ----------------------------------------------------------------------
# Step 1: Backup
# ----------------------------------------------------------------------

echo "Step 1: Backup docs/apd/ to ${BACKUP_DIR}/"
run "cp -R docs/apd \"${BACKUP_DIR}\""
echo ""

# ----------------------------------------------------------------------
# Step 2: design/
# ----------------------------------------------------------------------

echo "Step 2: design/"
if [[ -f "docs/apd/design/product-design.md" ]]; then
  move "docs/apd/design/product-design.md" "docs/apd/design.md"
fi
# Move any other files at the top of design/ (excluding the already-moved product-design.md)
if [[ -d "docs/apd/design" ]]; then
  while IFS= read -r -d '' f; do
    name="$(basename "$f")"
    if [[ "$name" == "product-design.md" ]]; then
      continue  # already handled above
    fi
    move "$f" "docs/apd/design-${name}"
  done < <(find "docs/apd/design" -maxdepth 1 -type f -print0 2>/dev/null)
  # Remove empty design/
  if [[ $DRY_RUN -eq 0 ]] && [[ -d "docs/apd/design" ]]; then
    rmdir "docs/apd/design" 2>/dev/null || WARNINGS+=("docs/apd/design/ not empty after migration, review manually")
  fi
fi
echo ""

# ----------------------------------------------------------------------
# Step 3: specs/
# ----------------------------------------------------------------------

echo "Step 3: specs/"
if [[ -d "docs/apd/specs" ]]; then
  # Cross-context scenarios
  if [[ -f "docs/apd/specs/_cross-context-scenarios.md" ]]; then
    move "docs/apd/specs/_cross-context-scenarios.md" "docs/apd/spec-cross-context.md"
  fi

  # Amendments: {name}.v{N}.A-{NNN}.md → spec-{name}-patch-{NNN}.md
  while IFS= read -r -d '' f; do
    name="$(basename "$f" .md)"
    # Match {name}.v{N}.A-{NNN}
    if [[ "$name" =~ ^([a-zA-Z0-9_-]+)\.v[0-9]+\.A-([0-9]+)$ ]]; then
      ctx="${BASH_REMATCH[1]}"
      num="${BASH_REMATCH[2]}"
      move "$f" "docs/apd/spec-${ctx}-patch-${num}.md"
    fi
  done < <(find "docs/apd/specs" -maxdepth 1 -name "*.A-*.md" -type f -print0 2>/dev/null)

  # Specs: {name}.v{N}.md → spec-{name}.md (keep only highest version, archive others)
  # Build a map: ctx → highest version
  declare -A HIGHEST_VERSION
  while IFS= read -r -d '' f; do
    name="$(basename "$f" .md)"
    if [[ "$name" =~ ^([a-zA-Z0-9_-]+)\.v([0-9]+)$ ]]; then
      ctx="${BASH_REMATCH[1]}"
      ver="${BASH_REMATCH[2]}"
      cur="${HIGHEST_VERSION[$ctx]:-0}"
      if [[ "$ver" -gt "$cur" ]]; then
        HIGHEST_VERSION[$ctx]="$ver"
      fi
    fi
  done < <(find "docs/apd/specs" -maxdepth 1 -name "*.v*.md" ! -name "*.A-*.md" -type f -print0 2>/dev/null)

  while IFS= read -r -d '' f; do
    name="$(basename "$f" .md)"
    if [[ "$name" =~ ^([a-zA-Z0-9_-]+)\.v([0-9]+)$ ]]; then
      ctx="${BASH_REMATCH[1]}"
      ver="${BASH_REMATCH[2]}"
      if [[ "$ver" == "${HIGHEST_VERSION[$ctx]}" ]]; then
        move "$f" "docs/apd/spec-${ctx}.md"
      else
        WARNINGS+=("older version archived in backup only: $f (kept v${HIGHEST_VERSION[$ctx]} as spec-${ctx}.md)")
        SKIPPED+=("$f (older version)")
      fi
    fi
  done < <(find "docs/apd/specs" -maxdepth 1 -name "*.v*.md" ! -name "*.A-*.md" -type f -print0 2>/dev/null)

  # Anything else in specs/?
  while IFS= read -r -d '' f; do
    name="$(basename "$f")"
    if [[ "$name" != "_cross-context-scenarios.md" ]] && [[ ! "$name" =~ \.v[0-9]+\.A-[0-9]+\.md$ ]] && [[ ! "$name" =~ \.v[0-9]+\.md$ ]]; then
      WARNINGS+=("unrecognized file in specs/: $f — review and move manually")
      SKIPPED+=("$f (unrecognized)")
    fi
  done < <(find "docs/apd/specs" -maxdepth 1 -type f -print0 2>/dev/null)

  # Remove empty specs/
  if [[ $DRY_RUN -eq 0 ]] && [[ -d "docs/apd/specs" ]]; then
    rmdir "docs/apd/specs" 2>/dev/null || WARNINGS+=("docs/apd/specs/ not empty after migration, review manually")
  fi
fi
echo ""

# ----------------------------------------------------------------------
# Step 4: decisions/
# ----------------------------------------------------------------------

echo "Step 4: decisions/"
if [[ -d "docs/apd/decisions" ]]; then
  while IFS= read -r -d '' f; do
    name="$(basename "$f" .md)"
    # D-NNN → decision-NNN
    if [[ "$name" =~ ^D-([0-9]+)$ ]]; then
      num="${BASH_REMATCH[1]}"
      move "$f" "docs/apd/decision-${num}.md"
    else
      WARNINGS+=("unrecognized file in decisions/: $f — review and move manually")
      SKIPPED+=("$f (unrecognized)")
    fi
  done < <(find "docs/apd/decisions" -maxdepth 1 -type f -print0 2>/dev/null)

  if [[ $DRY_RUN -eq 0 ]] && [[ -d "docs/apd/decisions" ]]; then
    rmdir "docs/apd/decisions" 2>/dev/null || WARNINGS+=("docs/apd/decisions/ not empty, review manually")
  fi
fi
echo ""

# ----------------------------------------------------------------------
# Step 5: previews/
# ----------------------------------------------------------------------

echo "Step 5: previews/"
if [[ -d "docs/apd/previews" ]]; then
  while IFS= read -r -d '' d; do
    name="$(basename "$d")"
    move "$d" "docs/apd/preview-${name}"
  done < <(find "docs/apd/previews" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null)

  # Loose files at the top of previews/
  while IFS= read -r -d '' f; do
    name="$(basename "$f")"
    move "$f" "docs/apd/preview-${name}"
  done < <(find "docs/apd/previews" -maxdepth 1 -type f -print0 2>/dev/null)

  if [[ $DRY_RUN -eq 0 ]] && [[ -d "docs/apd/previews" ]]; then
    rmdir "docs/apd/previews" 2>/dev/null || WARNINGS+=("docs/apd/previews/ not empty, review manually")
  fi
fi
echo ""

# ----------------------------------------------------------------------
# Step 6: cycles/ (archive only)
# ----------------------------------------------------------------------

echo "Step 6: cycles/ (archive, not brought forward)"
if [[ -d "docs/apd/cycles" ]]; then
  # Don't move into flat structure. The backup already has it.
  # Remove from active docs/apd/ to avoid confusion.
  if [[ $DRY_RUN -eq 0 ]]; then
    if [[ $IN_GIT -eq 1 ]]; then
      run "git rm -r docs/apd/cycles"
    else
      run "rm -rf docs/apd/cycles"
    fi
  else
    echo "  (would remove docs/apd/cycles/ from active tree; preserved in backup)"
  fi
  SKIPPED+=("docs/apd/cycles/ (archived in backup only; new APD uses GH issues for cycles)")
fi
echo ""

# ----------------------------------------------------------------------
# Report
# ----------------------------------------------------------------------

echo "==================================================="
echo "Migration Report"
echo "==================================================="
echo ""
echo "Backup: ${BACKUP_DIR}/"
echo ""

echo "Moved (${#MOVED[@]} entries):"
if [[ ${#MOVED[@]} -gt 0 ]]; then
  for m in "${MOVED[@]}"; do
    echo "  - $m"
  done
else
  echo "  (none)"
fi
echo ""

echo "Skipped / archived (${#SKIPPED[@]} entries):"
if [[ ${#SKIPPED[@]} -gt 0 ]]; then
  for s in "${SKIPPED[@]}"; do
    echo "  - $s"
  done
else
  echo "  (none)"
fi
echo ""

echo "Warnings (${#WARNINGS[@]}):"
if [[ ${#WARNINGS[@]} -gt 0 ]]; then
  for w in "${WARNINGS[@]}"; do
    echo "  ! $w"
  done
else
  echo "  (none)"
fi
echo ""

echo "Next steps (manual):"
echo "  1. Open Claude Code in this project and run /apd:init to refresh .claude/rules/apd/"
echo "  2. Update frontmatter fields in moved files:"
echo "     - amendment_id: \"A-NNN\"  →  patch_id: \"P-NNN\""
echo "     - cycle_ref: \"C-NNN\"     →  issue_ref: <github issue number>  (if applicable)"
echo "  3. Search the project for old path references and update:"
echo "     - grep -r 'docs/apd/specs/' .   →  docs/apd/spec-*.md"
echo "     - grep -r 'docs/apd/decisions/' .  →  docs/apd/decision-*.md"
echo "     - grep -r 'docs/apd/cycles/' .  →  remove or replace with GH issue links"
echo "  4. Review CLAUDE.md for old APD path references"
echo "  5. Commit the migration: git add -A && git commit -m 'chore: migrate to APD 1.x'"
echo ""

if [[ $DRY_RUN -eq 1 ]]; then
  echo "(DRY RUN — re-run without --dry-run to apply)"
fi
