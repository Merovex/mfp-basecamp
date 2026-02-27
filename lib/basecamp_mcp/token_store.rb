# frozen_string_literal: true

require 'faraday'

module BasecampMcp
  class TokenStore
    CONFIG_DIR = File.expand_path('~/.basecamp-mcp')
    CREDENTIALS_FILE = File.join(CONFIG_DIR, 'credentials.json')
    TOKEN_URL = 'https://launchpad.37signals.com/authorization/token'

    def initialize
      @credentials = load_credentials
    end

    def access_token
      @credentials['access_token']
    end

    def refresh_token
      @credentials['refresh_token']
    end

    def account_id
      @credentials['account_id']
    end

    def client_id
      @credentials['client_id']
    end

    def client_secret
      @credentials['client_secret']
    end

    def user_agent
      @credentials['user_agent']
    end

    def refresh!
      response = Faraday.post(TOKEN_URL, {
                                grant_type: 'refresh_token',
                                refresh_token: refresh_token,
                                client_id: client_id,
                                client_secret: client_secret
                              })

      raise "Token refresh failed (#{response.status}): #{response.body}" unless response.success?

      new_tokens = JSON.parse(response.body)
      @credentials['access_token'] = new_tokens['access_token']
      @credentials['refresh_token'] = new_tokens['refresh_token'] if new_tokens['refresh_token']
      save_credentials
    end

    def save(credentials)
      @credentials = credentials
      save_credentials
    end

    private

    def load_credentials
      if ENV['BASECAMP_API_KEY'] || ENV['BASECAMP_ACCESS_TOKEN']
        {
          'access_token' => ENV['BASECAMP_API_KEY'] || ENV['BASECAMP_ACCESS_TOKEN'],
          'refresh_token' => ENV.fetch('BASECAMP_REFRESH_TOKEN', nil),
          'client_id' => ENV.fetch('BASECAMP_CLIENT_ID', nil),
          'client_secret' => ENV.fetch('BASECAMP_CLIENT_SECRET', nil),
          'account_id' => ENV.fetch('BASECAMP_ACCOUNT_ID', nil),
          'user_agent' => ENV.fetch('BASECAMP_USER_AGENT', nil)
        }
      elsif File.exist?(CREDENTIALS_FILE)
        JSON.parse(File.read(CREDENTIALS_FILE))
      else
        raise 'No credentials found. Run `basecamp-mcp setup` or set BASECAMP_ACCESS_TOKEN env var.'
      end
    end

    def save_credentials
      FileUtils.mkdir_p(CONFIG_DIR, mode: 0o700)
      File.open(CREDENTIALS_FILE, File::CREAT | File::WRONLY | File::TRUNC, 0o600) do |f|
        f.write(JSON.pretty_generate(@credentials))
      end
    end
  end
end
