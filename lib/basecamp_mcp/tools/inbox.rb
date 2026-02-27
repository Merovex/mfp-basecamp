# frozen_string_literal: true

module BasecampMcp
  module Tools
    class GetInbox < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Get the email inbox for a project."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project ID" },
          inbox_id: { type: "integer", description: "The inbox ID (from project dock)" }
        },
        required: %w[project_id inbox_id]
      )

      class << self
        def call(project_id:, inbox_id:, server_context:)
          inbox = client(server_context:).get("buckets/#{project_id}/inboxes/#{inbox_id}")
          text_response(inbox)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class ListInboxForwards < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "List forwarded emails in a project's inbox."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          inbox_id: { type: "integer", description: "The inbox ID" }
        },
        required: %w[project_id inbox_id]
      )

      class << self
        def call(project_id:, inbox_id:, server_context:)
          forwards = client(server_context:).get_all(
            "buckets/#{project_id}/inboxes/#{inbox_id}/forwards"
          )
          forwards.each { |f| f["content"] = HtmlUtils.strip_for_ai(f["content"]) if f["content"] }
          text_response(forwards)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class GetForward < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Get a specific forwarded email."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          forward_id: { type: "integer", description: "The forward ID" }
        },
        required: %w[project_id forward_id]
      )

      class << self
        def call(project_id:, forward_id:, server_context:)
          forward = client(server_context:).get("buckets/#{project_id}/inbox_forwards/#{forward_id}")
          forward["content"] = HtmlUtils.strip_for_ai(forward["content"]) if forward["content"]
          text_response(forward)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class ListInboxReplies < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "List replies to a forwarded email."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          forward_id: { type: "integer", description: "The forwarded email ID" }
        },
        required: %w[project_id forward_id]
      )

      class << self
        def call(project_id:, forward_id:, server_context:)
          replies = client(server_context:).get_all(
            "buckets/#{project_id}/inbox_forwards/#{forward_id}/replies"
          )
          replies.each { |r| r["content"] = HtmlUtils.strip_for_ai(r["content"]) if r["content"] }
          text_response(replies)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class GetInboxReply < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Get a specific reply to a forwarded email."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          reply_id: { type: "integer", description: "The reply ID" }
        },
        required: %w[project_id reply_id]
      )

      class << self
        def call(project_id:, reply_id:, server_context:)
          reply = client(server_context:).get("buckets/#{project_id}/inbox_forwards/replies/#{reply_id}")
          reply["content"] = HtmlUtils.strip_for_ai(reply["content"]) if reply["content"]
          text_response(reply)
        rescue => e
          error_response(e.message)
        end
      end
    end
  end
end
