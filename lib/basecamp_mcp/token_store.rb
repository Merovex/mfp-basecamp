# frozen_string_literal: true

require "faraday"

module BasecampMcp
  class TokenStore
    CONFIG_DIR = File.expand_path("~/.basecamp-mcp")
    CREDENTIALS_FILE = File.join(CONFIG_DIR, "credentials.json")
    TOKEN_URL = "https://launchpad.37signals.com/authorization/token"

    def initialize
      @credentials = load_credentials
    end

    def access_token
      @credentials["access_token"]
    end

    def refresh_token
      @credentials["refresh_token"]
    end

    def account_id
      @credentials["account_id"]
    end

    def client_id
      @credentials["client_id"]
    end

    def client_secret
      @credentials["client_secret"]
    end

    def user_agent
      @credentials["user_agent"]
    end

    def refresh!
      response = Faraday.post(TOKEN_URL, {
        grant_type: "refresh_token",
        refresh_token: refresh_token,
        client_id: client_id,
        client_secret: client_secret
      })

      unless response.success?
        raise "Token refresh failed (#{response.status}): #{response.body}"
      end

      new_tokens = JSON.parse(response.body)
      @credentials["access_token"] = new_tokens["access_token"]
      @credentials["refresh_token"] = new_tokens["refresh_token"] if new_tokens["refresh_token"]
      save_credentials
    end

    def save(credentials)
      @credentials = credentials
      save_credentials
    end

    private

    def load_credentials
      if ENV["BASECAMP_API_KEY"] || ENV["BASECAMP_ACCESS_TOKEN"]
        {
          "access_token"  => ENV["BASECAMP_API_KEY"] || ENV["BASECAMP_ACCESS_TOKEN"],
          "refresh_token" => ENV["BASECAMP_REFRESH_TOKEN"],
          "client_id"     => ENV["BASECAMP_CLIENT_ID"],
          "client_secret" => ENV["BASECAMP_CLIENT_SECRET"],
          "account_id"    => ENV["BASECAMP_ACCOUNT_ID"],
          "user_agent"    => ENV["BASECAMP_USER_AGENT"]
        }
      elsif File.exist?(CREDENTIALS_FILE)
        JSON.parse(File.read(CREDENTIALS_FILE))
      else
        raise "No credentials found. Run `basecamp-mcp setup` or set BASECAMP_ACCESS_TOKEN env var."
      end
    end

    def save_credentials
      FileUtils.mkdir_p(CONFIG_DIR)
      File.write(CREDENTIALS_FILE, JSON.pretty_generate(@credentials))
      File.chmod(0600, CREDENTIALS_FILE)
    end
  end
end
