# frozen_string_literal: true

module BasecampMcp
  module Tools
    class ListPeople < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'List all people on the Basecamp account.'

      input_schema(properties: {})

      class << self
        def call(server_context:)
          people = client(server_context:).get_all('people')
          text_response(people)
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

      description 'List all people who can be pinged on the account.'

      input_schema(properties: {})

      class << self
        def call(server_context:)
          people = client(server_context:).get_all('circles/people')
          text_response(people)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end
  end
end
