# frozen_string_literal: true

require 'faraday'

module BasecampMcp
  class Client
    DEFAULT_USER_AGENT = 'BasecampMCP (basecamp-mcp@example.com)'

    attr_reader :account_id

    def initialize(account_id:, token_store:, base_url: nil)
      @account_id = account_id
      @token_store = token_store
      @base_url = base_url || ENV['BASECAMP_BASE_URL'] || 'https://3.basecampapi.com'
      @user_agent = token_store.user_agent || DEFAULT_USER_AGENT
      @connection = build_connection
    end

    def get(path, params = {})
      response = @connection.get(api_path(path), params)
      raise_on_error!(response)
      response.body
    end

    def get_all(path, params = {})
      results = []
      url = api_path(path)

      loop do
        response = @connection.get(url, params)
        raise_on_error!(response)
        results.concat(Array(response.body))

        next_url = extract_next_link(response.headers['link'])
        break unless next_url

        url = next_url
        params = {} # params are embedded in the Link URL
      end

      results
    end

    def post(path, body = {})
      response = @connection.post(api_path(path)) do |req|
        req.body = body.to_json unless body.empty?
      end
      raise_on_error!(response)
      response.body
    end

    def put(path, body = {})
      response = @connection.put(api_path(path)) do |req|
        req.body = body.to_json unless body.empty?
      end
      raise_on_error!(response)
      response.body
    end

    def delete(path)
      response = @connection.delete(api_path(path))
      raise_on_error!(response)
      true
    end

    def trash(project_id, recording_id)
      put("buckets/#{project_id}/recordings/#{recording_id}/status/trashed")
    end

    private

    def api_path(path)
      "#{@account_id}/#{path}.json"
    end

    def build_connection
      Faraday.new(url: @base_url) do |f|
        f.request :json
        f.response :json, content_type: /\bjson$/
        f.use BasecampMcp::Middleware::TokenRefresh, token_store: @token_store
        f.use BasecampMcp::Middleware::RateLimitRetry
        f.headers['User-Agent'] = @user_agent
        f.headers['Content-Type'] = 'application/json; charset=utf-8'
        f.request :authorization, 'Bearer', -> { @token_store.access_token }
        f.adapter Faraday.default_adapter
      end
    end

    def extract_next_link(link_header)
      return nil unless link_header

      match = link_header.match(/<([^>]+)>;\s*rel="next"/)
      match ? match[1] : nil
    end

    def raise_on_error!(response)
      return if response.success? || response.status == 204

      raise "API error #{response.status}: #{response.body}"
    end
  end
end
