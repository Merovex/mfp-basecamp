# frozen_string_literal: true

module BasecampMcp
  module Tools
    class ListComments < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'List comments on any Basecamp recording (paginated).'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          recording_id: { type: 'integer', description: 'The recording ID (message, to-do, etc.)' },
          page: { type: 'integer', description: 'Page number (default: 1)' }
        },
        required: %w[project_id recording_id]
      )

      class << self
        def call(project_id:, recording_id:, server_context:, page: 1)
          comments, has_more = client(server_context:).get_page(
            "buckets/#{project_id}/recordings/#{recording_id}/comments", {}, page: page
          )
          comments.each { |c| c['content'] = HtmlUtils.strip_for_ai(c['content']) if c['content'] }
          paginated_list_response(comments, page: page, has_more: has_more)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class GetComment < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get a specific comment by ID.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          comment_id: { type: 'integer', description: 'The comment ID' }
        },
        required: %w[project_id comment_id]
      )

      class << self
        def call(project_id:, comment_id:, server_context:)
          comment = client(server_context:).get("buckets/#{project_id}/comments/#{comment_id}")
          comment['content'] = HtmlUtils.strip_for_ai(comment['content']) if comment['content']
          text_response(comment)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class CreateComment < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Add a comment to any Basecamp recording (message, to-do, document, etc.).'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          recording_id: { type: 'integer', description: 'The recording ID to comment on' },
          content: { type: 'string', description: 'Comment body (supports HTML)' }
        },
        required: %w[project_id recording_id content]
      )

      class << self
        def call(project_id:, recording_id:, content:, server_context:)
          comment = client(server_context:).post(
            "buckets/#{project_id}/recordings/#{recording_id}/comments", { content: content }
          )
          text_response(comment)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class UpdateComment < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Update an existing comment's content."

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          comment_id: { type: 'integer', description: 'The comment ID' },
          content: { type: 'string', description: 'New comment content (supports HTML)' }
        },
        required: %w[project_id comment_id content]
      )

      class << self
        def call(project_id:, comment_id:, content:, server_context:)
          comment = client(server_context:).put(
            "buckets/#{project_id}/comments/#{comment_id}", { content: content }
          )
          text_response(comment)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class TrashComment < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Move a comment to the trash.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          comment_id: { type: 'integer', description: 'The comment ID' }
        },
        required: %w[project_id comment_id]
      )

      class << self
        def call(project_id:, comment_id:, server_context:)
          client(server_context:).trash(project_id, comment_id)
          text_response({ status: 'trashed', comment_id: comment_id })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end
  end
end
