# MFP: Main Force Patrol for Basecamp

A full-coverage Ruby MCP server for the Basecamp 3/4 API. Built with the official [MCP Ruby SDK](https://github.com/modelcontextprotocol/ruby-sdk) and designed to work with Claude Desktop, Claude Code, and any MCP-compatible client.

Named after the Main Force Patrol from *Mad Max* -- because someone has to bring law and order to the wasteland of incomplete Basecamp integrations.

## Why MFP

Every existing Basecamp MCP server is incomplete. The best Python implementation covers 64 tools. The Node.js "complete" version is undocumented and untested. None are written in Ruby, despite Basecamp being built by a Ruby shop.

MFP targets **137 tools** covering the entire Basecamp 4 API surface. Phase 1 ships with 41 tools across the most-used domains.

| Feature | mcp-basecamp (PyPI) | georgeantonopoulos | MFP |
|---------|--------------------|--------------------|-----|
| Language | Python | Python | Ruby |
| Tools | ~15 | 64 | 41 (Phase 1), 137 planned |
| Card Tables | No | No | Planned |
| Client Access | No | No | Planned |
| Webhooks | No | No | Planned |
| Rich text handling | Basic | Basic | Full (HTML stripped for AI) |
| Pagination | No | Yes | Yes (automatic) |
| Rate limiting | No | No | Yes (automatic retry) |
| Token refresh | No | Yes | Yes (automatic) |

## Current Tools (Phase 1)

### People (4 tools)
`list_people` `get_person` `get_my_profile` `list_pingable_people`

### Projects (5 tools)
`list_projects` `get_project` `create_project` `update_project` `trash_project`

### Message Boards (1 tool)
`get_message_board`

### Messages (7 tools)
`list_messages` `get_message` `create_message` `update_message` `trash_message` `pin_message` `unpin_message`

### Message Types (5 tools)
`list_message_types` `get_message_type` `create_message_type` `update_message_type` `trash_message_type`

### To-Do Sets (1 tool)
`get_todoset`

### To-Do Lists (5 tools)
`list_todolists` `get_todolist` `create_todolist` `update_todolist` `trash_todolist`

### To-Dos (8 tools)
`list_todos` `get_todo` `create_todo` `update_todo` `complete_todo` `uncomplete_todo` `reposition_todo` `trash_todo`

### Comments (5 tools)
`list_comments` `get_comment` `create_comment` `update_comment` `trash_comment`

## Requirements

- Ruby >= 3.1.0
- A Basecamp 3 or 4 account
- A Basecamp API token (see [Authentication](#authentication))

## Installation

Clone the repository and install dependencies:

```bash
git clone https://github.com/merovex/mfp-basecamp.git
cd mfp-basecamp
bundle install
```

## Authentication

MFP supports two authentication methods.

### Option A: API Key (simplest)

If you already have a Basecamp API key, pass it directly via environment variables. This is the recommended approach for quick setup.

You'll need three values:

1. **API Key** -- Your Basecamp OAuth token. You can generate one at [https://launchpad.37signals.com/integrations](https://launchpad.37signals.com/integrations).
2. **Account ID** -- The numeric ID from your Basecamp URL (e.g., `https://3.basecamp.com/5516303/` means the account ID is `5516303`).
3. **User-Agent** -- Basecamp requires a User-Agent header with your app name and contact email.

### Option B: OAuth Setup Flow

Run the interactive setup command to walk through the full OAuth 2.0 flow:

```bash
ruby bin/basecamp-mcp setup
```

This will:
1. Prompt you for your OAuth Client ID and Client Secret
2. Open your browser to authorize with Basecamp
3. Exchange the authorization code for access/refresh tokens
4. Save credentials to `~/.basecamp-mcp/credentials.json` (mode 0600)

Tokens are automatically refreshed on 401 responses.

## Configuration

### Claude Desktop

Add MFP to your Claude Desktop config at `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "mfp-basecamp": {
      "command": "ruby",
      "args": ["/path/to/mfp-basecamp/bin/basecamp-mcp"],
      "env": {
        "BASECAMP_API_KEY": "your-api-token-here",
        "BASECAMP_ACCOUNT_ID": "your-account-id",
        "BASECAMP_USER_AGENT": "MFP Basecamp (you@example.com)"
      }
    }
  }
}
```

Or generate a starter config:

```bash
ruby bin/basecamp-mcp config
```

### Claude Code

Add to your Claude Code MCP settings:

```bash
claude mcp add mfp-basecamp -- ruby /path/to/mfp-basecamp/bin/basecamp-mcp
```

Set the required environment variables in your shell profile or use `--env` flags.

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `BASECAMP_API_KEY` | Yes* | Basecamp OAuth access token |
| `BASECAMP_ACCOUNT_ID` | Yes* | Numeric account ID from your Basecamp URL |
| `BASECAMP_USER_AGENT` | No | User-Agent string (default: `BasecampMCP (basecamp-mcp@example.com)`) |
| `BASECAMP_BASE_URL` | No | API base URL (default: `https://3.basecampapi.com`) |
| `BASECAMP_ACCESS_TOKEN` | Yes* | Alias for `BASECAMP_API_KEY` |
| `BASECAMP_REFRESH_TOKEN` | No | OAuth refresh token for automatic renewal |
| `BASECAMP_CLIENT_ID` | No | OAuth client ID (needed for token refresh) |
| `BASECAMP_CLIENT_SECRET` | No | OAuth client secret (needed for token refresh) |

*Either `BASECAMP_API_KEY` or `BASECAMP_ACCESS_TOKEN` is required (unless using `~/.basecamp-mcp/credentials.json`).

## Usage

Once configured, MFP tools are available to your AI assistant. Examples of what you can ask:

**Project overview:**
> "List all my active Basecamp projects"

**To-do management:**
> "Show me the to-do lists in project 12345"
> "Create a to-do 'Review pull request' in to-do list 67890 on project 12345, due Friday"
> "Mark to-do 11111 as complete in project 12345"

**Messages:**
> "Post a message titled 'Sprint Recap' to the message board in project 12345"
> "List all messages in the message board for project 12345"

**Comments:**
> "Add a comment 'Looks good to me' to to-do 11111 in project 12345"

**People:**
> "Who's on this Basecamp account?"

### Finding IDs

Most tools require a `project_id`. Start by listing projects:
1. Use `list_projects` to find your project ID
2. Use `get_project` with that ID to see the project's "dock" -- this contains IDs for the message board, to-do set, schedule, etc.
3. Use those dock IDs to access specific tools (e.g., `list_todolists` with the todoset ID)

## Architecture

```
lib/
  basecamp_mcp.rb                    # Top-level require
  basecamp_mcp/
    client.rb                        # Faraday HTTP client with auto-pagination
    token_store.rb                   # Credential management (env vars + file)
    html_utils.rb                    # HTML-to-text stripping for AI readability
    tool_helpers.rb                  # Shared helpers for all tool classes
    server.rb                        # MCP server bootstrap (STDIO transport)
    setup.rb                         # OAuth setup flow (lazy-loaded)
    middleware/
      token_refresh.rb               # Auto-refresh on 401
      rate_limit_retry.rb            # Auto-retry on 429 with Retry-After
    tools/
      people.rb                      # 4 tools
      projects.rb                    # 5 tools
      message_boards.rb              # 1 tool
      messages.rb                    # 7 tools
      message_types.rb               # 5 tools
      todosets.rb                    # 1 tool
      todolists.rb                   # 5 tools
      todos.rb                       # 8 tools
      comments.rb                    # 5 tools
```

Tools are auto-discovered at startup. Adding a new domain means creating a file in `tools/` and adding its name to the `TOOL_FILES` array in `tools.rb`. No manual registration needed.

## Roadmap

| Phase | Domain | Tools | Status |
|-------|--------|-------|--------|
| 1 | People, Projects, Messages, To-Dos, Comments | 41 | Shipped |
| 2 | Documents, Vaults, Schedule, Card Tables | 36 | Planned |
| 3 | Campfire, Chatbots, Check-ins, Inbox, Client Access | 35 | Planned |
| 4 | Recordings, Subscriptions, Events, Lineup, Timesheets, Webhooks | 26 | Planned |

## Built With

- [MCP Ruby SDK](https://github.com/modelcontextprotocol/ruby-sdk) v0.7 -- Official Model Context Protocol implementation
- [Faraday](https://github.com/lostisland/faraday) v2 -- HTTP client with middleware
- [Basecamp 4 API](https://github.com/basecamp/bc3-api) -- The API we're wrapping

## License

MIT
