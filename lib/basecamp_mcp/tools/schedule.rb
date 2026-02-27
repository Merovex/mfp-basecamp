# frozen_string_literal: true

module BasecampMcp
  module Tools
    class GetSchedule < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get the schedule for a project. Returns the schedule ID needed for listing/creating entries.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project ID' },
          schedule_id: { type: 'integer', description: 'The schedule ID (from project dock)' }
        },
        required: %w[project_id schedule_id]
      )

      class << self
        def call(project_id:, schedule_id:, server_context:)
          schedule = client(server_context:).get("buckets/#{project_id}/schedules/#{schedule_id}")
          text_response(schedule)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class ListScheduleEntries < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "List all entries in a project's schedule."

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          schedule_id: { type: 'integer', description: 'The schedule ID' },
          status: { type: 'string', enum: %w[active archived trashed], description: 'Filter by status' }
        },
        required: %w[project_id schedule_id]
      )

      class << self
        def call(project_id:, schedule_id:, server_context:, status: nil)
          params = {}
          params[:status] = status if status
          entries = client(server_context:).get_all(
            "buckets/#{project_id}/schedules/#{schedule_id}/entries", params
          )
          entries.each { |e| e['description'] = HtmlUtils.strip_for_ai(e['description']) if e['description'] }
          text_response(entries)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class GetScheduleEntry < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get a specific schedule entry by ID.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          entry_id: { type: 'integer', description: 'The schedule entry ID' }
        },
        required: %w[project_id entry_id]
      )

      class << self
        def call(project_id:, entry_id:, server_context:)
          entry = client(server_context:).get("buckets/#{project_id}/schedule_entries/#{entry_id}")
          entry['description'] = HtmlUtils.strip_for_ai(entry['description']) if entry['description']
          text_response(entry)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class CreateScheduleEntry < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Create a new schedule entry.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          schedule_id: { type: 'integer', description: 'The schedule ID' },
          summary: { type: 'string', description: 'Entry title/summary' },
          starts_at: { type: 'string', description: 'Start datetime (ISO 8601) or date (YYYY-MM-DD)' },
          ends_at: { type: 'string', description: 'End datetime (ISO 8601) or date (YYYY-MM-DD)' },
          description: { type: 'string', description: 'Description (supports HTML)' },
          all_day: { type: 'boolean', description: 'Whether this is an all-day event' },
          participant_ids: { type: 'array', items: { type: 'integer' },
                             description: 'People IDs to add as participants' },
          notify: { type: 'boolean', description: 'Whether to notify participants' }
        },
        required: %w[project_id schedule_id summary starts_at ends_at]
      )

      class << self
        def call(project_id:, schedule_id:, summary:, starts_at:, ends_at:,
                 server_context:, description: nil, all_day: nil, participant_ids: nil, notify: nil)
          body = { summary: summary, starts_at: starts_at, ends_at: ends_at }
          body[:description] = description if description
          body[:all_day] = all_day unless all_day.nil?
          body[:participant_ids] = participant_ids if participant_ids
          body[:notify] = notify unless notify.nil?
          entry = client(server_context:).post(
            "buckets/#{project_id}/schedules/#{schedule_id}/entries", body
          )
          text_response(entry)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class UpdateScheduleEntry < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Update a schedule entry.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          entry_id: { type: 'integer', description: 'The schedule entry ID' },
          summary: { type: 'string', description: 'New title/summary' },
          starts_at: { type: 'string', description: 'New start datetime' },
          ends_at: { type: 'string', description: 'New end datetime' },
          description: { type: 'string', description: 'New description (supports HTML)' },
          all_day: { type: 'boolean', description: 'Whether this is an all-day event' },
          participant_ids: { type: 'array', items: { type: 'integer' }, description: 'New participant IDs' },
          notify: { type: 'boolean', description: 'Whether to notify participants' }
        },
        required: %w[project_id entry_id]
      )

      class << self
        def call(project_id:, entry_id:, server_context:, summary: nil, starts_at: nil, ends_at: nil,
                 description: nil, all_day: nil, participant_ids: nil, notify: nil)
          body = {}
          body[:summary] = summary if summary
          body[:starts_at] = starts_at if starts_at
          body[:ends_at] = ends_at if ends_at
          body[:description] = description if description
          body[:all_day] = all_day unless all_day.nil?
          body[:participant_ids] = participant_ids if participant_ids
          body[:notify] = notify unless notify.nil?
          entry = client(server_context:).put("buckets/#{project_id}/schedule_entries/#{entry_id}", body)
          text_response(entry)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class TrashScheduleEntry < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Move a schedule entry to the trash.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          entry_id: { type: 'integer', description: 'The schedule entry ID' }
        },
        required: %w[project_id entry_id]
      )

      class << self
        def call(project_id:, entry_id:, server_context:)
          client(server_context:).trash(project_id, entry_id)
          text_response({ status: 'trashed', entry_id: entry_id })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end
  end
end
