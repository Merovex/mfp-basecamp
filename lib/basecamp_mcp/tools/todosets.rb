# frozen_string_literal: true

module BasecampMcp
  module Tools
    class GetTodoset < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Get the to-do set for a project. Returns the todoset ID needed for listing/creating to-do lists."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project ID" },
          todoset_id: { type: "integer", description: "The to-do set ID (from project dock)" }
        },
        required: %w[project_id todoset_id]
      )

      class << self
        def call(project_id:, todoset_id:, server_context:)
          todoset = client(server_context:).get("buckets/#{project_id}/todosets/#{todoset_id}")
          text_response(todoset)
        rescue => e
          error_response(e.message)
        end
      end
    end
  end
end
