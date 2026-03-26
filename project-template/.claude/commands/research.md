# /research

Run a targeted web sweep and return a structured intelligence brief.

`$ARGUMENTS`: topic, library, question, or pattern to research.

## Steps

1. Use Tavily MCP if connected. Otherwise use `web_search`.
2. Run 3–5 distinct, targeted searches. Each query must differ meaningfully from the last.
3. Cross-reference at least 2 sources per key finding.
4. Output the brief in this structure:

```
RESEARCH: [topic]
Date: [today]

SUMMARY
[2–3 sentences — the single most important finding]

KEY FINDINGS
• [Finding 1 — paraphrased, with source URL]
• [Finding 2 — paraphrased, with source URL]
• [Finding 3 — paraphrased, with source URL]

RELEVANCE TO THIS PROJECT
[1–3 concrete actions based on findings, tailored to the detected stack]

SOURCES
• [url 1]
• [url 2]
```

5. Append the brief to `SESSION_LOG.md`:

```markdown
## Research: [topic] — [YYYY-MM-DD]
[paste full brief]
```

If `$ARGUMENTS` is empty, run the intelligence sweep defined in Step 6 of `~/.claude/skills/master-session/SKILL.md`.
