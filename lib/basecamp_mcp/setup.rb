# frozen_string_literal: true

require "webrick"
require "uri"
require "open-uri"

module BasecampMcp
  class Setup
    AUTHORIZE_URL = "https://launchpad.37signals.com/authorization/new"
    TOKEN_URL = "https://launchpad.37signals.com/authorization/token"
    AUTH_INFO_URL = "https://launchpad.37signals.com/authorization.json"
    REDIRECT_PORT = 14839
    REDIRECT_URI = "http://localhost:#{REDIRECT_PORT}/callback"

    def self.run
      new.run
    end

    def self.generate_claude_config
      bin_path = File.expand_path("../../bin/basecamp-mcp", __dir__)
      config = {
        mcpServers: {
          basecamp: {
            command: "ruby",
            args: [bin_path]
          }
        }
      }
      puts JSON.pretty_generate(config)
    end

    def run
      puts "Basecamp MCP Server Setup"
      puts "========================="
      puts

      client_id = prompt("Enter your Basecamp OAuth Client ID")
      client_secret = prompt("Enter your Basecamp OAuth Client Secret")

      puts
      puts "Opening browser for authorization..."
      auth_url = "#{AUTHORIZE_URL}?type=web_server&client_id=#{client_id}&redirect_uri=#{URI.encode_www_form_component(REDIRECT_URI)}"

      code = capture_oauth_code(auth_url)

      puts "Exchanging code for tokens..."
      tokens = exchange_code(code, client_id, client_secret)

      puts "Fetching account information..."
      accounts = fetch_accounts(tokens["access_token"])

      bc3_accounts = accounts.select { |a| a["product"] == "bc3" }
      if bc3_accounts.empty?
        puts "Error: No Basecamp 4 accounts found."
        exit 1
      end

      account = if bc3_accounts.length == 1
        bc3_accounts.first
      else
        choose_account(bc3_accounts)
      end

      credentials = {
        "client_id" => client_id,
        "client_secret" => client_secret,
        "access_token" => tokens["access_token"],
        "refresh_token" => tokens["refresh_token"],
        "account_id" => account["id"].to_s,
        "account_name" => account["name"]
      }

      token_store = TokenStore.new rescue nil
      store = TokenStore.allocate
      store.save(credentials)

      puts
      puts "Setup complete! Credentials saved to ~/.basecamp-mcp/credentials.json"
      puts "Account: #{account["name"]} (ID: #{account["id"]})"
      puts
      puts "To configure Claude Desktop, run:"
      puts "  basecamp-mcp config"
    end

    private

    def prompt(message)
      print "#{message}: "
      $stdin.gets.chomp
    end

    def capture_oauth_code(auth_url)
      code = nil
      server = WEBrick::HTTPServer.new(
        Port: REDIRECT_PORT,
        Logger: WEBrick::Log.new("/dev/null"),
        AccessLog: []
      )

      server.mount_proc "/callback" do |req, res|
        code = req.query["code"]
        res.body = "<html><body><h1>Authorization successful!</h1><p>You can close this window.</p></body></html>"
        res.content_type = "text/html"
        Thread.new { sleep 1; server.shutdown }
      end

      system("open", auth_url) || system("xdg-open", auth_url)

      server.start
      raise "No authorization code received" unless code

      code
    end

    def exchange_code(code, client_id, client_secret)
      response = Faraday.post(TOKEN_URL, {
        type: "web_server",
        grant_type: "authorization_code",
        client_id: client_id,
        client_secret: client_secret,
        redirect_uri: REDIRECT_URI,
        code: code
      })

      unless response.success?
        raise "Token exchange failed (#{response.status}): #{response.body}"
      end

      JSON.parse(response.body)
    end

    def fetch_accounts(access_token)
      response = Faraday.get(AUTH_INFO_URL) do |req|
        req.headers["Authorization"] = "Bearer #{access_token}"
        req.headers["User-Agent"] = Client::USER_AGENT
      end

      unless response.success?
        raise "Failed to fetch accounts (#{response.status}): #{response.body}"
      end

      JSON.parse(response.body)["accounts"]
    end

    def choose_account(accounts)
      puts
      puts "Multiple Basecamp accounts found:"
      accounts.each_with_index do |account, i|
        puts "  #{i + 1}. #{account["name"]} (ID: #{account["id"]})"
      end
      print "Choose account (1-#{accounts.length}): "
      choice = $stdin.gets.chomp.to_i
      accounts[choice - 1]
    end
  end
end
