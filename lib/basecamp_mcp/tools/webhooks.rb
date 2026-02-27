# frozen_string_literal: true

module BasecampMcp
  module Tools
    class ListWebhooks < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "List all webhooks for a project."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" }
        },
        required: ["project_id"]
      )

      class << self
        def call(project_id:, server_context:)
          hooks = client(server_context:).get_all("buckets/#{project_id}/webhooks")
          text_response(hooks)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class GetWebhook < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Get a specific webhook."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          webhook_id: { type: "integer", description: "The webhook ID" }
        },
        required: %w[project_id webhook_id]
      )

      class << self
        def call(project_id:, webhook_id:, server_context:)
          hook = client(server_context:).get("buckets/#{project_id}/webhooks/#{webhook_id}")
          text_response(hook)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class CreateWebhook < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Create a new webhook for a project."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          payload_url: { type: "string", description: "URL to receive webhook payloads" },
          types: { type: "array", items: { type: "string" }, description: "Event types to subscribe to (e.g., Todo, Message)" }
        },
        required: %w[project_id payload_url]
      )

      class << self
        def call(project_id:, payload_url:, types: nil, server_context:)
          body = { payload_url: payload_url }
          body[:types] = types if types
          hook = client(server_context:).post("buckets/#{project_id}/webhooks", body)
          text_response(hook)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class UpdateWebhook < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Update a webhook's payload URL or event types."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          webhook_id: { type: "integer", description: "The webhook ID" },
          payload_url: { type: "string", description: "New payload URL" },
          types: { type: "array", items: { type: "string" }, description: "New event types" }
        },
        required: %w[project_id webhook_id]
      )

      class << self
        def call(project_id:, webhook_id:, payload_url: nil, types: nil, server_context:)
          body = {}
          body[:payload_url] = payload_url if payload_url
          body[:types] = types if types
          hook = client(server_context:).put("buckets/#{project_id}/webhooks/#{webhook_id}", body)
          text_response(hook)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class TrashWebhook < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Trash a webhook."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          webhook_id: { type: "integer", description: "The webhook ID" }
        },
        required: %w[project_id webhook_id]
      )

      class << self
        def call(project_id:, webhook_id:, server_context:)
          client(server_context:).delete("buckets/#{project_id}/webhooks/#{webhook_id}")
          text_response({ status: "trashed", webhook_id: webhook_id })
        rescue => e
          error_response(e.message)
        end
      end
    end
  end
end
