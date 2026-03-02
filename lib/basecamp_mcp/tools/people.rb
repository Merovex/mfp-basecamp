# frozen_string_literal: true

module BasecampMcp
  module Tools
    class ListPeople < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'List people on the Basecamp account (paginated).'

      input_schema(
        properties: {
          page: { type: 'integer', description: 'Page number (default: 1)' }
        }
      )

      class << self
        def call(server_context:, page: 1)
          people, has_more = client(server_context:).get_page('people', {}, page: page)
          paginated_list_response(people, page: page, has_more: has_more)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class GetPerson < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Get a specific person's details by their ID."

      input_schema(
        properties: {
          person_id: { type: 'integer', description: "The person's ID" }
        },
        required: ['person_id']
      )

      class << self
        def call(person_id:, server_context:)
          person = client(server_context:).get("people/#{person_id}")
          text_response(person)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class GetMyProfile < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Get the authenticated user's profile."

      input_schema(properties: {})

      class << self
        def call(server_context:)
          profile = client(server_context:).get('my/profile')
          text_response(profile)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class ListPingablePeople < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'List people who can be pinged on the account (paginated).'

      input_schema(
        properties: {
          page: { type: 'integer', description: 'Page number (default: 1)' }
        }
      )

      class << self
        def call(server_context:, page: 1)
          people, has_more = client(server_context:).get_page('circles/people', {}, page: page)
          paginated_list_response(people, page: page, has_more: has_more)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end
  end
end
