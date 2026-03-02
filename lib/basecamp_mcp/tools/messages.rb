# frozen_string_literal: true

module BasecampMcp
  module Tools
    class ListMessages < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "List messages in a project's message board (paginated)."

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          message_board_id: { type: 'integer', description: 'The message board ID' },
          page: { type: 'integer', description: 'Page number (default: 1)' }
        },
        required: %w[project_id message_board_id]
      )

      class << self
        def call(project_id:, message_board_id:, server_context:, page: 1)
          messages, has_more = client(server_context:).get_page(
            "buckets/#{project_id}/message_boards/#{message_board_id}/messages", {}, page: page
          )
          messages.each { |m| m['content'] = HtmlUtils.strip_for_ai(m['content']) if m['content'] }
          paginated_list_response(messages, page: page, has_more: has_more)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class GetMessage < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get a specific message by ID.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          message_id: { type: 'integer', description: 'The message ID' }
        },
        required: %w[project_id message_id]
      )

      class << self
        def call(project_id:, message_id:, server_context:)
          message = client(server_context:).get("buckets/#{project_id}/messages/#{message_id}")
          message['content'] = HtmlUtils.strip_for_ai(message['content']) if message['content']
          text_response(message)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class CreateMessage < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Create a new message in a project's message board."

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          message_board_id: { type: 'integer', description: 'The message board ID' },
          subject: { type: 'string', description: 'Message subject/title' },
          content: { type: 'string', description: 'Message body (supports HTML)' },
          category_id: { type: 'integer', description: 'Message type/category ID' }
        },
        required: %w[project_id message_board_id subject]
      )

      class << self
        def call(project_id:, message_board_id:, subject:, server_context:, content: nil, category_id: nil)
          body = { subject: subject }
          body[:content] = content if content
          body[:category_id] = category_id if category_id
          message = client(server_context:).post(
            "buckets/#{project_id}/message_boards/#{message_board_id}/messages", body
          )
          text_response(message)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class UpdateMessage < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Update an existing message's subject, content, or category."

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          message_id: { type: 'integer', description: 'The message ID' },
          subject: { type: 'string', description: 'New subject' },
          content: { type: 'string', description: 'New content (supports HTML)' },
          category_id: { type: 'integer', description: 'New category ID' }
        },
        required: %w[project_id message_id]
      )

      class << self
        def call(project_id:, message_id:, server_context:, subject: nil, content: nil, category_id: nil)
          body = {}
          body[:subject] = subject if subject
          body[:content] = content if content
          body[:category_id] = category_id if category_id
          message = client(server_context:).put("buckets/#{project_id}/messages/#{message_id}", body)
          text_response(message)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class TrashMessage < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Move a message to the trash.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          message_id: { type: 'integer', description: 'The message ID' }
        },
        required: %w[project_id message_id]
      )

      class << self
        def call(project_id:, message_id:, server_context:)
          client(server_context:).trash(project_id, message_id)
          text_response({ status: 'trashed', message_id: message_id })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class PinMessage < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Pin a message so it appears at the top of the message board.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          message_id: { type: 'integer', description: 'The message ID' }
        },
        required: %w[project_id message_id]
      )

      class << self
        def call(project_id:, message_id:, server_context:)
          client(server_context:).post("buckets/#{project_id}/recordings/#{message_id}/pin")
          text_response({ status: 'pinned', message_id: message_id })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class UnpinMessage < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Unpin a message from the top of the message board.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          message_id: { type: 'integer', description: 'The message ID' }
        },
        required: %w[project_id message_id]
      )

      class << self
        def call(project_id:, message_id:, server_context:)
          client(server_context:).delete("buckets/#{project_id}/recordings/#{message_id}/pin")
          text_response({ status: 'unpinned', message_id: message_id })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end
  end
end
