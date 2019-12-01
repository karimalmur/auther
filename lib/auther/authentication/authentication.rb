# frozen_string_literal: true

module Auther
  module Authentication
    extend Dry::Monads[:result]

    class AuthenticationManager
      include Dry::Monads[:result]

      attr_reader :current_user, :error

      def initialize(env)
        @env = env
      end

      def authenticate
        clear_errors
        run_authentication_strategies
        return Success(current_user) if current_user

        Failure(error)
      end

      def authenticated?
        !current_user.nil?
      end

      private

      def run_authentication_strategies
        catch(:auther) do
          Authentication.strategies.each do |identifier, strategy_class|
            strategy = build_strategy(identifier, strategy_class)
            next unless strategy.valid?

            strategy.authenticate.either(
              ->(user) { (@current_user = user) && throw(:auther) },
              ->(failure) { @error = failure }
            )
          end
        end
      end

      def build_strategy(identifier, strategy_class)
        strategy_class.new(@env, Authentication.repositories[identifier])
      end

      # Clears error (if any) tht was set during the last
      # unsuccessful run of authenticate
      def clear_errors
        @error = nil
      end
    end

    class << self
      def add_authentication_strategy(strategy)
        # raise unless strategy 1. is a Strategies::Base, 2. has 'authenticate' method
        validate_strategy(strategy)

        strategies[strategy.identifier] = strategy
        Success(strategy)
      end

      def add_authentication_repository(repository, strategy_identifier)
        unless strategies[strategy_identifier]
          raise ::Auther::StrategyNotFound, "Couldn't find strategy #{strategy_identifier}"
        end

        repositories[strategy_identifier] = repository
      end

      def strategies
        @strategies ||= {}
      end

      def repositories
        @repositories ||= {}
      end

      def validate_strategy(strategy)
        validate_strategy_base(strategy)
        validate_strategy_implementation(strategy)
      end

      def validate_strategy_base(strategy)
        return if strategy.ancestors.include?(::Auther::Authentication::Strategies::Base)

        raise(
          ::Auther::InvalidStrategyBase,
          "Authentication strategies need to inherit from"\
          "#{::Auther::Authentication::Strategies::Base}"
        )
      end

      def validate_strategy_implementation(strategy)
        return if strategy.method_defined?(:authenticate)

        raise(
          ::Auther::InvalidStrategyImplementation,
          "A strategy needs to implement 'authenticate' method"
        )
      end
    end
  end
end
