# frozen_string_literal: true

module BasecampMcp
  module Tools
    class ListEvents < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'List events (activity log) for a recording or entire project (paginated).'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          recording_id: { type: 'integer', description: 'Optional: recording ID to scope events to a specific item' },
          page: { type: 'integer', description: 'Page number (default: 1)' }
        },
        required: ['project_id']
      )

      class << self
        def call(project_id:, server_context:, recording_id: nil, page: 1)
          path = if recording_id
                   "buckets/#{project_id}/recordings/#{recording_id}/events"
                 else
                   "buckets/#{project_id}/events"
                 end
          events, has_more = client(server_context:).get_page(path, {}, page: page)
          paginated_list_response(events, page: page, has_more: has_more)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class GetEvent < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get a specific event from the activity log.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          event_id: { type: 'integer', description: 'The event ID' }
        },
        required: %w[project_id event_id]
      )

      class << self
        def call(project_id:, event_id:, server_context:)
          event = client(server_context:).get("buckets/#{project_id}/events/#{event_id}")
          text_response(event)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end
  end
end
