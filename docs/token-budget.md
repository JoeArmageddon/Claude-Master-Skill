# Token budget guide

Understanding and managing Claude Code's context window is the single most important skill for productive long sessions. This doc explains how claude-session-master keeps context lean, and what you can do on top of that.

---

## How the context window fills up

Claude Code's context window is 200K tokens. Here's what typically occupies it before you type a word:

| Source | Typical cost | Notes |
|--------|-------------|-------|
| Claude Code system prompt | ~20K | Fixed, not configurable |
| `CLAUDE.md` (project) | 1K–20K | Biggest variable you control |
| Active MCP tool definitions | 1K per server | 10 servers = 10K |
| Loaded skills | 1K–5K per skill | Only if fully embedded |
| Session history | Grows with every turn | Compounds fastest |

**Without management**, a 200K window is effectively 120–140K usable by the time you start. **With claude-session-master**, you typically start at 160–170K usable — gaining 30–50K before writing a single line of code.

---

## How this system keeps context lean

### 1. CLAUDE.md ≤ 3,000 tokens (enforced)

The `/start-session` generator hard-limits `CLAUDE.md` to 3,000 tokens and 40 instructions. Research shows Claude can reliably follow ~150–200 instructions total; the system prompt already consumes ~50. Every extra instruction past that threshold degrades adherence to *all* of them — including the ones you care about most.

The generator uses `@path/to/file` references for on-demand content instead of embedding docs inline.

### 2. Skill lazy-loading

Skills in `~/.claude/skills/` have their `name` and `description` frontmatter indexed at startup. The full `SKILL.md` loads only when the skill is relevant. This means having 20 skills in your library costs ~200 tokens at startup (just their descriptions), not 20K.

### 3. `.claudeignore`

Blocks `node_modules/`, `dist/`, `build/`, lock files, coverage directories, and media files. Without this, Claude may read thousands of tokens of irrelevant content when exploring the codebase.

### 4. `DISABLE_NON_ESSENTIAL_MODEL_CALLS=1`

Set in `settings.json`. Disables background API calls Claude Code makes for non-critical features (tips, suggestions). Has no effect on your core workflow.

### 5. Compact at 80%, not 83.5%

`CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=80` in `settings.json` fires compaction slightly earlier. This gives the compaction process more room to work, producing better summaries with less loss.

### 6. PreCompact hook backs up memory files

When compaction fires, the `pre-compact.sh` hook backs up `SESSION_LOG.md`, `MEMORY.md`, `PHASES.md`, and `CLAUDE.md` before the summary is written. This preserves exact content that summarisation would otherwise compress. The last 5 backups are kept at `.claude/compact-backups/`.

### 7. Structured compact instructions

`settings.json` includes:
```json
"compactInstructions": "Preserve: current phase goals, all architectural decisions in MEMORY.md, list of files modified, blocker list, next actions. Discard: debugging output, failed attempts, verbose tool call logs."
```

This tells Claude what to retain when compaction summarises. The difference between a structured compact and an unguided one is significant — you lose far less context.

### 8. MCP limit at 10

Each connected MCP server adds its tool definitions to the context window. The session audit warns if you exceed 10 project MCPs. At 15 servers, you may be burning 15–20K tokens on tool definitions alone before any conversation starts.

---

## Manual strategies (use these on top of the system)

### Use the Task tool for file exploration

```
Task: Read these 12 files and tell me which one handles authentication: [list]
```

The subagent reads all 12 files in its own context window. You get back a 2-sentence answer. Your main context spends 200 tokens instead of 12,000.

### Manual /compact at logical breakpoints

Don't wait for auto-compaction. At 70% context, run:

```
/compact Focus on: [what matters right now]. Discard: [what you're done with].
```

A focused compact is lossless for the things that matter. An auto-compact at 83% under pressure is not.

### /clear when switching topics entirely

If you finish a feature and are switching to something completely unrelated, `/clear` is better than `/compact`. Start the new task with a fresh `/start-session` call to reload memory files.

### /checkpoint mid-phase

Running `/checkpoint` every 60–90 minutes writes a structured entry to `SESSION_LOG.md`. If the session crashes or you lose context, the next `/start-session` picks up the checkpoint and rebuilds your brief from it. Nothing is lost.

### Keep CLAUDE.md under audit

Run `/start-session` regularly. It regenerates `CLAUDE.md` based on the current phase. If you've been manually editing `CLAUDE.md` and it's grown bloated, the next `/start-session` resets it to lean. If you want to preserve a manual rule, add it to `MEMORY.md` — the generator reads that.

---

## Monitoring context usage

| Method | How |
|--------|-----|
| Status bar | `context-monitor.mjs` shows live `● 47% ctx` in the terminal status line |
| `/context` command | Full breakdown by category (system, tools, memory, history) |
| `/cost` command | API token usage for the session (API users only) |

At **50%**: you have room. Work normally.  
At **70%**: start thinking about a compact after the current task.  
At **80%**: compact fires automatically. Try to do it manually first with a focus directive.

---

## Session strategy for large projects

For projects with multiple major subsystems (e.g. frontend + backend + infra), consider separate Claude Code sessions per subsystem rather than one giant session:

```bash
# Terminal 1: Frontend
cd frontend && claude
/start-session

# Terminal 2: Backend
cd backend && claude
/start-session

# Terminal 3: Infra
cd infra && claude
/start-session
```

Each session has its own 200K window. Cross-session context lives in the shared memory files at the project root — all three sessions read the same `PHASES.md` and `MEMORY.md`.
