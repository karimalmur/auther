# frozen_string_literal: true

require "forwardable"

module Auther
  class Auther
    extend Forwardable

    attr_reader :env, :authentication_strategy

    def_delegators :authentication_manager, :authenticate, :authenticated?, :current_user

    def initialize(env)
      @env = env
    end

    private

    def authentication_manager
      @authentication_manager ||= ::Auther::Authentication::AuthenticationManager.new(env)
    end
  end
end
