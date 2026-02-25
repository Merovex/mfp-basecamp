# frozen_string_literal: true

module BasecampMcp
  module Middleware
    class RateLimitRetry < Faraday::Middleware
      MAX_RETRIES = 3

      def call(env)
        retries = 0

        loop do
          response = @app.call(env)

          if response.status == 429 && retries < MAX_RETRIES
            wait = (response.headers["Retry-After"] || 10).to_i
            sleep(wait)
            retries += 1
          else
            return response
          end
        end
      end
    end
  end
end
