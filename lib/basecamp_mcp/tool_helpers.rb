# frozen_string_literal: true

module BasecampMcp
  module ToolHelpers
    MAX_RESPONSE_BYTES = 50_000
    SUMMARY_KEYS = %w[id title subject name status created_at updated_at url app_url type content_type
                      starts_on due_on completed position bucket creator assignees].freeze

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

    def paginated_list_response(items, page:, has_more:)
      summarized = items.map { |item| summarize_item(item) }
      footer = pagination_footer(items.size, page, has_more)
      text = JSON.pretty_generate(summarized)

      if text.bytesize > MAX_RESPONSE_BYTES
        summarized = summarized.map { |item| item.slice('id', 'title', 'subject', 'name', 'url', 'status') }
        text = JSON.pretty_generate(summarized)
      end

      text_response("#{text}\n\n#{footer}")
    end

    private

    def summarize_item(item)
      return item unless item.is_a?(Hash)

      item.slice(*SUMMARY_KEYS)
    end

    def pagination_footer(count, page, has_more)
      msg = "Page #{page} (#{count} items)."
      msg += " More pages available — use page: #{page + 1} to continue." if has_more
      msg
    end
  end
end
