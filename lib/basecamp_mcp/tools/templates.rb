# frozen_string_literal: true

module BasecampMcp
  module Tools
    class ListTemplates < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'List project templates (paginated).'

      input_schema(
        properties: {
          status: { type: 'string', enum: %w[active archived trashed], description: 'Filter by status' },
          page: { type: 'integer', description: 'Page number (default: 1)' }
        }
      )

      class << self
        def call(server_context:, status: nil, page: 1)
          params = {}
          params[:status] = status if status
          templates, has_more = client(server_context:).get_page('templates', params, page: page)
          paginated_list_response(templates, page: page, has_more: has_more)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class GetTemplate < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get a specific project template.'

      input_schema(
        properties: {
          template_id: { type: 'integer', description: 'The template ID' }
        },
        required: ['template_id']
      )

      class << self
        def call(template_id:, server_context:)
          template = client(server_context:).get("templates/#{template_id}")
          text_response(template)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class CreateTemplate < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Create a new project template.'

      input_schema(
        properties: {
          name: { type: 'string', description: 'Template name' },
          description: { type: 'string', description: 'Template description' }
        },
        required: ['name']
      )

      class << self
        def call(name:, server_context:, description: nil)
          body = { name: name }
          body[:description] = description if description
          template = client(server_context:).post('templates', body)
          text_response(template)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class UpdateTemplate < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Update a project template.'

      input_schema(
        properties: {
          template_id: { type: 'integer', description: 'The template ID' },
          name: { type: 'string', description: 'New template name' },
          description: { type: 'string', description: 'New description' }
        },
        required: ['template_id']
      )

      class << self
        def call(template_id:, server_context:, name: nil, description: nil)
          body = {}
          body[:name] = name if name
          body[:description] = description if description
          template = client(server_context:).put("templates/#{template_id}", body)
          text_response(template)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class TrashTemplate < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Trash a project template.'

      input_schema(
        properties: {
          template_id: { type: 'integer', description: 'The template ID' }
        },
        required: ['template_id']
      )

      class << self
        def call(template_id:, server_context:)
          client(server_context:).delete("templates/#{template_id}")
          text_response({ status: 'trashed', template_id: template_id })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end
  end
end
