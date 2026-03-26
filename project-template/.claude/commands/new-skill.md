# /new-skill

Create a new skill for your global skill library at `~/.claude/skills/`.

Read `~/.claude/skills/skill-authoring/SKILL.md` and follow its authoring workflow exactly.

## Steps

1. If `$ARGUMENTS` is provided, treat it as the initial description of what the skill should do and skip directly to drafting.
2. If `$ARGUMENTS` is empty, run the interview from Step 1 of the skill-authoring workflow — ask all questions at once, not one by one.
3. Draft the full `SKILL.md` following the template in the skill-authoring guide.
4. Show the draft to the user and ask: "Does this look right? I'll install it once you confirm."
5. On confirmation, write the file to `~/.claude/skills/[skill-name]/SKILL.md`.
6. Output:
```
Skill installed: ~/.claude/skills/[skill-name]/SKILL.md
Run /start-session in a relevant project to verify it appears in ACTIVE SKILLS.
```
