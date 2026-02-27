# frozen_string_literal: true

module BasecampMcp
  module Tools
    class ListSubscriptions < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "List all subscribers for a recording."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          recording_id: { type: "integer", description: "The recording ID" }
        },
        required: %w[project_id recording_id]
      )

      class << self
        def call(project_id:, recording_id:, server_context:)
          subs = client(server_context:).get(
            "buckets/#{project_id}/recordings/#{recording_id}/subscription"
          )
          text_response(subs)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class Subscribe < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Subscribe people to a recording's notifications."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          recording_id: { type: "integer", description: "The recording ID" },
          subscriptions: { type: "array", items: { type: "integer" }, description: "People IDs to subscribe" }
        },
        required: %w[project_id recording_id subscriptions]
      )

      class << self
        def call(project_id:, recording_id:, subscriptions:, server_context:)
          result = client(server_context:).post(
            "buckets/#{project_id}/recordings/#{recording_id}/subscription",
            { subscriptions: subscriptions }
          )
          text_response(result)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class Unsubscribe < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Unsubscribe people from a recording's notifications."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          recording_id: { type: "integer", description: "The recording ID" },
          subscriptions: { type: "array", items: { type: "integer" }, description: "People IDs to unsubscribe" }
        },
        required: %w[project_id recording_id subscriptions]
      )

      class << self
        def call(project_id:, recording_id:, subscriptions:, server_context:)
          result = client(server_context:).put(
            "buckets/#{project_id}/recordings/#{recording_id}/subscription",
            { subscriptions: subscriptions }
          )
          text_response(result)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class UpdateSubscription < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Update subscription (subscribe yourself to a recording)."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          recording_id: { type: "integer", description: "The recording ID" }
        },
        required: %w[project_id recording_id]
      )

      class << self
        def call(project_id:, recording_id:, server_context:)
          result = client(server_context:).put(
            "buckets/#{project_id}/recordings/#{recording_id}/subscription"
          )
          text_response(result)
        rescue => e
          error_response(e.message)
        end
      end
    end
  end
end
