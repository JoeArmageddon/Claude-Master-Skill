# Contributing to claude-session-master

Thanks for contributing. This project improves when real Claude Code users share what works.

---

## Ways to contribute

### 1. Community skills

The most valuable contribution. If you've written a skill that makes Claude meaningfully better at a specific task, share it.

**What qualifies:**
- Fully generic (no company names, internal URLs, proprietary tooling)
- Tested across at least 2 different projects
- Under 300 lines
- Follows the skill template (see below)

**Where it goes:** `community-skills/[skill-name]/SKILL.md`

**How to submit:**
1. Fork the repo
2. Create `community-skills/[your-skill-name]/SKILL.md`
3. Add a one-line entry to `community-skills/README.md`
4. Open a PR with the title: `skill: [skill-name] — [one sentence description]`

**Skill template:**
```markdown
---
name: your-skill-name
description: [under 25 words, starts with verb/noun, names trigger context]
---

# [Skill title]

## When to use
- [Trigger scenario]

## Rules
- Always [rule]
- Never [rule]

## Process
1. [Step]
2. [Step]

## Output format
[Template or description]
```

See `global/skills/skill-authoring/SKILL.md` for the full authoring guide.

---

### 2. Bug reports

Open an issue with the `bug` label. Include:

- Claude Code version (`claude --version`)
- OS and shell
- Which command or hook failed
- The exact error message or unexpected behaviour
- Steps to reproduce

Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md).

---

### 3. Feature requests

Open an issue with the `enhancement` label. Describe:

- The problem you're trying to solve
- What you expected the system to do
- Why this would be useful to others (not just your specific workflow)

Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md).

---

### 4. Core improvements

For changes to `install.sh`, `SKILL.md`, hooks, or commands:

1. Open an issue first describing the change — get feedback before writing code
2. Fork and branch from `main`
3. Test against at least 2 different project types (Node.js, Python, etc.)
4. Open a PR with a clear description of what changed and why

---

## PR checklist

Before opening a PR:

- [ ] No company-specific or project-specific content
- [ ] No time-sensitive content (version-specific workarounds, dated API references)
- [ ] Skill files are under 300 lines
- [ ] Skill frontmatter `description` is under 25 words
- [ ] Hooks exit 0 (never block Claude Code sessions)
- [ ] install.sh changes tested on macOS and Linux
- [ ] README updated if a new command or file was added

---

## Code style

- Shell scripts: `bash`, `set -euo pipefail`, always `exit 0` for hooks
- Markdown: sentence case, no title case, no ALL CAPS
- Skill files: follow the template exactly — frontmatter, then `## When to use`, `## Rules`, `## Process`
- No emoji in shell scripts or SKILL.md files
- Comments in shell: explain *why*, not *what*

---

## Community skills directory structure

```
community-skills/
├── README.md                    ← index of all community skills
├── reviewing-prs/
│   └── SKILL.md
├── writing-changelogs/
│   └── SKILL.md
└── [your-skill]/
    └── SKILL.md
```

---

## Questions?

Open a discussion in the [GitHub Discussions](../../discussions) tab. Not an issue — a discussion.
