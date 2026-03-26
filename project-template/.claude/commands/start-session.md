# /start-session

Initialise this Claude Code session using the master-session skill.

Read and execute every step in `~/.claude/skills/master-session/SKILL.md` — Steps 1 through 8 — in order. Do not skip any step. Do not ask for confirmation before running. Present only the final briefing block defined in Step 8.

---

If `~/.claude/skills/master-session/SKILL.md` is not found, output:

```
ERROR: master-session skill not found.

Install it by running:
  bash install.sh --global-only

Or manually:
  mkdir -p ~/.claude/skills/master-session
  cp global/skills/master-session/SKILL.md ~/.claude/skills/master-session/SKILL.md

Then re-run /start-session.
```
