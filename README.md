# claude-session-master

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-%3E%3D1.0.0-blue)](https://code.claude.com)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](./CONTRIBUTING.md)

> A session orchestration framework for [Claude Code](https://code.claude.com). One slash command gives Claude persistent memory, phase-gated reflection, lazy skill routing, project-scoped MCP management, and a web intelligence sweep — every session, automatically.

---

## The problem

Every Claude Code session starts cold. Claude doesn't know what you were building, what decisions you made last week, what phase you're in, or what traps to avoid. You repeat yourself constantly. Context bloats. Compaction fires mid-task and loses critical detail.

**claude-session-master fixes this.**

---

## How it works

Run `/start-session` at the top of every Claude Code session. Claude will:

1. **Scan** the project — stack, git status, directory structure
2. **Generate** a lean `CLAUDE.md` (≤3,000 tokens, phase-aware, auto-refreshed)
3. **Build** a 200-token session brief from your memory files
4. **Route** only the relevant skills from your global library (lazy-loaded — no context bloat)
5. **Audit** active MCP servers and warn if too many are loaded
6. **Sweep** the web for security advisories and breaking changes in your stack
7. **Surface** 3–5 prioritised next actions specific to your project state

When a phase is done, run `/end-phase`. Claude will:

- Run a 5-point reflection checklist
- Append a structured entry to `SESSION_LOG.md`
- Update `MEMORY.md` with new architectural decisions
- Mark `PHASES.md` as done
- Issue a guided `/compact` before the next phase begins

---

## Quick start

```bash
# Clone
git clone https://github.com/JoeArmageddon/Claude-Master-Skill.git
cd Claude-Master-Skill

# Install globally (skills available in all projects)
bash install.sh --global-only

# Install into your project
cd /your/project
bash /path/to/Claude-Master-Skill/install.sh --project-only

# Edit PHASES.md to define your project phases
# Then open Claude Code and run:
/start-session
```

That's it. Claude handles the rest.

---

## Installation

### Requirements

| Dependency | Notes |
|------------|-------|
| [Claude Code](https://code.claude.com) | v1.0.0 or later |
| Bash | macOS, Linux, or WSL on Windows |
| Python 3 | Used for stack detection in hooks — usually pre-installed |
| Node.js | Optional — only needed for the live context % status bar |

### Install options

```bash
# Full install (global skills + project template in current directory)
bash install.sh

# Global only — skills available to all projects
bash install.sh --global-only

# Project only — template into current directory
bash install.sh --project-only

# Project into a specific path
bash install.sh --dir /path/to/your/project

# See all options
bash install.sh --help
```

The installer is safe to re-run. It never overwrites existing files — it merges or skips, and tells you which.

---

## File structure

After install, your workspace looks like this:

```
~/.claude/                              ← global (all projects)
├── CLAUDE.md                           ← your personal preferences
└── skills/
    ├── master-session/
    │   └── SKILL.md                    ← the orchestrator (required)
    ├── skill-authoring/
    │   └── SKILL.md                    ← guide for writing new skills
    └── [your other skills]/            ← add any skills you want routed

your-project/
├── CLAUDE.md                           ← auto-generated, do not hand-edit
├── PHASES.md                           ← phase plan — you define this
├── SESSION_LOG.md                      ← session diary — Claude writes
├── MEMORY.md                           ← architectural decisions — persists forever
├── .claudeignore                       ← files Claude should never read
└── .claude/
    ├── settings.json                   ← hooks, statusline, token budget env
    ├── commands/
    │   ├── start-session.md            ← /start-session
    │   ├── end-phase.md                ← /end-phase
    │   ├── checkpoint.md               ← /checkpoint
    │   ├── add-mcp.md                  ← /add-mcp [name]
    │   ├── remove-mcp.md               ← /remove-mcp [name]
    │   ├── research.md                 ← /research [topic]
    │   └── new-skill.md                ← /new-skill
    └── hooks/
        ├── session-start.sh            ← live git + phase status at startup
        ├── pre-compact.sh              ← backs up memory files before compaction
        └── context-monitor.mjs         ← live context % in the status bar
```

---

## Slash commands

| Command | What it does |
|---------|-------------|
| `/start-session` | Full session init — run this first, every time |
| `/end-phase` | Reflection + log + compact. Run when a phase is complete |
| `/checkpoint` | Lightweight mid-session save. No reflection, no compact |
| `/checkpoint compact` | Checkpoint + guided compact |
| `/add-mcp [name]` | Add a project-scoped MCP server |
| `/remove-mcp [name]` | Remove a project-scoped MCP server |
| `/research [topic]` | On-demand web sweep on any topic |
| `/new-skill` | Interactively create and install a new skill |

---

## Memory files

| File | Purpose | Written by |
|------|---------|-----------|
| `CLAUDE.md` | Session instructions for Claude | Auto-generated by `/start-session` |
| `PHASES.md` | Phase plan and gate criteria | You define it; `/end-phase` updates status |
| `SESSION_LOG.md` | Running session diary | `/end-phase` + `/checkpoint` + `/research` |
| `MEMORY.md` | Architectural decisions that persist forever | `/end-phase` + you |
| `.mcp.json` | Project MCP server list | `/add-mcp` + `/remove-mcp` |
| `.claudeignore` | Files Claude should never read | You edit |

---

## Token budget

The system is designed to stay lean from the start:

| Strategy | Effect |
|----------|--------|
| `CLAUDE.md` ≤ 3,000 tokens | Auto-generated and phase-aware — no accumulated bloat |
| Skill lazy-loading | Only 2–4 skill summaries at startup; full content loaded on demand |
| `.claudeignore` | Blocks `node_modules`, `dist`, lock files, media |
| `DISABLE_NON_ESSENTIAL_MODEL_CALLS=1` | Cuts background tip/suggestion API calls |
| Compact at 80% | Fires earlier than default (83.5%) with a structured focus directive |
| PreCompact hook | Backs up all memory files before compaction so nothing is lost |
| MCP limit warning | Warns when > 10 project MCPs are active |
| Task tool pattern | File exploration via subagent keeps main context clean |

Based on community benchmarks, this combination typically reduces per-session token usage by **40–60%** compared to an unmanaged setup.

### Token math

Claude Code's context window is 200K tokens. The system prompt uses ~20K before you type a word:

```
Without claude-session-master:
  System prompt        ~20K
  CLAUDE.md (bloated)  ~15K
  All skills loaded    ~12K
  MCPs (15 servers)    ~18K
  Available for work   ~135K  (67%)

With claude-session-master:
  System prompt        ~20K
  CLAUDE.md (lean)     ~3K
  Skills (lazy, 2–4)   ~2K
  MCPs (≤10, audited)  ~10K
  Available for work   ~165K  (82%)
```

That extra 30K tokens per session compounds significantly across a long project.

---

## Skill library

The skill router surfaces skills from `~/.claude/skills/` that match your current phase. Install any skill by placing its `SKILL.md` in the right directory:

```bash
mkdir -p ~/.claude/skills/[skill-name]
cp /path/to/SKILL.md ~/.claude/skills/[skill-name]/SKILL.md
```

Or use `/new-skill` to have Claude write a skill interactively.

### Recommended skills to install

| Skill | Source | When it's surfaced |
|-------|--------|-------------------|
| `frontend-design` | [Claude public skills](https://code.claude.com/docs/skills) | UI/frontend phases |
| `docx` | Claude public skills | Document generation |
| `pptx` | Claude public skills | Presentation creation |
| `pdf` | Claude public skills | PDF creation/manipulation |
| `xlsx` | Claude public skills | Spreadsheet work |
| `file-reading` | Claude public skills | File upload handling |

### Community skills

See [`community-skills/`](./community-skills/) for skills contributed by the community. Add yours — see [CONTRIBUTING.md](./CONTRIBUTING.md).

---

## Recommended MCPs

Add with `/add-mcp [name]`:

| Name | Purpose | Best for |
|------|---------|---------|
| `tavily` | Web research | All projects |
| `context7` | Framework docs lookup | Projects using major frameworks |
| `github` | PR reviews, issue management | Any team project |
| `supabase` | Database, auth, storage | Supabase projects |
| `playwright` | Browser automation, e2e | Frontend + QA |
| `sequential-thinking` | Complex problem decomposition | Architecture phases |

Keep active MCPs ≤ 10. Each one adds tool definitions to your context window.

---

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for how to:

- Contribute a community skill
- Report bugs
- Suggest features
- Improve the core skill

---

## License

MIT — see [LICENSE](./LICENSE).

---

## Acknowledgements

Inspired by techniques from:
- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)
- [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework)
- [HumanLayer blog — Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)
- The Claude Code community on Reddit and Discord
