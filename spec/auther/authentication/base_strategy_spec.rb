# frozen_string_literal: true

RSpec.describe ::Auther::Authentication::Strategies::Base do
  describe ".identifier" do
    StrategyBase = ::Auther::Authentication::Strategies::Base
    class PasswordlessStrategy < StrategyBase; end
    class TokenAuthStrategy < StrategyBase; end

    it "returns downcased strategy class name with 'Strategy' suffix removed" do
      expect(PasswordlessStrategy.identifier).to eq("passwordless")
      expect(TokenAuthStrategy.identifier).to eq("tokenauth")
    end
  end
end
