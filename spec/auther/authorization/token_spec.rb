# frozen_string_literal: true

require "jwt"

RSpec.describe ::Auther::Authorization::Token do
  let(:hmac_secret) { "my$ecretK3y" }
  let(:iat) { Time.now.to_i }
  let(:data) { { "data" => "test" } }
  let(:claims) do
    {
      "jti" => Digest::MD5.hexdigest("#{hmac_secret}:#{Time.now.to_i}"),
      "aud" => "foo",
      "iss" => "auther",
      "sub" => "a client",
      "exp_leeway" => 60,
      "iat" => iat,
      "exp" => Time.now.to_i + 3600
    }
  end
  let(:payload) { data.merge(claims) }

  describe ".from_decoded_token" do
    it "returns an ::Auther::Authorization::Token instance" do
      expect(
        ::Auther::Authorization::Token.from_decoded_token(fake_token.decoded_token)
      ).to be_an(::Auther::Authorization::Token)
    end

    it "sets the payload, header and claims" do
      result = fake_token
      decoded_token = result.decoded_token
      token_instance = ::Auther::Authorization::Token.from_decoded_token(decoded_token)

      expect(token_instance.payload).to eq(data)
      expect(token_instance.header).to eq("alg" => "HS256", "typ" => "JWT")
      expect(token_instance.aud).to eq(["foo"])
      expect(token_instance.iss).to eq("auther")
      expect(token_instance.sub).to eq("a client")
      expect(token_instance.exp_leeway).to eq(60)
      expect(token_instance.jti).to eq(decoded_token[0]["jti"])
      expect(token_instance.iat).to eq(iat)
    end

    it "does not use default claim values for missing claims" do
      pl = payload.reject { |k, _| %w[jti iat iss].include?(k) }

      result = fake_token(payload_data: pl)
      decoded_token = result.decoded_token
      token_instance = ::Auther::Authorization::Token.from_decoded_token(decoded_token)

      expect(token_instance.jti).to be(nil)
      expect(token_instance.iat).to be(nil)
      expect(token_instance.iss).to be(nil)
    end
  end

  describe ".initialize" do
    before(:each) do
      @iss = ::Auther.token_options.iss
      ::Auther.configure do |config|
        config.token_config { |tc| tc.iss = "foo" }
      end
    end

    after(:each) do
      ::Auther.configure do |config|
        config.token_config { |tc| tc.iss = @iss }
      end
    end

    it "can initialize calims with sensible defaults" do
      token = ::Auther::Authorization::Token.new(payload: data, with_claim_defaults: true)

      expect(token.iss).to eq("foo")
      expect(token.iat).not_to be_nil
    end
  end

  describe "#claims" do
    it "returns a hash of token's claims" do
      result = fake_token
      decoded_token = result.decoded_token
      token_instance = ::Auther::Authorization::Token.from_decoded_token(decoded_token)

      expect(token_instance.claims).to eq(
        aud: [claims["aud"]],
        iss: claims["iss"],
        iat: claims["iat"],
        exp: claims["exp"],
        jti: claims["jti"],
        sub: claims["sub"],
        exp_leeway: claims["exp_leeway"]
      )
    end
  end

  def fake_token(payload_data: payload)
    token = JWT.encode payload_data, hmac_secret, "HS256", typ: "JWT"
    decoded_token = JWT.decode token, hmac_secret, true, algorithm: "HS256"

    Struct.new(:token, :decoded_token).new(token, decoded_token)
  end
end
