# frozen_string_literal: true

module BasecampMcp
  module Tools
    class ListTodolistGroups < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'List groups within a to-do list (paginated).'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          todolist_id: { type: 'integer', description: 'The to-do list ID' },
          page: { type: 'integer', description: 'Page number (default: 1)' }
        },
        required: %w[project_id todolist_id]
      )

      class << self
        def call(project_id:, todolist_id:, server_context:, page: 1)
          groups, has_more = client(server_context:).get_page(
            "buckets/#{project_id}/todolists/#{todolist_id}/groups", {}, page: page
          )
          paginated_list_response(groups, page: page, has_more: has_more)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class GetTodolistGroup < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get a specific to-do list group.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          group_id: { type: 'integer', description: 'The group ID' }
        },
        required: %w[project_id group_id]
      )

      class << self
        def call(project_id:, group_id:, server_context:)
          group = client(server_context:).get("buckets/#{project_id}/todolists/#{group_id}")
          text_response(group)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class CreateTodolistGroup < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Create a new group within a to-do list.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          todolist_id: { type: 'integer', description: 'The to-do list ID' },
          name: { type: 'string', description: 'Group name' }
        },
        required: %w[project_id todolist_id name]
      )

      class << self
        def call(project_id:, todolist_id:, name:, server_context:)
          group = client(server_context:).post(
            "buckets/#{project_id}/todolists/#{todolist_id}/groups", { name: name }
          )
          text_response(group)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class RepositionTodolistGroup < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Change a to-do list group's position."

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          group_id: { type: 'integer', description: 'The group ID' },
          position: { type: 'integer', description: 'New position (1-based)' }
        },
        required: %w[project_id group_id position]
      )

      class << self
        def call(project_id:, group_id:, position:, server_context:)
          client(server_context:).put(
            "buckets/#{project_id}/todolists/#{group_id}/position", { position: position }
          )
          text_response({ status: 'repositioned', group_id: group_id, position: position })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end
  end
end
