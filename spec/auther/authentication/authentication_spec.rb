# frozen_string_literal: true

RSpec.describe ::Auther::Authentication do
  class TestStrategy < ::Auther::Authentication::Strategies::Base
    def authenticate; end
  end

  before(:each) do
    ::Auther::Authentication.strategies.clear
    ::Auther::Authentication.repositories.clear
  end

  describe ".add_authentication_strategy" do
    it "rejects strategies that don't inherit from 'Base' strategy" do
      expect { ::Auther::Authentication.add_authentication_strategy(Class.new) }
        .to raise_error(::Auther::InvalidStrategyBase)
    end

    it "rejects strategies that do not implement 'authenticate' method" do
      expect do
        ::Auther::Authentication
          .add_authentication_strategy(Class.new(::Auther::Authentication::Strategies::Base))
      end.to raise_error(::Auther::InvalidStrategyImplementation)
    end

    it "can add a valid strategy" do
      ::Auther::Authentication.add_authentication_strategy(TestStrategy)

      expect(
        ::Auther::Authentication.strategies.any? { |k, v| k == "test" && v == TestStrategy }
      ).to be(true)
    end
  end

  describe ".add_authentication_repository" do
    it "raises an error when target strategy does not exist" do
      repo = {}
      expect { ::Auther::Authentication.add_authentication_repository(repo, "invalid") }
        .to raise_error(::Auther::StrategyNotFound)
    end

    it "can add a repo associated with a strategy" do
      TestRepo = Class.new
      ::Auther::Authentication.add_authentication_strategy(TestStrategy)
      ::Auther::Authentication.add_authentication_repository(TestRepo, TestStrategy.identifier)

      expect(::Auther::Authentication.repositories[TestStrategy.identifier]).to eq(TestRepo)
    end
  end
end
