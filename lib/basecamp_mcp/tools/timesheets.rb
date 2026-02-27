# frozen_string_literal: true

module BasecampMcp
  module Tools
    class GetTimesheet < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get the timesheet for a project.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project ID' },
          timesheet_id: { type: 'integer', description: 'The timesheet ID (from project dock)' }
        },
        required: %w[project_id timesheet_id]
      )

      class << self
        def call(project_id:, timesheet_id:, server_context:)
          timesheet = client(server_context:).get("buckets/#{project_id}/timesheets/#{timesheet_id}")
          text_response(timesheet)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class ListTimeEntries < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "List all time entries in a project's timesheet."

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          timesheet_id: { type: 'integer', description: 'The timesheet ID' }
        },
        required: %w[project_id timesheet_id]
      )

      class << self
        def call(project_id:, timesheet_id:, server_context:)
          entries = client(server_context:).get_all(
            "buckets/#{project_id}/timesheets/#{timesheet_id}/entries"
          )
          text_response(entries)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class GetTimeEntry < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get a specific time entry.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          entry_id: { type: 'integer', description: 'The time entry ID' }
        },
        required: %w[project_id entry_id]
      )

      class << self
        def call(project_id:, entry_id:, server_context:)
          entry = client(server_context:).get("buckets/#{project_id}/time_entries/#{entry_id}")
          text_response(entry)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class CreateTimeEntry < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Log time to a project's timesheet."

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          timesheet_id: { type: 'integer', description: 'The timesheet ID' },
          hours: { type: 'number', description: 'Number of hours (e.g., 1.5)' },
          date: { type: 'string', description: 'Date for the entry (YYYY-MM-DD)' },
          description: { type: 'string', description: 'Description of work done' }
        },
        required: %w[project_id timesheet_id hours date]
      )

      class << self
        def call(project_id:, timesheet_id:, hours:, date:, server_context:, description: nil)
          body = { hours: hours, date: date }
          body[:description] = description if description
          entry = client(server_context:).post(
            "buckets/#{project_id}/timesheets/#{timesheet_id}/entries", body
          )
          text_response(entry)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class UpdateTimeEntry < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Update a time entry.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          entry_id: { type: 'integer', description: 'The time entry ID' },
          hours: { type: 'number', description: 'New hours' },
          date: { type: 'string', description: 'New date (YYYY-MM-DD)' },
          description: { type: 'string', description: 'New description' }
        },
        required: %w[project_id entry_id]
      )

      class << self
        def call(project_id:, entry_id:, server_context:, hours: nil, date: nil, description: nil)
          body = {}
          body[:hours] = hours if hours
          body[:date] = date if date
          body[:description] = description if description
          entry = client(server_context:).put("buckets/#{project_id}/time_entries/#{entry_id}", body)
          text_response(entry)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class TrashTimeEntry < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Trash a time entry.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          entry_id: { type: 'integer', description: 'The time entry ID' }
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
