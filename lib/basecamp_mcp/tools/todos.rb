# frozen_string_literal: true

module BasecampMcp
  module Tools
    class ListTodos < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'List all to-dos in a to-do list. Supports filtering by completion status.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          todolist_id: { type: 'integer', description: 'The to-do list ID' },
          completed: { type: 'boolean', description: 'Filter: true=completed, false=incomplete. Omit for all.' },
          status: { type: 'string', enum: %w[active archived trashed],
                    description: 'Filter by status. Default: active' }
        },
        required: %w[project_id todolist_id]
      )

      class << self
        def call(project_id:, todolist_id:, server_context:, completed: nil, status: nil)
          params = {}
          params[:completed] = completed unless completed.nil?
          params[:status] = status if status
          todos = client(server_context:).get_all(
            "buckets/#{project_id}/todolists/#{todolist_id}/todos", params
          )
          todos.each { |t| t['description'] = HtmlUtils.strip_for_ai(t['description']) if t['description'] }
          text_response(todos)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class GetTodo < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get a specific to-do by ID, including description, assignees, due date, and completion status.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          todo_id: { type: 'integer', description: 'The to-do ID' }
        },
        required: %w[project_id todo_id]
      )

      class << self
        def call(project_id:, todo_id:, server_context:)
          todo = client(server_context:).get("buckets/#{project_id}/todos/#{todo_id}")
          todo['description'] = HtmlUtils.strip_for_ai(todo['description']) if todo['description']
          text_response(todo)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class CreateTodo < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Create a new to-do in a to-do list.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          todolist_id: { type: 'integer', description: 'The to-do list ID' },
          content: { type: 'string', description: 'The to-do title/content' },
          description: { type: 'string', description: 'Detailed description (supports HTML)' },
          assignee_ids: { type: 'array', items: { type: 'integer' }, description: 'People IDs to assign' },
          due_on: { type: 'string', description: 'Due date (YYYY-MM-DD)' },
          starts_on: { type: 'string', description: 'Start date (YYYY-MM-DD)' },
          notify: { type: 'boolean', description: 'Whether to notify assignees. Default: false' }
        },
        required: %w[project_id todolist_id content]
      )

      class << self
        def call(project_id:, todolist_id:, content:, server_context:, description: nil,
                 assignee_ids: nil, due_on: nil, starts_on: nil, notify: false)
          body = { content: content }
          body[:description] = description if description
          body[:assignee_ids] = assignee_ids if assignee_ids
          body[:due_on] = due_on if due_on
          body[:starts_on] = starts_on if starts_on
          body[:notify] = notify
          todo = client(server_context:).post(
            "buckets/#{project_id}/todolists/#{todolist_id}/todos", body
          )
          text_response(todo)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class UpdateTodo < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Update a to-do's content, description, assignees, or dates."

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          todo_id: { type: 'integer', description: 'The to-do ID' },
          content: { type: 'string', description: 'New title/content' },
          description: { type: 'string', description: 'New description (supports HTML)' },
          assignee_ids: { type: 'array', items: { type: 'integer' },
                          description: 'New assignee IDs (replaces existing)' },
          due_on: { type: 'string', description: 'New due date (YYYY-MM-DD) or empty to clear' },
          starts_on: { type: 'string', description: 'New start date (YYYY-MM-DD) or empty to clear' },
          notify: { type: 'boolean', description: 'Whether to notify assignees' }
        },
        required: %w[project_id todo_id]
      )

      class << self
        def call(project_id:, todo_id:, server_context:, content: nil, description: nil,
                 assignee_ids: nil, due_on: nil, starts_on: nil, notify: nil)
          body = {}
          body[:content] = content if content
          body[:description] = description if description
          body[:assignee_ids] = assignee_ids if assignee_ids
          body[:due_on] = due_on unless due_on.nil?
          body[:starts_on] = starts_on unless starts_on.nil?
          body[:notify] = notify unless notify.nil?
          todo = client(server_context:).put("buckets/#{project_id}/todos/#{todo_id}", body)
          text_response(todo)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class CompleteTodo < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Mark a to-do as complete.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          todo_id: { type: 'integer', description: 'The to-do ID' }
        },
        required: %w[project_id todo_id]
      )

      class << self
        def call(project_id:, todo_id:, server_context:)
          client(server_context:).post("buckets/#{project_id}/todos/#{todo_id}/completion")
          text_response({ status: 'completed', todo_id: todo_id })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class UncompleteTodo < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Mark a to-do as incomplete (uncomplete it).'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          todo_id: { type: 'integer', description: 'The to-do ID' }
        },
        required: %w[project_id todo_id]
      )

      class << self
        def call(project_id:, todo_id:, server_context:)
          client(server_context:).delete("buckets/#{project_id}/todos/#{todo_id}/completion")
          text_response({ status: 'uncompleted', todo_id: todo_id })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class RepositionTodo < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Change a to-do's position within its list."

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          todo_id: { type: 'integer', description: 'The to-do ID' },
          position: { type: 'integer', description: 'New position (1-based)' }
        },
        required: %w[project_id todo_id position]
      )

      class << self
        def call(project_id:, todo_id:, position:, server_context:)
          client(server_context:).put(
            "buckets/#{project_id}/todos/#{todo_id}/position", { position: position }
          )
          text_response({ status: 'repositioned', todo_id: todo_id, position: position })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class TrashTodo < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Move a to-do to the trash.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          todo_id: { type: 'integer', description: 'The to-do ID' }
        },
        required: %w[project_id todo_id]
      )

      class << self
        def call(project_id:, todo_id:, server_context:)
          client(server_context:).trash(project_id, todo_id)
          text_response({ status: 'trashed', todo_id: todo_id })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end
  end
end
