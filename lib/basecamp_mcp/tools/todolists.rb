# frozen_string_literal: true

module BasecampMcp
  module Tools
    class ListTodolists < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "List all to-do lists in a project's to-do set."

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          todoset_id: { type: 'integer', description: 'The to-do set ID' },
          status: { type: 'string', enum: %w[active archived trashed],
                    description: 'Filter by status. Default: active' }
        },
        required: %w[project_id todoset_id]
      )

      class << self
        def call(project_id:, todoset_id:, server_context:, status: nil)
          params = {}
          params[:status] = status if status
          lists = client(server_context:).get_all(
            "buckets/#{project_id}/todosets/#{todoset_id}/todolists", params
          )
          text_response(lists)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class GetTodolist < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get a specific to-do list by ID.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          todolist_id: { type: 'integer', description: 'The to-do list ID' }
        },
        required: %w[project_id todolist_id]
      )

      class << self
        def call(project_id:, todolist_id:, server_context:)
          list = client(server_context:).get("buckets/#{project_id}/todolists/#{todolist_id}")
          list['description'] = HtmlUtils.strip_for_ai(list['description']) if list['description']
          text_response(list)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class CreateTodolist < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Create a new to-do list in a project's to-do set."

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          todoset_id: { type: 'integer', description: 'The to-do set ID' },
          name: { type: 'string', description: 'To-do list name' },
          description: { type: 'string', description: 'Description (supports HTML)' }
        },
        required: %w[project_id todoset_id name]
      )

      class << self
        def call(project_id:, todoset_id:, name:, server_context:, description: nil)
          body = { name: name }
          body[:description] = description if description
          list = client(server_context:).post(
            "buckets/#{project_id}/todosets/#{todoset_id}/todolists", body
          )
          text_response(list)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class UpdateTodolist < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Update a to-do list's name or description."

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          todolist_id: { type: 'integer', description: 'The to-do list ID' },
          name: { type: 'string', description: 'New name' },
          description: { type: 'string', description: 'New description (supports HTML)' }
        },
        required: %w[project_id todolist_id]
      )

      class << self
        def call(project_id:, todolist_id:, server_context:, name: nil, description: nil)
          body = {}
          body[:name] = name if name
          body[:description] = description if description
          list = client(server_context:).put("buckets/#{project_id}/todolists/#{todolist_id}", body)
          text_response(list)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class TrashTodolist < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Move a to-do list to the trash.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          todolist_id: { type: 'integer', description: 'The to-do list ID' }
        },
        required: %w[project_id todolist_id]
      )

      class << self
        def call(project_id:, todolist_id:, server_context:)
          client(server_context:).trash(project_id, todolist_id)
          text_response({ status: 'trashed', todolist_id: todolist_id })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end
  end
end
