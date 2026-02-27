# frozen_string_literal: true

module BasecampMcp
  module Middleware
    class RateLimitRetry < Faraday::Middleware
      MAX_RETRIES = 3
      MAX_WAIT_SECONDS = 60

      def call(env)
        retries = 0

        loop do
          response = @app.call(env)

          return response unless response.status == 429 && retries < MAX_RETRIES

          wait = [(response.headers['Retry-After'] || 10).to_i, MAX_WAIT_SECONDS].min
          sleep(wait)
          retries += 1
        end
      end
    end
  end
end
