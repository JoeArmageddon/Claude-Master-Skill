# Changelog

All notable changes to claude-session-master are documented here.

Format: [Semantic Versioning](https://semver.org). Dates are YYYY-MM-DD.

---

## [1.0.0] — 2026-03-27

Initial public release.

### Added
- `master-session` skill — session orchestrator (Steps 1–8 + /end-phase protocol)
- `skill-authoring` skill — guide for writing and contributing new skills
- `/start-session` command — full session initialisation
- `/end-phase` command — phase reflection + SESSION_LOG + MEMORY + guided compact
- `/checkpoint` command — lightweight mid-session save
- `/add-mcp` command — project-scoped MCP server management
- `/remove-mcp` command — MCP server removal
- `/research` command — on-demand web intelligence sweep
- `/new-skill` command — interactive skill creation workflow
- `session-start.sh` hook — live git + phase status injected at startup
- `pre-compact.sh` hook — backs up memory files before auto-compaction
- `context-monitor.mjs` — live context percentage in the status bar
- `settings.json` — hooks, statusline, token budget env vars pre-configured
- `PHASES.md` template — phase plan and gate criteria
- `SESSION_LOG.md` template — cross-session diary
- `MEMORY.md` template — architectural decisions
- `.claudeignore` — comprehensive file exclusion list
- `global/CLAUDE.md` — personal preferences template
- `install.sh` — one-command installer with merge-safe re-runs
- `community-skills/` directory for community contributions
- GitHub issue templates (bug report, feature request)
- GitHub Actions CI for install script testing

---

<!-- Add new entries above this line. Format:
## [X.Y.Z] — YYYY-MM-DD
### Added / Changed / Fixed / Removed
- [description]
-->
