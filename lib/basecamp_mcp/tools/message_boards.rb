# frozen_string_literal: true

module BasecampMcp
  module Tools
    class GetMessageBoard < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get the message board for a project. Returns the board ID needed for listing/creating messages.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project ID' },
          message_board_id: { type: 'integer', description: 'The message board ID (from project dock)' }
        },
        required: %w[project_id message_board_id]
      )

      class << self
        def call(project_id:, message_board_id:, server_context:)
          board = client(server_context:).get("buckets/#{project_id}/message_boards/#{message_board_id}")
          text_response(board)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end
  end
end
