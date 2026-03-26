# /add-mcp

Add an MCP server scoped to this project.

`$ARGUMENTS`: `[name] [url]` — or just `[name]` for servers in the known list below.

## Known servers

| Name | Transport | URL / Command | Purpose |
|------|-----------|---------------|---------|
| `tavily` | http | `https://mcp.tavily.com/mcp` | Web research and search |
| `context7` | http | `https://mcp.context7.com/mcp` | Framework documentation lookup |
| `github` | http | `https://api.githubcopilot.com/mcp` | PR reviews, issues, repo management |
| `supabase` | http | `https://mcp.supabase.com/mcp` | Database, auth, storage |
| `playwright` | stdio | `npx @playwright/mcp` | Browser automation, e2e testing |
| `sequential-thinking` | stdio | `npx @modelcontextprotocol/server-sequential-thinking` | Complex problem decomposition |
| `memory` | stdio | `npx @modelcontextprotocol/server-memory` | Persistent knowledge graph |

## Steps

1. Parse `$ARGUMENTS` — extract name and URL
2. If name matches a known server, use its URL and transport
3. For http transport: `claude mcp add --transport http [name] [url] --scope project`
4. For stdio transport: `claude mcp add [name] -- npx [package] --scope project`
5. Verify: `claude mcp list`
6. Check total MCP count. If > 10: warn the user
7. Output: `Added [name] to this project. Active MCPs: [count]`

If `$ARGUMENTS` is empty, list all known servers and ask which to add.
