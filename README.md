# MFP: Main Force Patrol for Basecamp

A full-coverage Ruby MCP server for the Basecamp 3/4 API. Built with the official [MCP Ruby SDK](https://github.com/modelcontextprotocol/ruby-sdk) and designed to work with Claude Desktop, Claude Code, and any MCP-compatible client.

Named after the Main Force Patrol from *Mad Max* -- because someone has to bring law and order to the wasteland of incomplete Basecamp integrations.

## Why MFP

Every existing Basecamp MCP server is incomplete. The best Python implementation covers 64 tools. The Node.js "complete" version is undocumented and untested. None are written in Ruby, despite Basecamp being built by a Ruby shop.

MFP ships **146 tools** covering the entire Basecamp 4 API surface.

| Feature | mcp-basecamp (PyPI) | georgeantonopoulos | MFP |
|---------|--------------------|--------------------|-----|
| Language | Python | Python | Ruby |
| Tools | ~15 | 64 | **146** |
| Card Tables | No | No | Yes |
| Client Access | No | No | Yes |
| Webhooks | No | No | Yes |
| Campfire / Chat | No | Partial | Yes |
| Documents & Vaults | No | Partial | Yes |
| Schedule | No | Partial | Yes |
| Timesheets | No | Partial | Yes |
| Rich text handling | Basic | Basic | Full (HTML stripped for AI) |
| Pagination | No | Yes | Yes (automatic) |
| Rate limiting | No | No | Yes (automatic retry) |
| Token refresh | No | Yes | Yes (automatic) |

## Tools (146)

### People (4 tools)
`list_people` `get_person` `get_my_profile` `list_pingable_people`

### Projects (5 tools)
`list_projects` `get_project` `create_project` `update_project` `trash_project`

### Templates (5 tools)
`list_templates` `get_template` `create_template` `update_template` `trash_template`

### Message Boards (1 tool)
`get_message_board`

### Messages (7 tools)
`list_messages` `get_message` `create_message` `update_message` `trash_message` `pin_message` `unpin_message`

### Message Types (5 tools)
`list_message_types` `get_message_type` `create_message_type` `update_message_type` `trash_message_type`

### Campfire / Chat (5 tools)
`get_campfire` `list_campfire_lines` `get_campfire_line` `create_campfire_line` `trash_campfire_line`

### Chatbots (6 tools)
`list_chatbots` `get_chatbot` `create_chatbot` `update_chatbot` `trash_chatbot` `create_chatbot_line`

### To-Do Sets (1 tool)
`get_todoset`

### To-Do Lists (5 tools)
`list_todolists` `get_todolist` `create_todolist` `update_todolist` `trash_todolist`

### To-Do List Groups (4 tools)
`list_todolist_groups` `get_todolist_group` `create_todolist_group` `reposition_todolist_group`

### To-Dos (8 tools)
`list_todos` `get_todo` `create_todo` `update_todo` `complete_todo` `uncomplete_todo` `reposition_todo` `trash_todo`

### Card Tables / Kanban (19 tools)
`get_card_table` `list_card_table_columns` `get_card_table_column` `create_card_table_column` `update_card_table_column` `trash_card_table_column` `list_cards` `get_card` `create_card` `update_card` `move_card` `trash_card` `list_card_steps` `get_card_step` `create_card_step` `complete_card_step` `uncomplete_card_step` `reposition_card_step` `trash_card_step`

### Documents (5 tools)
`list_documents` `get_document` `create_document` `update_document` `trash_document`

### Vaults / Folders (5 tools)
`list_vaults` `get_vault` `create_vault` `update_vault` `trash_vault`

### Uploads & Attachments (6 tools)
`list_uploads` `get_upload` `create_upload` `update_upload` `trash_upload` `create_attachment`

### Schedule (6 tools)
`get_schedule` `list_schedule_entries` `get_schedule_entry` `create_schedule_entry` `update_schedule_entry` `trash_schedule_entry`

### Check-ins (5 tools)
`get_questionnaire` `list_questions` `get_question` `list_question_answers` `get_question_answer`

### Email Inbox (5 tools)
`get_inbox` `list_inbox_forwards` `get_forward` `list_inbox_replies` `get_inbox_reply`

### Client Access (9 tools)
`list_client_visible_recordings` `toggle_client_visibility` `get_client_approval` `list_client_approval_responses` `list_client_correspondences` `get_client_correspondence` `create_client_correspondence` `list_client_replies` `get_client_reply`

### Comments (5 tools)
`list_comments` `get_comment` `create_comment` `update_comment` `trash_comment`

### Recordings (4 tools)
`list_recordings` `trash_recording` `archive_recording` `unarchive_recording`

### Subscriptions (4 tools)
`list_subscriptions` `subscribe` `unsubscribe` `update_subscription`

### Events / Activity Log (2 tools)
`list_events` `get_event`

### Lineup Markers (4 tools)
`list_lineup_markers` `create_lineup_marker` `update_lineup_marker` `trash_lineup_marker`

### Timesheets (6 tools)
`get_timesheet` `list_time_entries` `get_time_entry` `create_time_entry` `update_time_entry` `trash_time_entry`

### Webhooks (5 tools)
`list_webhooks` `get_webhook` `create_webhook` `update_webhook` `trash_webhook`

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

Claude Desktop launches MCP servers with a minimal `PATH` that typically only includes `/usr/bin`. If you use a Ruby version manager (mise, rbenv, asdf, rvm), Claude Desktop won't find your managed Ruby -- it will find the ancient system Ruby instead, and fail to load gems.

The fix is to use the included wrapper script, which sets the correct Ruby path:

```bash
# First, edit the wrapper to match your Ruby path:
# Open bin/mfp-basecamp-wrapper and update the PATH line
# to point at your Ruby installation.
```

Then add MFP to your Claude Desktop config at `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "mfp-basecamp": {
      "command": "/path/to/mfp-basecamp/bin/mfp-basecamp-wrapper",
      "args": [],
      "env": {
        "BASECAMP_API_KEY": "your-api-token-here",
        "BASECAMP_ACCOUNT_ID": "your-account-id",
        "BASECAMP_USER_AGENT": "MFP Basecamp (you@example.com)"
      }
    }
  }
}
```

If you're **not** using a version manager and your default `ruby` is 3.1+, you can skip the wrapper and use `ruby` directly:

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
    tools/                           # 27 tool files, 146 tools total
      people.rb                      # 4 tools
      projects.rb                    # 5 tools
      templates.rb                   # 5 tools
      message_boards.rb              # 1 tool
      messages.rb                    # 7 tools
      message_types.rb               # 5 tools
      campfire.rb                    # 5 tools
      chatbots.rb                    # 6 tools
      todosets.rb                    # 1 tool
      todolists.rb                   # 5 tools
      todolist_groups.rb             # 4 tools
      todos.rb                       # 8 tools
      card_tables.rb                 # 19 tools
      documents.rb                   # 5 tools
      vaults.rb                      # 5 tools
      uploads.rb                     # 6 tools
      schedule.rb                    # 6 tools
      checkins.rb                    # 5 tools
      inbox.rb                       # 5 tools
      client_access.rb               # 9 tools
      comments.rb                    # 5 tools
      recordings.rb                  # 4 tools
      subscriptions.rb               # 4 tools
      events.rb                      # 2 tools
      lineup.rb                      # 4 tools
      timesheets.rb                  # 6 tools
      webhooks.rb                    # 5 tools
```

Tools are auto-discovered at startup. Adding a new domain means creating a file in `tools/` and adding its name to the `TOOL_FILES` array in `tools.rb`. No manual registration needed.

## Built With

- [MCP Ruby SDK](https://github.com/modelcontextprotocol/ruby-sdk) v0.7 -- Official Model Context Protocol implementation
- [Faraday](https://github.com/lostisland/faraday) v2 -- HTTP client with middleware
- [Basecamp 4 API](https://github.com/basecamp/bc3-api) -- The API we're wrapping

## License

MIT
