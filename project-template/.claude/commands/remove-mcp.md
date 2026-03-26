# /remove-mcp

Remove an MCP server from this project's scope.

`$ARGUMENTS`: name of the MCP server to remove.

## Steps

1. If `$ARGUMENTS` is empty: run `claude mcp list`, show project MCPs, ask which to remove
2. Run: `claude mcp remove $ARGUMENTS --scope project`
3. Verify: `claude mcp list`
4. Output: `Removed [name]. Active MCPs: [count remaining]`

Note: removes only from this project's `.mcp.json`. Does not affect global MCP config.
