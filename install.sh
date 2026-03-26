#!/bin/bash
# install.sh — claude-session-master installer
# https://github.com/JoeArmageddon/Claude-Master-Skill
#
# Usage:
#   bash install.sh                    Full install (global + current directory)
#   bash install.sh --global-only      Only install global skill
#   bash install.sh --project-only     Only install project template here
#   bash install.sh --dir /path/to/p   Install project template into a specific directory
#   bash install.sh --help

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_ONLY=false
PROJECT_ONLY=false
TARGET_DIR="$PWD"

for arg in "$@"; do
  case "$arg" in
    --global-only)   GLOBAL_ONLY=true ;;
    --project-only)  PROJECT_ONLY=true ;;
    --dir=*)         TARGET_DIR="${arg#*=}" ;;
    --help)
      grep '^#' "$0" | grep -v '#!/' | sed 's/^# //' | head -12
      exit 0 ;;
  esac
done

# ── Colours ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}↷${NC} $1"; }
err()  { echo -e "  ${RED}✗${NC} $1"; }

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  claude-session-master — installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── GLOBAL ────────────────────────────────────────────────────────────────────
if [ "$PROJECT_ONLY" = false ]; then
  echo "▶ Global install → ~/.claude/"
  echo ""

  # Skills
  for skill in master-session skill-authoring; do
    DEST=~/.claude/skills/$skill
    mkdir -p "$DEST"
    if cp "$REPO_DIR/global/skills/$skill/SKILL.md" "$DEST/SKILL.md" 2>/dev/null; then
      ok "skills/$skill/SKILL.md"
    else
      err "Could not install skills/$skill/SKILL.md"
    fi
  done

  # Global CLAUDE.md — don't overwrite existing
  if [ ! -f ~/.claude/CLAUDE.md ]; then
    cp "$REPO_DIR/global/CLAUDE.md" ~/.claude/CLAUDE.md
    ok "~/.claude/CLAUDE.md (global preferences)"
  else
    warn "~/.claude/CLAUDE.md already exists — not overwritten"
    warn "  Review $REPO_DIR/global/CLAUDE.md and merge manually if needed"
  fi

  echo ""
fi

# ── PROJECT ───────────────────────────────────────────────────────────────────
if [ "$GLOBAL_ONLY" = false ]; then
  TARGET="$(cd "$TARGET_DIR" && pwd)"
  echo "▶ Project install → $TARGET"
  echo ""

  [ -d "$TARGET" ] || { err "Directory does not exist: $TARGET"; exit 1; }

  # .claude/ directory
  mkdir -p "$TARGET/.claude/commands" "$TARGET/.claude/hooks"

  # Commands — skip existing
  for f in "$REPO_DIR/project-template/.claude/commands/"*.md; do
    fname=$(basename "$f")
    dest="$TARGET/.claude/commands/$fname"
    if [ ! -f "$dest" ]; then
      cp "$f" "$dest" && ok "commands/$fname"
    else
      warn "commands/$fname (exists — not overwritten)"
    fi
  done

  # Hooks — skip existing
  for f in "$REPO_DIR/project-template/.claude/hooks/"*; do
    fname=$(basename "$f")
    dest="$TARGET/.claude/hooks/$fname"
    if [ ! -f "$dest" ]; then
      cp "$f" "$dest" && ok "hooks/$fname"
    else
      warn "hooks/$fname (exists — not overwritten)"
    fi
  done

  # settings.json — skip if exists
  if [ ! -f "$TARGET/.claude/settings.json" ]; then
    cp "$REPO_DIR/project-template/.claude/settings.json" "$TARGET/.claude/settings.json"
    ok ".claude/settings.json"
  else
    warn ".claude/settings.json (exists — not overwritten)"
    warn "  Merge token budget and hook config manually if needed"
  fi

  # Memory files — skip if exist
  for f in PHASES.md SESSION_LOG.md MEMORY.md .claudeignore; do
    dest="$TARGET/$f"
    if [ ! -f "$dest" ]; then
      cp "$REPO_DIR/project-template/$f" "$dest" && ok "$f"
    else
      warn "$f (exists — not overwritten)"
    fi
  done

  # Make hooks executable
  chmod +x "$TARGET/.claude/hooks/"*.sh 2>/dev/null && ok "hooks made executable"

  # .gitignore — append compact-backups if git repo
  if [ -f "$TARGET/.gitignore" ] && ! grep -q "compact-backups" "$TARGET/.gitignore"; then
    printf '\n# claude-session-master\n.claude/compact-backups/\n' >> "$TARGET/.gitignore"
    ok ".gitignore updated (compact-backups excluded)"
  fi

  echo ""
fi

# ── VERIFY ────────────────────────────────────────────────────────────────────
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ERRORS=0
chk() { [ -e "$1" ] && ok "$1" || { err "MISSING: $1"; ERRORS=$((ERRORS+1)); }; }

if [ "$PROJECT_ONLY" = false ]; then
  chk ~/.claude/skills/master-session/SKILL.md
  chk ~/.claude/skills/skill-authoring/SKILL.md
  chk ~/.claude/CLAUDE.md
fi

if [ "$GLOBAL_ONLY" = false ]; then
  T="$(cd "$TARGET_DIR" && pwd)"
  for cmd in start-session end-phase checkpoint add-mcp remove-mcp research new-skill; do
    chk "$T/.claude/commands/$cmd.md"
  done
  for hook in session-start.sh pre-compact.sh context-monitor.mjs; do
    chk "$T/.claude/hooks/$hook"
  done
  chk "$T/.claude/settings.json"
  chk "$T/PHASES.md"
  chk "$T/SESSION_LOG.md"
  chk "$T/MEMORY.md"
  chk "$T/.claudeignore"
fi

echo ""

if [ "$ERRORS" -gt 0 ]; then
  echo -e "  ${RED}⚠ $ERRORS file(s) missing. Re-run the installer or copy manually.${NC}"
  exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  ${GREEN}Installation complete${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Next steps:"
echo ""
echo "  1.  Edit PHASES.md  — define your project phases"
echo "  2.  Edit MEMORY.md  — add hard architectural conventions"
echo "  3.  Open Claude Code: claude"
echo "  4.  Run: /start-session"
echo ""
echo "  Recommended MCPs:"
echo "    /add-mcp tavily      Web research"
echo "    /add-mcp context7    Framework docs"
echo "    /add-mcp github      PR + issue management"
echo ""
echo "  Add skills to your global library:"
echo "    Run /new-skill inside Claude Code"
echo "    Or: cp path/to/SKILL.md ~/.claude/skills/[name]/SKILL.md"
echo ""
