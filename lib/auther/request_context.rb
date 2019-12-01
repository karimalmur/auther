# frozen_string_literal: true

module Auther
  class RequestContext
    def initialize(env)
      @env = env
    end

    def request
      @request ||= Rack::Request.new(@env)
    end

    def params
      request.params
    end
  end
end
