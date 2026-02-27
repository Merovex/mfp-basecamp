# frozen_string_literal: true

module BasecampMcp
  module Tools
    class GetCampfire < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get the campfire (chat room) for a project.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project ID' },
          campfire_id: { type: 'integer', description: 'The campfire ID (from project dock, name: chat)' }
        },
        required: %w[project_id campfire_id]
      )

      class << self
        def call(project_id:, campfire_id:, server_context:)
          campfire = client(server_context:).get("buckets/#{project_id}/chats/#{campfire_id}")
          text_response(campfire)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class ListCampfireLines < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'List chat lines in a campfire. Returns the most recent lines.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          campfire_id: { type: 'integer', description: 'The campfire ID' }
        },
        required: %w[project_id campfire_id]
      )

      class << self
        def call(project_id:, campfire_id:, server_context:)
          lines = client(server_context:).get_all(
            "buckets/#{project_id}/chats/#{campfire_id}/lines"
          )
          lines.each { |l| l['content'] = HtmlUtils.strip_for_ai(l['content']) if l['content'] }
          text_response(lines)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class GetCampfireLine < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get a specific campfire chat line.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          line_id: { type: 'integer', description: 'The chat line ID' }
        },
        required: %w[project_id line_id]
      )

      class << self
        def call(project_id:, line_id:, server_context:)
          line = client(server_context:).get("buckets/#{project_id}/chats/lines/#{line_id}")
          line['content'] = HtmlUtils.strip_for_ai(line['content']) if line['content']
          text_response(line)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class CreateCampfireLine < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Post a message to a campfire chat room.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          campfire_id: { type: 'integer', description: 'The campfire ID' },
          content: { type: 'string', description: 'Message content (supports HTML)' }
        },
        required: %w[project_id campfire_id content]
      )

      class << self
        def call(project_id:, campfire_id:, content:, server_context:)
          line = client(server_context:).post(
            "buckets/#{project_id}/chats/#{campfire_id}/lines", { content: content }
          )
          text_response(line)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class TrashCampfireLine < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Trash a campfire chat line.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          line_id: { type: 'integer', description: 'The chat line ID' }
        },
        required: %w[project_id line_id]
      )

      class << self
        def call(project_id:, line_id:, server_context:)
          client(server_context:).trash(project_id, line_id)
          text_response({ status: 'trashed', line_id: line_id })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end
  end
end
