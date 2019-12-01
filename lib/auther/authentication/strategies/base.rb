# frozen_string_literal: true

module Auther
  module Authentication
    module Strategies
      class Base
        include Dry::Monads[:result]

        ERROR_RESOURCE_NOT_FOUND = :resource_not_found

        attr_accessor :repository
        attr_reader :env, :request_context

        def initialize(env, repository = nil)
          @env = env
          @request_context = ::Auther::RequestContext.new(env)
          @repository = repository
        end

        def valid?
          true
        end

        def self.identifier
          name.split("::").last.gsub("Strategy", "").downcase
        end
      end
    end
  end
end
