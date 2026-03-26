---
name: master-session
description: Session orchestrator for Claude Code. Triggered by /start-session. Auto-generates a lean CLAUDE.md, builds a session brief from unified memory files, lazy-routes relevant skills from your global library, audits project MCP servers, runs a web intelligence sweep, and surfaces prioritised next actions. Also powers /end-phase for phase-gated reflection and guided compaction.
---

# Master session skill

You are the session orchestrator. When invoked via `/start-session`, execute every step below in order, silently, without asking for confirmation. Present only the final briefing block to the user.

---

## Step 1 — Scan the project

Run these shell commands and capture output. Do not show raw output to the user.

```bash
# Stack detection
[ -f package.json ] && cat package.json | python3 -c "
import sys, json
d = json.load(sys.stdin)
deps = {**d.get('dependencies', {}), **d.get('devDependencies', {})}
scripts = list(d.get('scripts', {}).keys())
print('STACK_DEPS:', list(deps.keys())[:20])
print('SCRIPTS:', scripts[:10])
print('PROJECT_NAME:', d.get('name', 'unknown'))
" 2>/dev/null
[ -f pyproject.toml ] && echo "STACK: Python/pyproject"
[ -f Cargo.toml ]     && grep '^name' Cargo.toml | head -1
[ -f go.mod ]         && head -2 go.mod
[ -f pom.xml ]        && echo "STACK: Java/Maven"
[ -f composer.json ]  && echo "STACK: PHP/Composer"

# Git context
git branch --show-current 2>/dev/null
git log -1 --format="%s" 2>/dev/null
git status --short 2>/dev/null | head -10

# Top-level structure
ls -1 2>/dev/null | head -20

# Memory files
[ -f PHASES.md ]      && cat PHASES.md
[ -f SESSION_LOG.md ] && tail -80 SESSION_LOG.md
[ -f MEMORY.md ]      && cat MEMORY.md

# MCP config
[ -f .mcp.json ]      && cat .mcp.json
```

---

## Step 2 — Generate CLAUDE.md

Write a new `CLAUDE.md` to the project root. Hard limits:

- **≤ 3,000 tokens total** (aim for ~1,500)
- **≤ 40 instructions** (Claude Code system prompt already uses ~50 of the ~200 reliable slots; every extra instruction you add degrades adherence to all of them)
- Every line must pass: *"Would removing this cause Claude to make a mistake?"*
- Use `@path/to/file` for on-demand references — never embed full docs inline
- Never include: general best practices Claude already follows, time-sensitive content, version-specific workarounds

Structure to follow exactly:

```markdown
# [Project name]

## What this is
[1–2 sentences: purpose and audience]

## Stack
[Detected framework, language, key libraries — 1 line each]

## Directory map
[Key dirs only: src/, app/, lib/, db/, tests/ — 1 line each]

## Commands
[Only commands Claude needs: dev, test, build, typecheck, lint]

## Current phase
[Phase name and goal from PHASES.md — or "Phase 1: Setup" if PHASES.md is missing]

## Hard rules
[Max 10. Only things Claude gets wrong. Format: "Always X" or "Never Y"]

## On-demand references
@PHASES.md
@SESSION_LOG.md
@MEMORY.md
```

If a `CLAUDE.md` already exists, read it first. Preserve any manually written rules not already covered. Do not blindly overwrite.

---

## Step 3 — Build the 200-token session brief

Read:
- `SESSION_LOG.md` → last 3 entries
- `PHASES.md` → current phase section
- `MEMORY.md` → last 5 decisions

Synthesise into a brief. Stay under 200 tokens:

```
PHASE:     [name] — [goal in ≤10 words]
LAST:      [what was completed last session — 1 sentence]
BLOCKERS:  [unresolved issues, or "none"]
ANCHORS:   [2–3 architectural decisions Claude must not contradict]
CONTEXT:   [current git branch + last commit message]
```

---

## Step 4 — Lazy skill routing

Scan `~/.claude/skills/` for all available `SKILL.md` files. Read only the `name` and `description` frontmatter — do not load full skill content yet.

Match to the current task context:

| Context signal | Skills to surface |
|---------------|-------------------|
| UI / frontend work | `frontend-design` |
| Document generation | `docx`, `pdf`, `pptx` |
| Spreadsheet work | `xlsx` |
| File reading / uploads | `file-reading`, `pdf-reading` |
| Creating a new skill | `skill-authoring` |
| Any other signal | Match description keywords to phase goal |

Surface the top 2–4 matches only. Output:

```
ACTIVE SKILLS (load on demand):
• [name] — [description] → Read ~/.claude/skills/[name]/SKILL.md
```

If no skills match, say "No skills matched for this phase."

---

## Step 5 — MCP audit

Read `.mcp.json`. Count active servers.

Rules:
- If > 10 MCPs active: warn — each MCP adds tool definitions consuming context
- If Tavily is absent and web research is likely this session: suggest adding it
- If Context7 is absent and a major framework is detected: suggest adding it
- List active project MCPs by name only

Suggested install commands (only show if relevant):

```bash
# Web research
claude mcp add --transport http tavily https://mcp.tavily.com/mcp --scope project

# Framework documentation
claude mcp add --transport http context7 https://mcp.context7.com/mcp --scope project
```

---

## Step 6 — Web intelligence sweep

Run 3 searches maximum. Use Tavily MCP if connected, otherwise use `web_search`.

Search for:
1. Security advisories for the top 3 detected dependencies
2. Breaking changes in the detected framework's latest stable version
3. Any tool in the project's `scripts` block that may have had a major update

Summarise in ≤5 bullets. Flag anything critical with `⚠`. If nothing found: "No critical advisories found."

---

## Step 7 — Prioritised suggestions

Generate 3–5 next actions ranked by priority. Each must be:
- **Specific** — name the file, feature, or issue
- **Actionable this session** — completable in 1–4 hours
- **Derived from** PHASES.md gate criteria, SESSION_LOG.md blockers, or git status

```
SUGGESTED NEXT ACTIONS:
1. [highest priority]
2. [second]
3. [third]
```

---

## Step 8 — Final briefing output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SESSION START — [Project] — [Date]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[200-token brief from Step 3]

ACTIVE SKILLS:  [comma-separated names, or "none matched"]
ACTIVE MCPs:    [comma-separated names, or "none configured"]

INTELLIGENCE BRIEF:
[web sweep from Step 6]

[Suggestions from Step 7]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CLAUDE.md regenerated. Ready.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## /end-phase behaviour

When invoked via `/end-phase`:

### 1. Reflection checklist (run silently, report scores)

Score each: `pass` / `warn` / `fail`

| # | Check |
|---|-------|
| 1 | **CLAUDE.md compliance** — Did any work violate the hard rules? |
| 2 | **Skill adherence** — Were loaded skills' key rules followed? |
| 3 | **Architecture consistency** — Were any decisions made that contradict MEMORY.md? |
| 4 | **Phase gate** — Were the phase's gate criteria in PHASES.md actually met? |
| 5 | **Tech debt** — Were any intentional shortcuts taken that need tracking? |

### 2. Append to SESSION_LOG.md

```markdown
## Session [YYYY-MM-DD] — [Phase name]

**Completed:**
- [bullet]

**Decisions made:**
- [bullet, or "none"]

**Blockers / carry-forward:**
- [bullet, or "none"]

**Reflection:**
- CLAUDE.md compliance: [score]
- Skill adherence: [score]
- Architecture consistency: [score]
- Phase gate: [score]
- Tech debt: [score — list any debt items]
```

### 3. Update MEMORY.md

If new architectural decisions were made, append:

```markdown
## [YYYY-MM-DD] — [Decision title]
[1–2 sentence description and rationale]
```

### 4. Update PHASES.md

Mark the completed phase `[DONE]`. Confirm the next phase is defined.

### 5. Guided compaction

```
/compact Focus on: completed phase goals, all architectural decisions, key file changes, next phase starting state. Discard: debugging output, failed attempts, verbose tool logs.
```

### 6. Output summary

```
Phase [name] complete.
SESSION_LOG, MEMORY, PHASES updated.
Context compacted.

Next: [next phase name] — [goal]
Run /start-session to begin with clean context.
```

---

## Token budget rules (enforce throughout every session)

These apply at all times, not just startup:

- **CLAUDE.md is not a knowledge base.** If a rule would push it past 3,000 tokens, move it to a skill or MEMORY.md.
- **Never `@`-import a file into CLAUDE.md inline** unless it's under 200 tokens. Use path references with "load on demand."
- **Load ≤ 4 skills simultaneously.** If a new skill is needed, assess whether a loaded one can be dropped first.
- **At 70% context: proactively suggest `/compact`** before auto-compaction fires. Auto-compaction is lossy; manual with a focus directive is not.
- **Use the Task tool for file exploration.** Spawning a subagent to read 15 files and return a summary keeps the main context clean.
- **Keep project MCPs ≤ 10.** Each one adds tool definitions. Remove unused ones: `claude mcp remove [name] --scope project`.
- **Batch related file edits** into a single task instead of reading and editing them one by one across multiple turns.
