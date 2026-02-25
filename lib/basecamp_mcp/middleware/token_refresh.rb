# frozen_string_literal: true

module BasecampMcp
  module Middleware
    class TokenRefresh < Faraday::Middleware
      def initialize(app, token_store:)
        super(app)
        @token_store = token_store
        @refreshing = false
      end

      def call(env)
        response = @app.call(env)

        if response.status == 401 && !@refreshing
          @refreshing = true
          begin
            @token_store.refresh!
            env.request_headers["Authorization"] = "Bearer #{@token_store.access_token}"
            response = @app.call(env)
          ensure
            @refreshing = false
          end
        end

        response
      end
    end
  end
end
