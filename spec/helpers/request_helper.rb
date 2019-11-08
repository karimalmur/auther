# frozen_string_literal: true

module Auther
  module Spec
    module Helpers
      FAILURE_APP = ->(_) { [401, { "Content-Type" => "text/plain" }, ["You Fail!"]] }

      def env_with_params(path = "/", params = {}, env = {})
        method = params.delete(:method) || "GET"
        env = { "HTTP_VERSION" => "1.1", "REQUEST_METHOD" => method }.merge(env)
        Rack::MockRequest.env_for("#{path}?#{Rack::Utils.build_query(params)}", env)
      end

      def setup_rack(app = nil, opts = {}, &block)
        app ||= block if block_given?
        blk = opts[:configurator] || proc {}

        Rack::Builder.new do
          use ::Auther::Middleware, opts, &blk
          run app
        end
      end

      def valid_response
        Rack::Response.new("OK").finish
      end

      def failure_app
        FAILURE_APP
      end

      def success_app
        ->(_) { [200, { "Content-Type" => "text/plain" }, ["You Win"]] }
      end
    end
  end
end
