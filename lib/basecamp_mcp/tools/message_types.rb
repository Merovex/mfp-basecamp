# frozen_string_literal: true

module BasecampMcp
  module Tools
    class ListMessageTypes < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'List all message categories/types for a project.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' }
        },
        required: ['project_id']
      )

      class << self
        def call(project_id:, server_context:)
          types = client(server_context:).get_all("buckets/#{project_id}/categories")
          text_response(types)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class GetMessageType < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get a specific message category/type.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          category_id: { type: 'integer', description: 'The category ID' }
        },
        required: %w[project_id category_id]
      )

      class << self
        def call(project_id:, category_id:, server_context:)
          type = client(server_context:).get("buckets/#{project_id}/categories/#{category_id}")
          text_response(type)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class CreateMessageType < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Create a new message category/type for a project.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          name: { type: 'string', description: 'Category name' },
          icon: { type: 'string', description: 'Emoji icon for the category' }
        },
        required: %w[project_id name]
      )

      class << self
        def call(project_id:, name:, server_context:, icon: nil)
          body = { name: name }
          body[:icon] = icon if icon
          type = client(server_context:).post("buckets/#{project_id}/categories", body)
          text_response(type)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class UpdateMessageType < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Update a message category/type's name or icon."

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          category_id: { type: 'integer', description: 'The category ID' },
          name: { type: 'string', description: 'New category name' },
          icon: { type: 'string', description: 'New emoji icon' }
        },
        required: %w[project_id category_id]
      )

      class << self
        def call(project_id:, category_id:, server_context:, name: nil, icon: nil)
          body = {}
          body[:name] = name if name
          body[:icon] = icon if icon
          type = client(server_context:).put("buckets/#{project_id}/categories/#{category_id}", body)
          text_response(type)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class TrashMessageType < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Trash a message category/type.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          category_id: { type: 'integer', description: 'The category ID' }
        },
        required: %w[project_id category_id]
      )

      class << self
        def call(project_id:, category_id:, server_context:)
          client(server_context:).delete("buckets/#{project_id}/categories/#{category_id}")
          text_response({ status: 'trashed', category_id: category_id })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end
  end
end
