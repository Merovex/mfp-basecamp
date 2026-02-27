# frozen_string_literal: true

module BasecampMcp
  module Tools
    class ListEvents < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "List events (activity log) for a recording or entire project."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          recording_id: { type: "integer", description: "Optional: recording ID to scope events to a specific item" }
        },
        required: ["project_id"]
      )

      class << self
        def call(project_id:, recording_id: nil, server_context:)
          path = if recording_id
            "buckets/#{project_id}/recordings/#{recording_id}/events"
          else
            "buckets/#{project_id}/events"
          end
          events = client(server_context:).get_all(path)
          text_response(events)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class GetEvent < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Get a specific event from the activity log."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          event_id: { type: "integer", description: "The event ID" }
        },
        required: %w[project_id event_id]
      )

      class << self
        def call(project_id:, event_id:, server_context:)
          event = client(server_context:).get("buckets/#{project_id}/events/#{event_id}")
          text_response(event)
        rescue => e
          error_response(e.message)
        end
      end
    end
  end
end
