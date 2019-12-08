# frozen_string_literal: true

require "jwt"

RSpec.describe ::Auther::Authorization::TokenManager do
  before(:each) do
    @secret = ::Auther.token_options.secret
    ::Auther.configure do |config|
      config.token_config do |tc|
        tc.secret = "sekret"
      end
    end
  end

  after(:each) do
    ::Auther.configure do |config|
      config.token_config do |tc|
        tc.secret = @secret
      end
    end
  end

  describe ".encode" do
    context "when a 'JWT::*Error' is raised" do
      context "when raised error is a JWT::EncodeError" do
        before(:each) do
          @algorithm = ::Auther.token_options.algorithm
          @secret = ::Auther.token_options.secret

          ::Auther.configure do |config|
            config.token_config do |tc|
              tc.algorithm = "RS256"
              tc.secret = "invalid"
            end
          end
        end

        after(:each) do
          ::Auther.configure do |config|
            config.token_config do |tc|
              tc.algorithm = @algorithm
              tc.secret = @secret
            end
          end
        end

        it "returns the raised error wrapped in a failure" do
          token = Auther::Authorization::Token.new
          result = ::Auther::Authorization::TokenManager.encode(token)

          expect(result.failure?).to be(true)
          expect(result.failure).to be_a(JWT::EncodeError)
        end
      end

      context "when raised error is a JWT::DecodeError" do
        it "returns the raised error wrapped in a failure" do
          token = Auther::Authorization::Token.new.tap do |t|
            t.instance_variable_set("@claims", t.claims.merge(iat: nil))
          end

          result = ::Auther::Authorization::TokenManager.encode(token)

          expect(result.failure?).to be(true)
          expect(result.failure).to be_a(JWT::DecodeError)
        end
      end
    end

    it "encodes an Auther::Authorization::Token instance" do
      result = ::Auther::Authorization::TokenManager.encode(
        ::Auther::Authorization::Token.new(payload: { "data" => "foo" })
      )
      expect(result.success?).to be(true)
      expect(
        JWT.decode(
          result.success,
          ::Auther.token_options.secret,
          algorithm: ::Auther.token_options.algorithm
        )[0]["data"]
      ).to eq(
        "foo"
      )
    end
  end

  describe ".decode" do
    context "when a 'JWT::DecodeError' is raised" do
      it "returns the raised error wrapped in a failure" do
        # decoding an empty token will fill cause of a missing jti error
        token = Auther::Authorization::Token.new
        encoded_token = ::Auther::Authorization::TokenManager.encode(token).success
        result = ::Auther::Authorization::TokenManager.decode(encoded_token)

        expect(result.failure?).to be(true)
        expect(result.failure).to be_a(JWT::DecodeError)
      end
    end

    it "decodes an a token into an ::Auther::Athorization::Token instance" do
      token = Auther::Authorization::Token.new(
        payload: { "data" => "foo" },
        with_claim_defaults: true
      )
      encoded_token = ::Auther::Authorization::TokenManager.encode(token).success
      result = ::Auther::Authorization::TokenManager.decode(encoded_token)

      expect(result.success?).to be(true)
      expect(result.success).to be_a(::Auther::Authorization::Token)
      expect(result.success.payload["data"]).to eq("foo")
    end
  end
end
