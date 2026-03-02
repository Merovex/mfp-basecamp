# frozen_string_literal: true

module BasecampMcp
  module Tools
    class ListRecordings < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Search and filter recordings across projects (paginated). Can filter by type, bucket, sort, and status.'

      input_schema(
        properties: {
          type: { type: 'string',
                  description: 'Recording type (e.g., Todo, Message, Upload, Document, Question::Answer)' },
          bucket: { type: 'integer', description: 'Filter by project (bucket) ID' },
          sort: { type: 'string', enum: %w[created_at updated_at], description: 'Sort field' },
          direction: { type: 'string', enum: %w[asc desc], description: 'Sort direction' },
          status: { type: 'string', enum: %w[active archived trashed], description: 'Filter by status' },
          page: { type: 'integer', description: 'Page number (default: 1)' }
        },
        required: ['type']
      )

      class << self
        def call(type:, server_context:, bucket: nil, sort: nil, direction: nil, status: nil, page: 1)
          params = { type: type }
          params[:bucket] = bucket if bucket
          params[:sort] = sort if sort
          params[:direction] = direction if direction
          params[:status] = status if status
          recordings, has_more = client(server_context:).get_page('projects/recordings', params, page: page)
          paginated_list_response(recordings, page: page, has_more: has_more)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class TrashRecording < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Trash any recording (universal delete for any content type).'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          recording_id: { type: 'integer', description: 'The recording ID' }
        },
        required: %w[project_id recording_id]
      )

      class << self
        def call(project_id:, recording_id:, server_context:)
          client(server_context:).trash(project_id, recording_id)
          text_response({ status: 'trashed', recording_id: recording_id })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class ArchiveRecording < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Archive any recording.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          recording_id: { type: 'integer', description: 'The recording ID' }
        },
        required: %w[project_id recording_id]
      )

      class << self
        def call(project_id:, recording_id:, server_context:)
          client(server_context:).put(
            "buckets/#{project_id}/recordings/#{recording_id}/status/archived"
          )
          text_response({ status: 'archived', recording_id: recording_id })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class UnarchiveRecording < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Unarchive a recording (set it back to active).'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          recording_id: { type: 'integer', description: 'The recording ID' }
        },
        required: %w[project_id recording_id]
      )

      class << self
        def call(project_id:, recording_id:, server_context:)
          client(server_context:).put(
            "buckets/#{project_id}/recordings/#{recording_id}/status/active"
          )
          text_response({ status: 'active', recording_id: recording_id })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end
  end
end
