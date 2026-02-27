# frozen_string_literal: true

module BasecampMcp
  module Tools
    class ListClientVisibleRecordings < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'List all client-visible items in a project.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' }
        },
        required: ['project_id']
      )

      class << self
        def call(project_id:, server_context:)
          recordings = client(server_context:).get_all(
            "buckets/#{project_id}/client/recordings"
          )
          text_response(recordings)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class ToggleClientVisibility < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Toggle client visibility on a recording. Makes it visible or hidden to clients.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          recording_id: { type: 'integer', description: 'The recording ID' },
          visible: { type: 'boolean', description: 'true to make visible to clients, false to hide' }
        },
        required: %w[project_id recording_id visible]
      )

      class << self
        def call(project_id:, recording_id:, visible:, server_context:)
          if visible
            client(server_context:).post(
              "buckets/#{project_id}/recordings/#{recording_id}/client_visibility"
            )
          else
            client(server_context:).delete(
              "buckets/#{project_id}/recordings/#{recording_id}/client_visibility"
            )
          end
          text_response({ status: visible ? 'visible' : 'hidden', recording_id: recording_id })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class GetClientApproval < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get a client approval.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          approval_id: { type: 'integer', description: 'The client approval ID' }
        },
        required: %w[project_id approval_id]
      )

      class << self
        def call(project_id:, approval_id:, server_context:)
          approval = client(server_context:).get(
            "buckets/#{project_id}/client/approvals/#{approval_id}"
          )
          text_response(approval)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class ListClientApprovalResponses < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'List responses to a client approval.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          approval_id: { type: 'integer', description: 'The client approval ID' }
        },
        required: %w[project_id approval_id]
      )

      class << self
        def call(project_id:, approval_id:, server_context:)
          responses = client(server_context:).get_all(
            "buckets/#{project_id}/client/approvals/#{approval_id}/responses"
          )
          text_response(responses)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class ListClientCorrespondences < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'List all client correspondences in a project.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' }
        },
        required: ['project_id']
      )

      class << self
        def call(project_id:, server_context:)
          correspondences = client(server_context:).get_all(
            "buckets/#{project_id}/client/correspondences"
          )
          correspondences.each { |c| c['content'] = HtmlUtils.strip_for_ai(c['content']) if c['content'] }
          text_response(correspondences)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class GetClientCorrespondence < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get a specific client correspondence.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          correspondence_id: { type: 'integer', description: 'The correspondence ID' }
        },
        required: %w[project_id correspondence_id]
      )

      class << self
        def call(project_id:, correspondence_id:, server_context:)
          corr = client(server_context:).get(
            "buckets/#{project_id}/client/correspondences/#{correspondence_id}"
          )
          corr['content'] = HtmlUtils.strip_for_ai(corr['content']) if corr['content']
          text_response(corr)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class CreateClientCorrespondence < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Create a new client correspondence.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          subject: { type: 'string', description: 'Correspondence subject' },
          content: { type: 'string', description: 'Correspondence body (supports HTML)' }
        },
        required: %w[project_id subject content]
      )

      class << self
        def call(project_id:, subject:, content:, server_context:)
          corr = client(server_context:).post(
            "buckets/#{project_id}/client/correspondences",
            { subject: subject, content: content }
          )
          text_response(corr)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class ListClientReplies < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'List replies to a client correspondence.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          correspondence_id: { type: 'integer', description: 'The correspondence ID' }
        },
        required: %w[project_id correspondence_id]
      )

      class << self
        def call(project_id:, correspondence_id:, server_context:)
          replies = client(server_context:).get_all(
            "buckets/#{project_id}/client/correspondences/#{correspondence_id}/replies"
          )
          replies.each { |r| r['content'] = HtmlUtils.strip_for_ai(r['content']) if r['content'] }
          text_response(replies)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class GetClientReply < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get a specific reply to a client correspondence.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          reply_id: { type: 'integer', description: 'The reply ID' }
        },
        required: %w[project_id reply_id]
      )

      class << self
        def call(project_id:, reply_id:, server_context:)
          reply = client(server_context:).get("buckets/#{project_id}/client/replies/#{reply_id}")
          reply['content'] = HtmlUtils.strip_for_ai(reply['content']) if reply['content']
          text_response(reply)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end
  end
end
