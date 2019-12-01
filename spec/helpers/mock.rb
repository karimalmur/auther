# frozen_string_literal: true

require "rack"

module Auther
  module Spec
    module Helpers
      # A mock of an application to get a Auther object to test on
      module Mock
        # A helper method that provides the auther object by mocking the env variable.
        # @api public
        def auther
          @auther ||= begin
            env["auther"]
          end
        end

        private

        def env
          @env ||= begin
            request = Rack::MockRequest.env_for(
              "/?#{Rack::Utils.build_query({})}",
              "HTTP_VERSION" => "1.1",
              "REQUEST_METHOD" => "GET"
            )
            app.call(request)

            request
          end
        end

        def app
          @app ||= begin
            opts = {
              failure_app: -> { [401, { "Content-Type" => "text/plain" }, ["You Fail!"]] }
            }

            Rack::Builder.new do
              use Auther::Middleware, opts, &proc {}
              run -> { [200, { "Content-Type" => "text/plain" }, ["You Win"]] }
            end
          end
        end
      end
    end
  end
end
