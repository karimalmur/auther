# frozen_string_literal: true

module Auther
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :resource_name, :resource_identifiers, :secret_key, :encryption_cost

    def initialize
      @resource_name = nil
      @resource_identifiers = [:email]
      @secret_key = nil
      @encryption_cost = 11
    end
  end
end
