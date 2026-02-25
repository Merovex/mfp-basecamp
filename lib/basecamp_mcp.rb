# frozen_string_literal: true

require "json"
require "fileutils"

require_relative "basecamp_mcp/version"
require_relative "basecamp_mcp/html_utils"
require_relative "basecamp_mcp/tool_helpers"
require_relative "basecamp_mcp/token_store"
require_relative "basecamp_mcp/middleware/token_refresh"
require_relative "basecamp_mcp/middleware/rate_limit_retry"
require_relative "basecamp_mcp/client"
require_relative "basecamp_mcp/tools"
require_relative "basecamp_mcp/server"
# setup.rb is loaded on demand by bin/basecamp-mcp (requires webrick)

module BasecampMcp
end
