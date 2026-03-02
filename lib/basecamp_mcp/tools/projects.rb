# frozen_string_literal: true

module BasecampMcp
  module Tools
    class ListProjects < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'List projects (paginated). Supports filtering by status (active, archived, trashed).'

      input_schema(
        properties: {
          status: { type: 'string', enum: %w[active archived trashed],
                    description: 'Filter by status. Default: active' },
          page: { type: 'integer', description: 'Page number (default: 1)' }
        }
      )

      class << self
        def call(server_context:, status: nil, page: 1)
          params = {}
          params[:status] = status if status
          projects, has_more = client(server_context:).get_page('projects', params, page: page)
          paginated_list_response(projects, page: page, has_more: has_more)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class GetProject < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Get a specific project's details including its dock (available tools)."

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project ID' }
        },
        required: ['project_id']
      )

      class << self
        def call(project_id:, server_context:)
          project = client(server_context:).get("projects/#{project_id}")
          text_response(project)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class CreateProject < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Create a new project.'

      input_schema(
        properties: {
          name: { type: 'string', description: 'Project name' },
          description: { type: 'string', description: 'Project description' }
        },
        required: ['name']
      )

      class << self
        def call(name:, server_context:, description: nil)
          body = { name: name }
          body[:description] = description if description
          project = client(server_context:).post('projects', body)
          text_response(project)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class UpdateProject < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Update a project's name, description, or admissions setting."

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project ID' },
          name: { type: 'string', description: 'New project name' },
          description: { type: 'string', description: 'New project description' }
        },
        required: ['project_id']
      )

      class << self
        def call(project_id:, server_context:, name: nil, description: nil)
          body = {}
          body[:name] = name if name
          body[:description] = description if description
          project = client(server_context:).put("projects/#{project_id}", body)
          text_response(project)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class TrashProject < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Move a project to the trash.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project ID to trash' }
        },
        required: ['project_id']
      )

      class << self
        def call(project_id:, server_context:)
          client(server_context:).delete("projects/#{project_id}")
          text_response({ status: 'trashed', project_id: project_id })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end
  end
end
