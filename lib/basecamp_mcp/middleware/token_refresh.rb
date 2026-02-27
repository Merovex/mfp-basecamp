# frozen_string_literal: true

module BasecampMcp
  module Middleware
    class TokenRefresh < Faraday::Middleware
      def initialize(app, token_store:)
        super(app)
        @token_store = token_store
        @refresh_mutex = Mutex.new
      end

      def call(env)
        response = @app.call(env)

        if response.status == 401
          @refresh_mutex.synchronize do
            @token_store.refresh!
            env.request_headers["Authorization"] = "Bearer #{@token_store.access_token}"
          end
          response = @app.call(env)
        end

        response
      end
    end
  end
end
