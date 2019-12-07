# frozen_string_literal: true

RSpec.describe ::Auther do
  describe "configuration" do
    it "is configured by default" do
      expect(::Auther.configuration.token_options.signing_algorithm).to eq(
        ::Auther::TokenConfig::HMAC.HS256
      )
    end

    it "can be configured" do
      ::Auther.configure do |config|
        config.token_config do |token_options|
          token_options.signing_algorithm = ::Auther::TokenConfig::RSA.RS256
        end
      end

      expect(::Auther.configuration.token_options.signing_algorithm).to eq(
        ::Auther::TokenConfig::RSA.RS256
      )
    end
  end
end
