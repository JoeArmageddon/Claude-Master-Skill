# /end-phase

Run the phase-end protocol from `~/.claude/skills/master-session/SKILL.md`.

Execute all steps in the `/end-phase behaviour` section in order:
1. Run the 5-point reflection checklist
2. Append to SESSION_LOG.md
3. Update MEMORY.md with new decisions
4. Update PHASES.md to mark phase done
5. Issue guided /compact
6. Output the phase completion summary

Do not abbreviate the session log entry. Do not skip any step.

If `$ARGUMENTS` is provided, include it in the session log as "Additional notes: $ARGUMENTS".
