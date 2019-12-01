# frozen_string_literal: true

RSpec.describe ::Auther::Authentication::Strategies::PasswordStrategy do
  PasswordRepository = ::Auther::Spec::Helpers::Strategies::PasswordRepository

  describe "#valid?" do
    before(:each) do
      ::Auther::Authentication.add_authentication_strategy(
        ::Auther::Authentication::Strategies::PasswordStrategy
      )
    end

    context "when stategy resource repository has not been set" do
      it "returns false" do
        password_strategy = ::Auther::Authentication.strategies["password"].new(
          env_with_params
        )
        expect(password_strategy.valid?).to be(false)
      end
    end

    context "when params are missing required resource identifiers" do
      it "returns false" do
        password_strategy = ::Auther::Authentication.strategies["password"].new(
          env_with_params,
          PasswordRepository
        )

        expect(password_strategy.valid?).to be(false)

        password_strategy = ::Auther::Authentication.strategies["password"].new(
          env_with_params("/", { phone: "+2010" }, {}),
          PasswordRepository
        )

        expect(password_strategy.valid?).to be(false)
      end
    end

    context "when params are missing password" do
      it "returns false" do
        password_strategy = ::Auther::Authentication.strategies["password"].new(
          env_with_params("/", { email: "b@c.com" }, {}),
          PasswordRepository
        )

        expect(password_strategy.valid?).to be(false)
      end
    end

    context "when params contains password and at least one of the required resource ids" do
      it "returns true" do
        password_strategy_with_email = ::Auther::Authentication.strategies["password"].new(
          env_with_params("/", { email: "a@b.com", password: "pass" }, {}),
          PasswordRepository
        )

        password_strategy_with_username = ::Auther::Authentication.strategies["password"].new(
          env_with_params("/", { username: "ooser", password: "pass" }, {}),
          PasswordRepository
        )

        expect(
          password_strategy_with_email.valid? && password_strategy_with_username.valid?
        ).to be(true)
      end
    end
  end

  describe "#authenticate" do
    context "when resource is not found" do
      it "returns a failure" do
        password_strategy = ::Auther::Authentication.strategies["password"].new(
          env_with_params("/", { username: "ooser", password: "pass" }, {}),
          ::Auther::Spec::Helpers::Strategies::EmptyPasswordRepository
        )
        result = password_strategy.authenticate

        expect(result.failure?).to be(true)
        expect(result.failure.type)
          .to eq(::Auther::Authentication::Strategies::Base::ERROR_RESOURCE_NOT_FOUND)
      end
    end

    context "when resource is found" do
      class User
        include Auther::Resource

        attr_accessor :email
      end

      let(:user) do
        u = User.new
        u.set_password("password")
        u.email = "a@b.com"
        u
      end

      before(:each) do
        PasswordRepository.resources.clear
        PasswordRepository.resources.push(user)
      end

      context "when password is invalid" do
        it "returns a failure" do
          password_strategy = ::Auther::Authentication.strategies["password"].new(
            env_with_params("/", { email: user.email, password: "wrong_pass" }, {}),
            PasswordRepository
          )
          result = password_strategy.authenticate

          expect(result.failure?).to be(true)
        end
      end

      context "when password is valid" do
        it "returns a success" do
          password_strategy = ::Auther::Authentication.strategies["password"].new(
            env_with_params("/", { email: user.email, password: "password" }, {}),
            PasswordRepository
          )
          result = password_strategy.authenticate

          expect(result.success?).to be(true)
          expect(result.success).to eq(user)
        end
      end
    end
  end
end
