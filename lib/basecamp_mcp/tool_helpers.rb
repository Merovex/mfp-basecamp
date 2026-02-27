# frozen_string_literal: true

module BasecampMcp
  module ToolHelpers
    def client(server_context:)
      server_context[:client]
    end

    def text_response(data)
      text = data.is_a?(String) ? data : JSON.pretty_generate(data)
      MCP::Tool::Response.new([{ type: 'text', text: text }])
    end

    def error_response(message)
      MCP::Tool::Response.new(
        [{ type: 'text', text: "Error: #{message}" }],
        error: true
      )
    end
  end
end
