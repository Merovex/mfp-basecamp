# frozen_string_literal: true

module BasecampMcp
  module Tools
    class GetInbox < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get the email inbox for a project.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project ID' },
          inbox_id: { type: 'integer', description: 'The inbox ID (from project dock)' }
        },
        required: %w[project_id inbox_id]
      )

      class << self
        def call(project_id:, inbox_id:, server_context:)
          inbox = client(server_context:).get("buckets/#{project_id}/inboxes/#{inbox_id}")
          text_response(inbox)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class ListInboxForwards < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "List forwarded emails in a project's inbox (paginated)."

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          inbox_id: { type: 'integer', description: 'The inbox ID' },
          page: { type: 'integer', description: 'Page number (default: 1)' }
        },
        required: %w[project_id inbox_id]
      )

      class << self
        def call(project_id:, inbox_id:, server_context:, page: 1)
          forwards, has_more = client(server_context:).get_page(
            "buckets/#{project_id}/inboxes/#{inbox_id}/forwards", {}, page: page
          )
          forwards.each { |f| f['content'] = HtmlUtils.strip_for_ai(f['content']) if f['content'] }
          paginated_list_response(forwards, page: page, has_more: has_more)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class GetForward < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get a specific forwarded email.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          forward_id: { type: 'integer', description: 'The forward ID' }
        },
        required: %w[project_id forward_id]
      )

      class << self
        def call(project_id:, forward_id:, server_context:)
          forward = client(server_context:).get("buckets/#{project_id}/inbox_forwards/#{forward_id}")
          forward['content'] = HtmlUtils.strip_for_ai(forward['content']) if forward['content']
          text_response(forward)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class ListInboxReplies < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'List replies to a forwarded email (paginated).'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          forward_id: { type: 'integer', description: 'The forwarded email ID' },
          page: { type: 'integer', description: 'Page number (default: 1)' }
        },
        required: %w[project_id forward_id]
      )

      class << self
        def call(project_id:, forward_id:, server_context:, page: 1)
          replies, has_more = client(server_context:).get_page(
            "buckets/#{project_id}/inbox_forwards/#{forward_id}/replies", {}, page: page
          )
          replies.each { |r| r['content'] = HtmlUtils.strip_for_ai(r['content']) if r['content'] }
          paginated_list_response(replies, page: page, has_more: has_more)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class GetInboxReply < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get a specific reply to a forwarded email.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          reply_id: { type: 'integer', description: 'The reply ID' }
        },
        required: %w[project_id reply_id]
      )

      class << self
        def call(project_id:, reply_id:, server_context:)
          reply = client(server_context:).get("buckets/#{project_id}/inbox_forwards/replies/#{reply_id}")
          reply['content'] = HtmlUtils.strip_for_ai(reply['content']) if reply['content']
          text_response(reply)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end
  end
end
