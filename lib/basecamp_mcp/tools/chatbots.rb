# frozen_string_literal: true

module BasecampMcp
  module Tools
    class ListChatbots < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'List chatbots configured for a campfire (paginated).'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          campfire_id: { type: 'integer', description: 'The campfire ID' },
          page: { type: 'integer', description: 'Page number (default: 1)' }
        },
        required: %w[project_id campfire_id]
      )

      class << self
        def call(project_id:, campfire_id:, server_context:, page: 1)
          bots, has_more = client(server_context:).get_page(
            "buckets/#{project_id}/chats/#{campfire_id}/integrations", {}, page: page
          )
          paginated_list_response(bots, page: page, has_more: has_more)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class GetChatbot < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get a specific chatbot.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          chatbot_id: { type: 'integer', description: 'The chatbot ID' }
        },
        required: %w[project_id chatbot_id]
      )

      class << self
        def call(project_id:, chatbot_id:, server_context:)
          bot = client(server_context:).get("buckets/#{project_id}/chats/integrations/#{chatbot_id}")
          text_response(bot)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class CreateChatbot < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Create a new chatbot for a campfire.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          campfire_id: { type: 'integer', description: 'The campfire ID' },
          service_name: { type: 'string', description: 'Chatbot display name' },
          command_url: { type: 'string', description: 'Webhook URL the chatbot posts to' }
        },
        required: %w[project_id campfire_id service_name]
      )

      class << self
        def call(project_id:, campfire_id:, service_name:, server_context:, command_url: nil)
          body = { service_name: service_name }
          body[:command_url] = command_url if command_url
          bot = client(server_context:).post(
            "buckets/#{project_id}/chats/#{campfire_id}/integrations", body
          )
          text_response(bot)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class UpdateChatbot < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Update a chatbot's name or command URL."

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          chatbot_id: { type: 'integer', description: 'The chatbot ID' },
          service_name: { type: 'string', description: 'New display name' },
          command_url: { type: 'string', description: 'New webhook URL' }
        },
        required: %w[project_id chatbot_id]
      )

      class << self
        def call(project_id:, chatbot_id:, server_context:, service_name: nil, command_url: nil)
          body = {}
          body[:service_name] = service_name if service_name
          body[:command_url] = command_url if command_url
          bot = client(server_context:).put("buckets/#{project_id}/chats/integrations/#{chatbot_id}", body)
          text_response(bot)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class TrashChatbot < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Trash a chatbot.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          chatbot_id: { type: 'integer', description: 'The chatbot ID' }
        },
        required: %w[project_id chatbot_id]
      )

      class << self
        def call(project_id:, chatbot_id:, server_context:)
          client(server_context:).delete("buckets/#{project_id}/chats/integrations/#{chatbot_id}")
          text_response({ status: 'trashed', chatbot_id: chatbot_id })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class CreateChatbotLine < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Post a message as a chatbot to a campfire.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          campfire_id: { type: 'integer', description: 'The campfire ID' },
          chatbot_id: { type: 'integer', description: 'The chatbot ID' },
          content: { type: 'string', description: 'Message content' }
        },
        required: %w[project_id campfire_id chatbot_id content]
      )

      class << self
        def call(project_id:, campfire_id:, chatbot_id:, content:, server_context:)
          line = client(server_context:).post(
            "buckets/#{project_id}/chats/#{campfire_id}/integrations/#{chatbot_id}/lines",
            { content: content }
          )
          text_response(line)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end
  end
end
