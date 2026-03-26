# /checkpoint

Save a lightweight mid-session checkpoint. Lighter than /end-phase — no reflection, no compaction.

Use this at natural pauses within a phase to record progress.

`$ARGUMENTS`: optional note to include in the checkpoint entry.

## Steps

1. Append to `SESSION_LOG.md` under the current session block:

```markdown
### Checkpoint [HH:MM] — [YYYY-MM-DD]
[What was completed since last checkpoint — 2–3 bullets]
[Note: $ARGUMENTS if provided]
```

2. If any architectural decisions were made since the last checkpoint, append to `MEMORY.md`:

```markdown
## [YYYY-MM-DD] — [Decision title]
[1–2 sentence description and rationale]
```

3. Run:
```bash
git diff --stat 2>/dev/null | tail -5 || ls -lt | head -5
```

4. Output:
```
Checkpoint saved — [time]
Modified: [file list from git diff or ls]
Next: keep working, or run /end-phase when the phase is complete.
```

To also compact context, pass `compact` as the argument:  
`/checkpoint compact` → saves checkpoint then runs `/compact` with a focused directive.
