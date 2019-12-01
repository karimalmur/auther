# frozen_string_literal: true

RSpec.describe ::Auther::Authentication::AuthenticationManager do
  include Dry::Monads[:result]

  describe ".authenticate" do
    class FailedStrategy < ::Auther::Authentication::Strategies::Base
      def authenticate
        Failure("failure content")
      end
    end

    class EmailStrategy < ::Auther::Authentication::Strategies::Base
      def valid?
        !request_context.params["email"]&.empty?
      end

      def authenticate
        return Failure() unless request_context.params["email"] == "email"

        Success(request_context.params["email"])
      end
    end

    class UsernameStrategy < ::Auther::Authentication::Strategies::Base
      def valid?
        !request_context.params["username"]&.empty?
      end

      def authenticate
        return Failure("invalid username") unless request_context.params["username"] == "username"

        Success(request_context.params["username"])
      end
    end

    before(:each) do
      ::Auther::Authentication.strategies.clear
      ::Auther::Authentication.repositories.clear
    end

    context "when at least one strategy can succeed" do
      before(:each) do
        ::Auther::Authentication.strategies.clear
        ::Auther::Authentication.add_authentication_strategy(EmailStrategy)
        ::Auther::Authentication.add_authentication_strategy(UsernameStrategy)
      end

      it "returns success" do
        run_rack_app(email: "email") do |env|
          expect(env["auther"].authenticate.success?).to be(true)
        end
      end

      it "sets current_user" do
        run_rack_app(email: "email") do |env|
          env["auther"].authenticate
          expect(env["auther"].current_user).to eq("email")
        end
      end

      context "when a strategy fails" do
        before(:each) do
          # Order Matters
          ::Auther::Authentication.strategies.clear
          ::Auther::Authentication.add_authentication_strategy(UsernameStrategy)
          ::Auther::Authentication.add_authentication_strategy(FailedStrategy)
          ::Auther::Authentication.add_authentication_strategy(EmailStrategy)
        end

        it "will try other strategies" do
          run_rack_app(email: "email") do |env|
            expect(env["auther"].authenticate.success?).to be(true)
          end
        end
      end
    end

    context "when no strategy succeeds" do
      context "when all strategies are invalid" do
        before(:each) do
          ::Auther::Authentication.strategies.clear
          ::Auther::Authentication.add_authentication_strategy(EmailStrategy)
          ::Auther::Authentication.add_authentication_strategy(UsernameStrategy)
        end

        it "returns a failure" do
          run_rack_app(phone: "+2010") do |env|
            expect(env["auther"].authenticate.failure?).to be(true)
          end
        end

        it "does not set current_user" do
          run_rack_app(phone: "+2010") do |env|
            env["auther"].authenticate
            expect(env["auther"].current_user).to be_nil
          end
        end
      end

      context "when at least one strategy is valid but fails" do
        before(:each) do
          ::Auther::Authentication.strategies.clear
          # Order Matters
          ::Auther::Authentication.add_authentication_strategy(UsernameStrategy)
          ::Auther::Authentication.add_authentication_strategy(EmailStrategy)
          ::Auther::Authentication.add_authentication_strategy(FailedStrategy)
        end

        it "returns the latest ran strategy's failure" do
          run_rack_app(email: "invalid") do |env|
            result = env["auther"].authenticate
            expect(result.failure?).to be(true)
            expect(result.failure).to eq("failure content")
          end
        end
      end

      it "resets error state" do
        ::Auther::Authentication.strategies.clear
        # Order Matters
        ::Auther::Authentication.add_authentication_strategy(FailedStrategy)
        ::Auther::Authentication.add_authentication_strategy(UsernameStrategy)

        run_rack_app(username: "invalid") do |env|
          expect(env["auther"].authenticate.failure).to eq("invalid username")
        end

        ::Auther::Authentication.strategies.clear
        ::Auther::Authentication.add_authentication_strategy(EmailStrategy)

        run_rack_app(phone: "+2010") do |env|
          expect(env["auther"].authenticate.failure).to eq(Dry::Monads::Unit)
        end
      end
    end
  end

  describe "#authenticated?" do
    before(:each) do
      # Order Matters
      ::Auther::Authentication.add_authentication_strategy(EmailStrategy)
      ::Auther::Authentication.add_authentication_strategy(UsernameStrategy)
    end

    context "when authentication fails" do
      it "returns false" do
        run_rack_app do |env|
          env["auther"].authenticate
          expect(env["auther"].authenticated?).to be(false)
        end
      end
    end

    context "when current_user is set" do
      it "returns true" do
        run_rack_app(username: "username") do |env|
          env["auther"].authenticate
          expect(env["auther"].authenticated?).to be(true)
        end
      end
    end
  end
end
