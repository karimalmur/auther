# frozen_string_literal: true

RSpec.describe ::Auther do
  describe "configuration" do
    it "is configured by default" do
      expect(::Auther.configuration.token_options.algorithm).to eq(
        ::Auther::TokenConfig::HMAC.HS256
      )
    end

    it "can be configured" do
      algorithm = ::Auther.token_options.algorithm
      ::Auther.configure do |config|
        config.token_config do |token_options|
          token_options.algorithm = ::Auther::TokenConfig::RSA.RS256
        end
      end

      expect(::Auther.configuration.token_options.algorithm).to eq(
        ::Auther::TokenConfig::RSA.RS256
      )

      ::Auther.configure do |config|
        config.token_config do |token_options|
          token_options.algorithm = algorithm
        end
      end
    end
  end
end
