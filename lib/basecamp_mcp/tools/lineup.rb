# frozen_string_literal: true

module BasecampMcp
  module Tools
    class ListLineupMarkers < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'List lineup markers in a project (paginated).'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          page: { type: 'integer', description: 'Page number (default: 1)' }
        },
        required: ['project_id']
      )

      class << self
        def call(project_id:, server_context:, page: 1)
          markers, has_more = client(server_context:).get_page(
            "buckets/#{project_id}/lineup_markers", {}, page: page
          )
          paginated_list_response(markers, page: page, has_more: has_more)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class CreateLineupMarker < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Create a lineup marker in a project.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          starts_on: { type: 'string', description: 'Start date (YYYY-MM-DD)' },
          ends_on: { type: 'string', description: 'End date (YYYY-MM-DD)' },
          color: { type: 'string', description: 'Marker color' }
        },
        required: %w[project_id starts_on ends_on]
      )

      class << self
        def call(project_id:, starts_on:, ends_on:, server_context:, color: nil)
          body = { starts_on: starts_on, ends_on: ends_on }
          body[:color] = color if color
          marker = client(server_context:).post("buckets/#{project_id}/lineup_markers", body)
          text_response(marker)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class UpdateLineupMarker < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Update a lineup marker.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          marker_id: { type: 'integer', description: 'The marker ID' },
          starts_on: { type: 'string', description: 'New start date (YYYY-MM-DD)' },
          ends_on: { type: 'string', description: 'New end date (YYYY-MM-DD)' },
          color: { type: 'string', description: 'New marker color' }
        },
        required: %w[project_id marker_id]
      )

      class << self
        def call(project_id:, marker_id:, server_context:, starts_on: nil, ends_on: nil, color: nil)
          body = {}
          body[:starts_on] = starts_on if starts_on
          body[:ends_on] = ends_on if ends_on
          body[:color] = color if color
          marker = client(server_context:).put("buckets/#{project_id}/lineup_markers/#{marker_id}", body)
          text_response(marker)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class TrashLineupMarker < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Trash a lineup marker.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          marker_id: { type: 'integer', description: 'The marker ID' }
        },
        required: %w[project_id marker_id]
      )

      class << self
        def call(project_id:, marker_id:, server_context:)
          client(server_context:).trash(project_id, marker_id)
          text_response({ status: 'trashed', marker_id: marker_id })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end
  end
end
