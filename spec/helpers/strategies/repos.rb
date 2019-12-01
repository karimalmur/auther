# frozen_string_literal: true

module Auther
  module Spec
    module Helpers
      module Strategies
        class PasswordRepository
          def self.resources
            @resources ||= []
          end

          # Always returns a result
          def self.find_resource(auth_params)
            @resources.find do |r|
              auth_params.all? do |k, v|
                r.try(k) == v
              end
            end || {}
          end
        end

        class EmptyPasswordRepository
          def self.find_resource(_auth_params)
            nil
          end
        end
      end
    end
  end
end
