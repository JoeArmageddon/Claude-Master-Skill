#!/bin/bash
# .claude/hooks/session-start.sh
# Runs before CLAUDE.md loads. Injects live project status as context.
# Keeps CLAUDE.md static; this hook provides dynamic runtime facts.
# Always exits 0 — never blocks a session.

set -euo pipefail
START_NS=$(date +%s%N 2>/dev/null || echo "0")

echo "── Project status ──────────────────────────────"

# Git
BRANCH=$(git branch --show-current 2>/dev/null || echo "no git")
LAST=$(git log -1 --format="%s" 2>/dev/null || echo "—")
DIRTY=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
echo "Branch : $BRANCH"
echo "Commit : $LAST"
[ "$DIRTY" -gt 0 ] && echo "Dirty  : $DIRTY uncommitted file(s)" || echo "Tree   : clean"

# Phase
if [ -f PHASES.md ]; then
  PHASE=$(grep -m1 "^## Phase\|^\*\*Status:\*\* Active" PHASES.md 2>/dev/null \
    | grep "^## Phase" | head -1 | sed 's/^## //' | xargs)
  [ -n "$PHASE" ] && echo "Phase  : $PHASE" || echo "Phase  : see PHASES.md"
else
  echo "Phase  : PHASES.md not found — run /start-session to create it"
fi

echo ""
echo "── Token budget ────────────────────────────────"
echo "• /context  shows breakdown by category"
echo "• At 70%  → suggest /compact with focus directive"
echo "• At 80%  → compact fires automatically"
echo "• Use Task tool for multi-file exploration"

# MCP count
if [ -f .mcp.json ]; then
  MCP_COUNT=$(python3 -c \
    "import json; d=json.load(open('.mcp.json')); print(len(d.get('mcpServers', {})))" \
    2>/dev/null || echo "?")
  echo ""
  echo "── MCPs ────────────────────────────────────────"
  echo "Active project MCPs: $MCP_COUNT"
  if [ "$MCP_COUNT" != "?" ] && [ "$MCP_COUNT" -gt 10 ] 2>/dev/null; then
    echo "WARNING: >10 MCPs — consider /remove-mcp for unused servers"
  fi
fi

# Hook timing
if [ "$START_NS" != "0" ]; then
  END_NS=$(date +%s%N 2>/dev/null || echo "$START_NS")
  MS=$(( (END_NS - START_NS) / 1000000 ))
  echo ""
  echo "── Hook ${MS}ms ──────────────────────────────────"
fi

exit 0
