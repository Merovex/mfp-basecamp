# frozen_string_literal: true

require 'uri'

module BasecampMcp
  module Tools
    class ListWebhooks < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'List webhooks for a project (paginated).'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          page: { type: 'integer', description: 'Page number (default: 1)' }
        },
        required: ['project_id']
      )

      class << self
        def call(project_id:, server_context:, page: 1)
          hooks, has_more = client(server_context:).get_page(
            "buckets/#{project_id}/webhooks", {}, page: page
          )
          paginated_list_response(hooks, page: page, has_more: has_more)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class GetWebhook < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get a specific webhook.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          webhook_id: { type: 'integer', description: 'The webhook ID' }
        },
        required: %w[project_id webhook_id]
      )

      class << self
        def call(project_id:, webhook_id:, server_context:)
          hook = client(server_context:).get("buckets/#{project_id}/webhooks/#{webhook_id}")
          text_response(hook)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class CreateWebhook < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Create a new webhook for a project. CAUTION: The payload_url will receive Basecamp event data — only use trusted, verified URLs.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          payload_url: { type: 'string', format: 'uri',
                         description: 'HTTPS URL to receive webhook payloads. Must be a trusted endpoint.' },
          types: { type: 'array', items: { type: 'string' },
                   description: 'Event types to subscribe to (e.g., Todo, Message)' }
        },
        required: %w[project_id payload_url]
      )

      class << self
        def call(project_id:, payload_url:, server_context:, types: nil)
          uri = URI.parse(payload_url)
          return error_response('payload_url must be an HTTPS URL') unless uri.is_a?(URI::HTTPS)

          body = { payload_url: payload_url }
          body[:types] = types if types
          hook = client(server_context:).post("buckets/#{project_id}/webhooks", body)
          text_response(hook)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class UpdateWebhook < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Update a webhook's payload URL or event types. CAUTION: The payload_url will receive Basecamp event data — only use trusted, verified URLs."

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          webhook_id: { type: 'integer', description: 'The webhook ID' },
          payload_url: { type: 'string', format: 'uri',
                         description: 'HTTPS URL to receive webhook payloads. Must be a trusted endpoint.' },
          types: { type: 'array', items: { type: 'string' }, description: 'New event types' }
        },
        required: %w[project_id webhook_id]
      )

      class << self
        def call(project_id:, webhook_id:, server_context:, payload_url: nil, types: nil)
          if payload_url
            uri = URI.parse(payload_url)
            return error_response('payload_url must be an HTTPS URL') unless uri.is_a?(URI::HTTPS)
          end

          body = {}
          body[:payload_url] = payload_url if payload_url
          body[:types] = types if types
          hook = client(server_context:).put("buckets/#{project_id}/webhooks/#{webhook_id}", body)
          text_response(hook)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class TrashWebhook < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Trash a webhook.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          webhook_id: { type: 'integer', description: 'The webhook ID' }
        },
        required: %w[project_id webhook_id]
      )

      class << self
        def call(project_id:, webhook_id:, server_context:)
          client(server_context:).delete("buckets/#{project_id}/webhooks/#{webhook_id}")
          text_response({ status: 'trashed', webhook_id: webhook_id })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end
  end
end
