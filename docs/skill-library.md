# Skill library guide

Your global skill library lives at `~/.claude/skills/`. Skills are markdown files Claude reads on demand — they extend Claude's behaviour without bloating every session.

---

## How skills load

At `/start-session`, the skill router reads only the `name` and `description` frontmatter from every skill in your library. This costs ~10 tokens per skill regardless of how long the skill body is.

When a skill is matched to the current phase, Claude is told to read it on demand:
```
• frontend-design — Production-grade UI component patterns → Read ~/.claude/skills/frontend-design/SKILL.md
```

The full skill content loads only when Claude actually needs it. A library of 30 skills costs ~300 tokens at startup.

---

## Building your library

### From the Claude Code public skill library

Claude Code's official skill library contains production-tested skills for common domains. Install them individually:

```bash
# Example: install the frontend-design skill
mkdir -p ~/.claude/skills/frontend-design
# Copy SKILL.md from the Claude Code skills marketplace or docs
```

### From community-skills in this repo

```bash
# Example: install a community skill
mkdir -p ~/.claude/skills/reviewing-prs
cp community-skills/reviewing-prs/SKILL.md ~/.claude/skills/reviewing-prs/SKILL.md
```

### Creating your own

Run `/new-skill` inside Claude Code. Claude interviews you about the workflow, drafts the skill, and installs it.

Or follow the authoring guide in `global/skills/skill-authoring/SKILL.md`.

---

## Recommended library for common project types

### Web / SaaS projects
```
~/.claude/skills/
├── master-session/       ← required
├── skill-authoring/      ← required
├── frontend-design/      ← UI components, layout, design system
├── reviewing-prs/        ← PR review protocol
└── writing-changelogs/   ← changelog and release notes
```

### Full-stack + data
```
~/.claude/skills/
├── master-session/
├── skill-authoring/
├── frontend-design/
├── xlsx/                 ← spreadsheet generation
├── pdf/                  ← PDF creation
└── debugging-apis/       ← API debugging workflow
```

### Content / documentation
```
~/.claude/skills/
├── master-session/
├── skill-authoring/
├── docx/                 ← Word document generation
├── pptx/                 ← Presentation creation
├── pdf-reading/          ← Extracting content from PDFs
└── writing-blog-posts/   ← Blog post structure and tone
```

---

## Skill routing logic

The router matches skills using keyword overlap between the skill's `description` and:
1. The current phase name and goal from `PHASES.md`
2. The last session log entry from `SESSION_LOG.md`
3. The detected stack from `package.json` / `pyproject.toml`

**To improve routing accuracy for your skills:**
- Make descriptions specific: "Applies to UI component work in React and Next.js" routes better than "frontend development"
- Use the trigger context format: "Use when building..." or "Applies to..."
- Match the language you actually use in your phase goals

---

## Pruning your library

Delete skills Claude no longer needs:

```bash
rm -rf ~/.claude/skills/[skill-name]
```

The router will stop surfacing it immediately. A good time to prune:
- After a project type changes significantly
- When a skill's guidance is now standard Claude behaviour (models improve)
- When you've replaced a skill with a better one

---

## Skill file size budget

| Size | Status |
|------|--------|
| Under 100 lines | Ideal |
| 100–300 lines | Acceptable |
| Over 300 lines | Split into skill + reference doc (`@path/to/reference.md`) |
| Over 500 lines | Will be skimmed, not read — key rules will be missed |

Keep skills tight. Rules buried in long skills get missed the same way rules buried in a bloated `CLAUDE.md` do.
