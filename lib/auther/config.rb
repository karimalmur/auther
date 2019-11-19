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
    attr_accessor :resource_identifiers, :secret_key, :encryption_cost,
                  :confirmation_epxpiry_period_seconds

    def initialize
      @resource_name = nil
      @resource_identifiers = [:email]
      @secret_key = nil
      @encryption_cost = 11
      @confirmation_epxpiry_period_seconds = 864_00 # 1 day
    end
  end
end
