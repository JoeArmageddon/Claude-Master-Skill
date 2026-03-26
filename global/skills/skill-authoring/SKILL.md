---
name: skill-authoring
description: Guide for writing new skills and adding them to your global skill library at ~/.claude/skills/. Use when creating a custom skill, documenting a repeatable workflow, or extending claude-session-master with domain knowledge specific to your team or stack.
---

# Skill authoring guide

## When to use this skill
- User wants to create a new reusable skill
- User wants Claude to write a skill for a workflow it keeps getting wrong
- User wants to contribute a skill to the claude-session-master library

---

## What makes a good skill

**Good candidates:**
- A workflow Claude gets wrong without explicit guidance
- A repeatable task run frequently (PR reviews, writing changelogs, deploying)
- Domain knowledge not in Claude's training (internal APIs, company conventions, proprietary tooling)
- Stack-specific patterns (e.g. "how we write migrations in this repo")

**Bad candidates:**
- General best practices Claude already follows correctly
- One-off instructions (put those in a prompt instead)
- Time-sensitive content that will go stale (version-specific workarounds, dated API patterns)

---

## File structure

```
~/.claude/skills/
└── [skill-name]/
    └── SKILL.md         ← required
    └── [reference].md  ← optional, loaded on demand via @import
```

Every `SKILL.md` must open with YAML frontmatter:

```yaml
---
name: skill-name
description: One sentence. What this skill does and when Claude should use it.
---
```

**Description rules — this is the most important line you write:**
- Under 25 words
- Start with a verb or noun, not "This skill..."
- Name the trigger context explicitly ("Use when...", "Applies to...")
- The skill router reads only this line at startup — everything else loads on demand

---

## Skill body structure

```markdown
---
name: your-skill-name
description: [under 25 words, starts with verb/noun, names trigger context]
---

# [Skill title]

## When to use
- [Trigger scenario 1]
- [Trigger scenario 2]

## Rules
- Always [non-negotiable rule 1]
- Never [non-negotiable rule 2]
- [Rule 3 — only things Claude gets wrong without this]

## Process
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Output format
[Template or description. Include a literal example if format is strict.]
```

---

## Token budget for skill authors

| Rule | Rationale |
|------|-----------|
| Keep total skill under 300 lines | Long skills get skimmed; key rules get missed |
| Frontmatter description is indexed at startup | Everything else loads on demand — make description accurate |
| No time-sensitive content | "Use the v2 API (post-Aug 2025)" will be wrong in 6 months |
| Use `@path/to/file` for large reference docs | Don't embed entire style guides inline |
| One domain per skill | Don't combine "write emails" and "write blog posts" into one file |

---

## Authoring workflow

When a user asks you to create a new skill:

### Step 1 — Interview

Ask these questions (all at once, not one by one):

1. What task or workflow should this skill handle?
2. What does Claude currently get wrong without guidance?
3. What are the 3–5 non-negotiable rules?
4. What does good output look like? (ask for an example)
5. What should the skill be named? (suggest gerund form: `reviewing-prs`, `writing-changelogs`)

### Step 2 — Draft

Write the full `SKILL.md`. Show it to the user before saving.

### Step 3 — Install

```bash
mkdir -p ~/.claude/skills/[skill-name]
# Write SKILL.md to ~/.claude/skills/[skill-name]/SKILL.md
```

### Step 4 — Verify

Run `/start-session` in a relevant project. Confirm the skill appears in the ACTIVE SKILLS section of the session briefing.

### Step 5 — Test

Run a task that should trigger the skill. If Claude doesn't apply it correctly:
- Make the description more specific
- Add an explicit "When to use" trigger list at the top of the body
- Check that description keywords match the user's natural language

---

## Naming conventions

Lowercase kebab-case. Prefer gerund (verb + `-ing`):

| Good | Avoid |
|------|-------|
| `reviewing-prs` | `pr-review` |
| `writing-changelogs` | `changelog` |
| `debugging-typescript` | `typescript-debug` |
| `generating-api-docs` | `api-docs` |
| `writing-cold-emails` | `cold-email` |

---

## When to update or delete a skill

**Update when:**
- Claude keeps making a mistake the skill should prevent
- A workflow changes significantly
- A rule becomes outdated

**Delete when:**
- The use case no longer exists
- Claude handles it correctly without the skill (models improve over time)
- A better skill supersedes it

```bash
# Delete a skill
rm -rf ~/.claude/skills/[skill-name]
```

The router will stop surfacing it after the next `/start-session`.

---

## Contributing skills to claude-session-master

If you write a skill that would help others:
1. Make it fully generic (no company names, internal URLs, or project-specific paths)
2. Test it across at least 2 different projects
3. Open a PR to the `community-skills/` directory in the repo
4. Follow the naming conventions and token budget rules above

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for the full contribution process.
