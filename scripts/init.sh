#!/bin/bash
# APD Boilerplate — プロジェクト初期化スクリプト
# Usage: ./scripts/init.sh /path/to/project

set -euo pipefail

PROJECT_DIR="${1:?Usage: $0 <project-dir>}"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "🚀 APD Boilerplate — プロジェクト初期化"
echo "   ディレクトリ: ${PROJECT_DIR}"
echo ""

# ディレクトリ作成
mkdir -p "${PROJECT_DIR}"/docs/apd/{design,specs,contract,decisions,cycles}
mkdir -p "${PROJECT_DIR}"/{src,tests}

# Rules をコピー（APDフレームワーク方針 — 自動ロードされる）
if [ -d "${SCRIPT_DIR}/.claude/rules" ]; then
  mkdir -p "${PROJECT_DIR}/.claude/rules"
  cp -r "${SCRIPT_DIR}/.claude/rules/"* "${PROJECT_DIR}/.claude/rules/"
  echo "✅ Rules を .claude/rules/ にコピーしました"
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
echo "コピーされたもの:"
echo "  - .claude/rules/apd/  — APDフレームワーク方針（自動ロード）"
echo "  - .claude/skills/     — APDスキル（スラッシュコマンド）"
echo "  - .claude/agents/     — APDサブエージェント"
echo ""
echo "次のステップ:"
echo "  /apd-design でDesign文書を作成（または /apd-cycle で開始）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
