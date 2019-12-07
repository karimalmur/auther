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
                  :confirmation_epxpiry_period_seconds, :token_options

    def initialize
      @resource_identifiers = %i[email username]
      @secret_key = nil
      @encryption_cost = 11
      @confirmation_epxpiry_period_seconds = 864_00 # 1 day
      @token_options = TokenConfig.new
    end

    def token_config
      @token_options ||= TokenConfig.new
      yield(@token_options)
    end
  end

  class TokenConfig
    def self.build_options(*algorithms)
      Struct.new(*algorithms).new(algorithms.map(&:to_s))
    end

    NO_SIGNING = "none"
    HMAC = build_options(:HS256, :HS384, :HS512)
    RSA = build_options(:RS256, :RS384, :RS512)
    ECDSA = build_options(:ES256, :ES384, :ES512)

    attr_accessor :signing_algorithm

    def initialize
      @signing_algorithm = HMAC.HS256
    end
  end
end
