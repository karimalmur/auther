# frozen_string_literal: true

module Auther
  module Authentication
    module Strategies
      # Password authentication strategy. Based on resource's _identifier_ and _password_
      class PasswordStrategy < Base
        def valid?
          return false unless repository

          !(resource_auth_hash.empty? && request_context.params["password"].nil?)
        end

        # Authenticates a request using resources' _password_ and _identifier_ (e.g. email).
        # @return [Auther::Result]: Authentication result.
        def authenticate
          resource = repository.find_resource(resource_auth_hash)
          unless resource
            return Failure(Error.new(ERROR_RESOURCE_NOT_FOUND, "resource was not found"))
          end

          resource.authenticate_password(request_context.params["password"])
        end

        protected

        def resource_auth_hash
          @resource_auth_hash ||=
            request_context.params.filter do |identifier, _|
              ::Auther.configuration.resource_identifiers.include?(identifier) &&
                !request_context.params[identifier].empty?
            end
        end
      end
    end
  end
end

::Auther::Authentication.add_authentication_strategy(
  ::Auther::Authentication::Strategies::PasswordStrategy
)
