# frozen_string_literal: true

module BasecampMcp
  class Server
    def self.run
      token_store = TokenStore.new
      client = Client.new(
        account_id: token_store.account_id,
        token_store: token_store
      )

      server = MCP::Server.new(
        name: "basecamp-mcp",
        version: BasecampMcp::VERSION,
        tools: Tools.all,
        server_context: { client: client }
      )

      # STDIO transport uses $stdout for JSON-RPC; redirect $stderr to log file
      log_path = File.join(TokenStore::CONFIG_DIR, "server.log")
      FileUtils.mkdir_p(TokenStore::CONFIG_DIR)
      $stderr.reopen(File.open(log_path, "a"))

      transport = MCP::Server::Transports::StdioTransport.new(server)
      transport.open
    end
  end
end
