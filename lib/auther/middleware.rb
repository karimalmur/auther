# frozen_string_literal: true

module Auther
  class Middleware
    def initialize(app, options = {})
      @app = app
      @options = options
    end

    def call(env)
      env["auther"] = Auther.new(env)
      @app.call(env)
    end
  end
end
