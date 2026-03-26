#!/bin/bash
# .claude/hooks/pre-compact.sh
# Runs before Claude Code auto-compacts the context window.
# Backs up memory files so they survive lossy summarisation.
# Always exits 0 — never blocks compaction.

set -euo pipefail

BACKUP_DIR=".claude/compact-backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
SLOT="$BACKUP_DIR/$TIMESTAMP"

mkdir -p "$SLOT"

BACKED=0
for f in SESSION_LOG.md MEMORY.md PHASES.md CLAUDE.md .mcp.json; do
  if [ -f "$f" ]; then
    cp "$f" "$SLOT/$f"
    echo "Backed up: $f"
    BACKED=$((BACKED + 1))
  fi
done

# Keep only the 5 most recent backups
cd "$BACKUP_DIR" && ls -t | tail -n +6 | xargs rm -rf 2>/dev/null || true

echo ""
echo "Pre-compact: $BACKED file(s) saved to $SLOT"
echo "Tip: After compaction, run /start-session to restore full context."
exit 0
