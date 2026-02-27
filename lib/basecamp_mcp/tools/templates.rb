# frozen_string_literal: true

module BasecampMcp
  module Tools
    class ListTemplates < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "List all project templates."

      input_schema(
        properties: {
          status: { type: "string", enum: %w[active archived trashed], description: "Filter by status" }
        }
      )

      class << self
        def call(status: nil, server_context:)
          params = {}
          params[:status] = status if status
          templates = client(server_context:).get_all("templates", params)
          text_response(templates)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class GetTemplate < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Get a specific project template."

      input_schema(
        properties: {
          template_id: { type: "integer", description: "The template ID" }
        },
        required: ["template_id"]
      )

      class << self
        def call(template_id:, server_context:)
          template = client(server_context:).get("templates/#{template_id}")
          text_response(template)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class CreateTemplate < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Create a new project template."

      input_schema(
        properties: {
          name: { type: "string", description: "Template name" },
          description: { type: "string", description: "Template description" }
        },
        required: ["name"]
      )

      class << self
        def call(name:, description: nil, server_context:)
          body = { name: name }
          body[:description] = description if description
          template = client(server_context:).post("templates", body)
          text_response(template)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class UpdateTemplate < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Update a project template."

      input_schema(
        properties: {
          template_id: { type: "integer", description: "The template ID" },
          name: { type: "string", description: "New template name" },
          description: { type: "string", description: "New description" }
        },
        required: ["template_id"]
      )

      class << self
        def call(template_id:, name: nil, description: nil, server_context:)
          body = {}
          body[:name] = name if name
          body[:description] = description if description
          template = client(server_context:).put("templates/#{template_id}", body)
          text_response(template)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class TrashTemplate < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Trash a project template."

      input_schema(
        properties: {
          template_id: { type: "integer", description: "The template ID" }
        },
        required: ["template_id"]
      )

      class << self
        def call(template_id:, server_context:)
          client(server_context:).delete("templates/#{template_id}")
          text_response({ status: "trashed", template_id: template_id })
        rescue => e
          error_response(e.message)
        end
      end
    end
  end
end
