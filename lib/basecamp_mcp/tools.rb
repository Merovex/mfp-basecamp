# frozen_string_literal: true

require "mcp"

module BasecampMcp
  module Tools
    TOOL_FILES = %w[
      people
      projects
      templates
      message_boards
      messages
      message_types
      campfire
      chatbots
      todosets
      todolists
      todolist_groups
      todos
      card_tables
      documents
      vaults
      uploads
      schedule
      checkins
      inbox
      client_access
      comments
      recordings
      subscriptions
      events
      lineup
      timesheets
      webhooks
    ].freeze

    TOOL_FILES.each { |f| require_relative "tools/#{f}" }

    def self.all
      ObjectSpace.each_object(Class)
        .select { |klass| klass < MCP::Tool && klass.name&.start_with?("BasecampMcp::Tools::") }
        .sort_by(&:name)
    end
  end
end
