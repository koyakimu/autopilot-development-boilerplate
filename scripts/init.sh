#!/bin/bash
# APD Boilerplate — プロジェクト初期化スクリプト
# Usage: ./scripts/init.sh /path/to/project "プロジェクト名"

set -euo pipefail

PROJECT_DIR="${1:?Usage: $0 <project-dir> <project-name>}"
PROJECT_NAME="${2:?Usage: $0 <project-dir> <project-name>}"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "🚀 APD Boilerplate — プロジェクト初期化"
echo "   プロジェクト: ${PROJECT_NAME}"
echo "   ディレクトリ: ${PROJECT_DIR}"
echo ""

# ディレクトリ作成
mkdir -p "${PROJECT_DIR}"/{design,specs,contract,decisions,cycles,src,tests}

# CLAUDE.md コピー
if [ ! -f "${PROJECT_DIR}/CLAUDE.md" ]; then
  cp "${SCRIPT_DIR}/templates/CLAUDE.md" "${PROJECT_DIR}/CLAUDE.md"
  # プロジェクト名を置換
  sed -i "s/{{プロジェクト名}}/${PROJECT_NAME}/g" "${PROJECT_DIR}/CLAUDE.md"
  echo "✅ CLAUDE.md を作成しました"
else
  echo "⚠️  CLAUDE.md は既に存在します（スキップ）"
fi

# Skills をコピー（Claude Code スラッシュコマンド）
if [ -d "${SCRIPT_DIR}/.claude/skills" ]; then
  mkdir -p "${PROJECT_DIR}/.claude/skills"
  cp -r "${SCRIPT_DIR}/.claude/skills/"* "${PROJECT_DIR}/.claude/skills/"
  echo "✅ Skills を .claude/skills/ にコピーしました"
fi

# Agents をコピー（Claude Code カスタムサブエージェント）
if [ -d "${SCRIPT_DIR}/.claude/agents" ]; then
  mkdir -p "${PROJECT_DIR}/.claude/agents"
  cp -r "${SCRIPT_DIR}/.claude/agents/"* "${PROJECT_DIR}/.claude/agents/"
  echo "✅ Agents を .claude/agents/ にコピーしました"
fi

# .gitignore に追加
if [ ! -f "${PROJECT_DIR}/.gitignore" ]; then
  cat > "${PROJECT_DIR}/.gitignore" << 'EOF'
node_modules/
.env
.env.local
dist/
build/
*.log
EOF
  echo "✅ .gitignore を作成しました"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 初期化完了！"
echo ""
echo "次のステップ:"
echo "  1. CLAUDE.md のプロジェクトレベル設定を編集"
echo "  2. /apd-design でDesign文書を作成（または /apd-cycle で開始）"
echo "  3. git init && git add -A && git commit -m 'Initial APD setup'"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
