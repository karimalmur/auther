# frozen_string_literal: true

module Auther
  class Error
    attr_reader :type, :message

    def initialize(type, message)
      @type = type
      @message = message
    end
  end

  InvalidStrategyBase = Class.new(StandardError)
  InvalidStrategyImplementation = Class.new(StandardError)
  StrategyNotFound = Class.new(StandardError)
end
