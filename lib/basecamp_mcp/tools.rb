# frozen_string_literal: true

require "mcp"

module BasecampMcp
  module Tools
    TOOL_FILES = %w[
      people
      projects
      message_boards
      messages
      message_types
      todosets
      todolists
      todos
      comments
    ].freeze

    TOOL_FILES.each { |f| require_relative "tools/#{f}" }

    def self.all
      ObjectSpace.each_object(Class)
        .select { |klass| klass < MCP::Tool && klass.name&.start_with?("BasecampMcp::Tools::") }
        .sort_by(&:name)
    end
  end
end
