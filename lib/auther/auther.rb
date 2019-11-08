# frozen_string_literal: true

module Auther
  class Auther
    attr_reader :env, :authentication_strategy

    def initialize(env)
      @env = env
    end

    def authenticate; end
  end
end
