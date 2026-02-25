# Basecamp MCP Server: Full-Coverage Implementation Pitch

## The Problem

Every existing Basecamp MCP server is built in Python or Node.js. All of them are incomplete. The best one (georgeantonopoulos/Basecamp-MCP-Server) covers 64 tools but misses entire API surface areas like Card Tables, Client Visibility, Webhooks, and Lineup Markers. The Node.js "2026 Complete" version claims 100+ tools but is poorly documented and untested against real Basecamp 4 workspaces.

There is no Ruby or Rust implementation. The Ruby ecosystem now has a mature official MCP SDK (`mcp` gem, v0.6.0) and `fast-mcp` for rapid development. The Rust ecosystem has `mcp-sdk` crate support. Both languages are underserved despite being natural fits: Ruby because Basecamp is built by 37signals (a Ruby shop), and Rust because MCP sidecar binaries benefit from fast startup and zero runtime dependencies.

## The Opportunity

Build the first complete Basecamp 4 MCP server in Ruby or Rust that covers the entire documented API surface. Ship it as an open-source project. Position it as the reference implementation for Basecamp AI integration.

## Basecamp 4 API: Complete Endpoint Map

The Basecamp 4 API (documented at github.com/basecamp/bc3-api) exposes 37 endpoint groups. A complete MCP server needs tools for all of them. Below is the full surface organized by domain, with the MCP tools each group requires.

### Authentication & Identity

**People**
- `list_people` — Get all people on the account
- `get_person` — Get a specific person's details
- `get_my_profile` — Get the authenticated user's profile
- `list_pingable_people` — Get people who can be pinged

### Project Management

**Projects**
- `list_projects` — Get all projects (with status filter: active, archived, trashed)
- `get_project` — Get a specific project's details
- `create_project` — Create a new project
- `update_project` — Update project name, description, or tool configuration
- `trash_project` — Trash a project

**Templates**
- `list_templates` — Get all project templates
- `get_template` — Get a specific template
- `create_template` — Create a new template
- `update_template` — Update a template
- `trash_template` — Trash a template

### Messages & Communication

**Message Boards**
- `get_message_board` — Get the message board for a project

**Messages**
- `list_messages` — Get all messages in a project's message board
- `get_message` — Get a specific message
- `create_message` — Create a new message (with subject, content, category, subscriptions)
- `update_message` — Update an existing message
- `trash_message` — Trash a message
- `pin_message` — Pin a message
- `unpin_message` — Unpin a message

**Message Types**
- `list_message_types` — Get message categories for a project
- `get_message_type` — Get a specific message type
- `create_message_type` — Create a new message type
- `update_message_type` — Update a message type
- `trash_message_type` — Trash a message type

**Campfires (Chat)**
- `get_campfire` — Get the campfire for a project
- `list_campfire_lines` — Get chat lines in a campfire
- `get_campfire_line` — Get a specific chat line
- `create_campfire_line` — Post a message to the campfire
- `trash_campfire_line` — Trash a chat line

**Chatbots**
- `list_chatbots` — Get all chatbots for a campfire
- `get_chatbot` — Get a specific chatbot
- `create_chatbot` — Create a new chatbot
- `update_chatbot` — Update a chatbot
- `trash_chatbot` — Trash a chatbot
- `create_chatbot_line` — Post a message as a chatbot

### To-Dos

**To-Do Sets**
- `get_todoset` — Get the to-do set for a project

**To-Do Lists**
- `list_todolists` — Get all to-do lists in a project (with status filter)
- `get_todolist` — Get a specific to-do list
- `create_todolist` — Create a new to-do list
- `update_todolist` — Update a to-do list
- `trash_todolist` — Trash a to-do list

**To-Do List Groups**
- `list_todolist_groups` — Get groups within a to-do list
- `get_todolist_group` — Get a specific group
- `create_todolist_group` — Create a new group
- `reposition_todolist_group` — Change group position

**To-Dos**
- `list_todos` — Get all to-dos in a to-do list (with completed/status filters)
- `get_todo` — Get a specific to-do
- `create_todo` — Create a new to-do (content, description, assignees, due date, starts_on)
- `update_todo` — Update a to-do
- `complete_todo` — Mark a to-do as complete
- `uncomplete_todo` — Mark a to-do as incomplete
- `reposition_todo` — Change to-do position
- `trash_todo` — Trash a to-do

### Card Tables (Kanban)

**Card Tables**
- `get_card_table` — Get the card table for a project

**Card Table Columns**
- `list_card_table_columns` — Get all columns in a card table
- `get_card_table_column` — Get a specific column
- `create_card_table_column` — Create a new column
- `update_card_table_column` — Update a column
- `trash_card_table_column` — Trash a column

**Card Table Cards**
- `list_cards` — Get all cards in a column
- `get_card` — Get a specific card
- `create_card` — Create a new card (with assignees, due date)
- `update_card` — Update a card
- `move_card` — Move a card between columns
- `trash_card` — Trash a card

**Card Table Steps**
- `list_card_steps` — Get all steps (checklist items) on a card
- `get_card_step` — Get a specific step
- `create_card_step` — Create a new step
- `complete_card_step` — Complete a step
- `uncomplete_card_step` — Uncomplete a step
- `reposition_card_step` — Change step position
- `trash_card_step` — Trash a step

### Documents & Files

**Vaults (Folders)**
- `list_vaults` — Get all vaults in a project
- `get_vault` — Get a specific vault
- `create_vault` — Create a new vault (folder)
- `update_vault` — Update a vault
- `trash_vault` — Trash a vault

**Documents**
- `list_documents` — Get all documents in a vault
- `get_document` — Get a specific document
- `create_document` — Create a new document (title, content, status)
- `update_document` — Update a document
- `trash_document` — Trash a document

**Uploads (Files)**
- `list_uploads` — Get all uploads in a vault
- `get_upload` — Get a specific upload
- `create_upload` — Create a new upload (with attachable_sgid from attachment creation)
- `update_upload` — Update an upload's description
- `trash_upload` — Trash an upload

**Attachments**
- `create_attachment` — Create an attachment (returns attachable_sgid for use in uploads and rich text)

### Schedule

**Schedules**
- `get_schedule` — Get the schedule for a project

**Schedule Entries**
- `list_schedule_entries` — Get all entries in a project's schedule
- `get_schedule_entry` — Get a specific schedule entry
- `create_schedule_entry` — Create a new entry (summary, starts_at, ends_at, description, all_day, participants)
- `update_schedule_entry` — Update a schedule entry
- `trash_schedule_entry` — Trash a schedule entry

### Check-ins (Automatic Questions)

**Questionnaires**
- `get_questionnaire` — Get the questionnaire for a project

**Questions**
- `list_questions` — Get all automatic check-in questions
- `get_question` — Get a specific question

**Question Answers**
- `list_question_answers` — Get all answers to a question
- `get_question_answer` — Get a specific answer

### Email & Inbox

**Inboxes**
- `get_inbox` — Get the inbox for a project
- `list_inbox_forwards` — Get forwarded emails in the inbox

**Forwards**
- `get_forward` — Get a specific forwarded email

**Inbox Replies**
- `list_inbox_replies` — Get replies to a forwarded email
- `get_inbox_reply` — Get a specific reply

### Client Access

**Client Visibility**
- `list_client_visible_recordings` — Get all client-visible items in a project
- `toggle_client_visibility` — Toggle client visibility on a recording

**Client Approvals**
- `get_client_approval` — Get a client approval
- `list_client_approval_responses` — Get responses to an approval

**Client Correspondences**
- `list_client_correspondences` — Get all client correspondences
- `get_client_correspondence` — Get a specific correspondence
- `create_client_correspondence` — Create a new client correspondence

**Client Replies**
- `list_client_replies` — Get replies to a client correspondence
- `get_client_reply` — Get a specific reply

### Cross-Cutting Tools

**Comments**
- `list_comments` — Get all comments on a recording
- `get_comment` — Get a specific comment
- `create_comment` — Create a comment on any recording
- `update_comment` — Update a comment
- `trash_comment` — Trash a comment

**Recordings (Universal Operations)**
- `trash_recording` — Trash any recording (universal delete)
- `archive_recording` — Archive any recording
- `unarchive_recording` — Unarchive a recording
- `list_recordings` — Search/filter recordings by type, bucket, sort, status

**Subscriptions**
- `list_subscriptions` — Get subscribers for a recording
- `subscribe` — Subscribe people to a recording
- `unsubscribe` — Unsubscribe people from a recording
- `update_subscription` — Update the subscription

**Events (Activity Log)**
- `list_events` — Get events for a recording or entire project (the activity feed)
- `get_event` — Get a specific event

### Scheduling & Lineup

**Lineup Markers**
- `list_lineup_markers` — Get all lineup markers in a project
- `create_lineup_marker` — Create a lineup marker
- `update_lineup_marker` — Update a lineup marker
- `trash_lineup_marker` — Trash a lineup marker

### Timesheets

**Timesheets**
- `get_timesheet` — Get the timesheet for a project

**Time Entries** (if your account has time tracking enabled)
- `list_time_entries` — Get all time entries
- `get_time_entry` — Get a specific time entry
- `create_time_entry` — Log time
- `update_time_entry` — Update a time entry
- `trash_time_entry` — Trash a time entry

### Webhooks

**Webhooks**
- `list_webhooks` — Get all webhooks for a project
- `get_webhook` — Get a specific webhook
- `create_webhook` — Create a new webhook
- `update_webhook` — Update a webhook's payload URL or event types
- `trash_webhook` — Trash a webhook

### Rich Text Content

Not a separate endpoint group, but a critical implementation detail. Many Basecamp resources (messages, documents, comments, to-do descriptions) accept and return HTML-formatted rich text with Basecamp-specific attachment syntax (`<bc-attachment>` tags). The MCP server needs to handle rich text input and output cleanly, stripping or preserving HTML as appropriate for AI consumption.

## Tool Count Summary

| Domain | Tool Count |
|--------|-----------|
| People & Identity | 4 |
| Projects & Templates | 10 |
| Messages & Communication | 21 |
| To-Dos | 17 |
| Card Tables (Kanban) | 16 |
| Documents & Files | 14 |
| Schedule | 6 |
| Check-ins | 5 |
| Email & Inbox | 5 |
| Client Access | 9 |
| Comments | 5 |
| Recordings | 4 |
| Subscriptions | 4 |
| Events | 2 |
| Lineup Markers | 4 |
| Timesheets | 6 |
| Webhooks | 5 |
| **Total** | **~137** |

## Implementation Architecture

### Option A: Ruby (recommended for solo developer)

**Stack:**
- `mcp` gem (official Ruby SDK, v0.6.0) or `fast-mcp` gem
- `faraday` for HTTP client
- STDIO transport for Claude Desktop compatibility
- OAuth 2.0 token storage in `~/.basecamp-mcp/tokens.json`

**Why Ruby:**
- Basecamp is a Ruby shop; the API feels natural in Ruby
- Official MCP SDK is production-ready
- Fast enough for a STDIO sidecar process
- Familiar territory; no context-switching cost
- `fast-mcp` provides tool class inheritance pattern that maps cleanly to API resource groups

**Project structure:**
```
basecamp-mcp/
  lib/
    basecamp_mcp/
      client.rb           # Faraday-based Basecamp API client
      auth.rb             # OAuth 2.0 flow and token refresh
      tools/
        projects.rb       # Project tools
        messages.rb       # Message tools
        todos.rb          # To-do tools
        card_tables.rb    # Card table tools
        documents.rb      # Document/vault tools
        schedule.rb       # Schedule tools
        campfire.rb       # Chat tools
        comments.rb       # Comment tools
        recordings.rb     # Recording operations
        people.rb         # People tools
        webhooks.rb       # Webhook tools
        client_access.rb  # Client visibility/approvals
        checkins.rb       # Questionnaire/answers
        inbox.rb          # Email forwarding
        lineup.rb         # Lineup markers
        timesheets.rb     # Time tracking
        subscriptions.rb  # Subscription management
        events.rb         # Activity feed
      server.rb           # MCP server setup, tool registration
  bin/
    basecamp-mcp          # Entry point
  basecamp-mcp.gemspec
  Gemfile
```

### Option B: Rust (recommended for distribution as binary)

**Stack:**
- `mcp-sdk` crate
- `reqwest` for HTTP client
- STDIO transport
- Single static binary, no runtime dependencies

**Why Rust:**
- Ships as one binary; no Ruby/Python install required on user's machine
- Sub-millisecond startup for sidecar process
- Cross-compile for macOS (ARM + Intel), Windows, Linux
- Natural fit if bundling as a Verkilo sidecar later

**Tradeoff:** Higher development time per tool (Rust boilerplate vs. Ruby conciseness). For 137 tools, Ruby gets you to "done" 3-4x faster.

## Phased Delivery

### Phase 1: Core (week 1-2)
Auth, Projects, Messages, To-Dos, Comments, People. ~40 tools. Enough for the transcript-to-Basecamp workflow.

### Phase 2: Organization (week 3)
Documents, Vaults, Schedule, Card Tables. ~36 tools. Covers project management use cases.

### Phase 3: Communication (week 4)
Campfire, Chatbots, Check-ins, Inbox, Client Access. ~35 tools. Full communication coverage.

### Phase 4: Infrastructure (week 5)
Recordings, Subscriptions, Events, Lineup, Timesheets, Webhooks. ~26 tools. Completeness.

## Differentiation from Existing Servers

| Feature | mcp-basecamp (PyPI) | georgeantonopoulos | This project |
|---------|---------------------|-------------------|--------------|
| Language | Python | Python | Ruby |
| Tool count | ~15 | 64 | ~137 |
| Card Tables | No | No | Yes |
| Client Access | No | No | Yes |
| Webhooks | No | No | Yes |
| Lineup Markers | No | No | Yes |
| Timesheets | No | Partial | Yes |
| Rich text handling | Basic | Basic | Full |
| Pagination | No | Yes | Yes |
| Auth | Token only | OAuth 2.0 | OAuth 2.0 + token |
| Distribution | pip | git clone | gem install |

## Success Criteria

1. Every documented Basecamp 4 API endpoint has a corresponding MCP tool
2. OAuth 2.0 flow works without requiring the user to touch config files
3. Pagination is handled transparently (user asks for "all to-dos," gets all to-dos)
4. Rich text content is readable by AI without raw HTML noise
5. Rate limiting and error retry are built in from day one
6. Claude Desktop config generation is automated via setup command
7. Test suite covers auth flow, each tool group, and error cases
