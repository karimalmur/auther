# frozen_string_literal: true

module Auther
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def self.token_options
    configuration.token_options
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
      Struct.new(*algorithms).new(*algorithms.map(&:to_s))
    end

    NO_SIGNING = "none"
    HMAC = build_options(:HS256, :HS384, :HS512)
    RSA = build_options(:RS256, :RS384, :RS512)
    ECDSA = build_options(:ES256, :ES384, :ES512)

    # Signing algorithm, and secret key
    attr_accessor :algorithm, :secret
    # Issuer claim
    attr_accessor :iss, :verify_iss, :verify_jti
    # Audience claim. Configures the default list of aud claims.
    # Audience claims provided to token encoding functions overwrite this option.
    attr_accessor :aud, :verify_aud
    # Expiration Time Claim & expiry leeway. Seconds
    attr_accessor :exp, :exp_leeway

    def initialize
      @iss        = nil
      @aud        = ""
      @exp        = 3600
      @algorithm  = HMAC.HS256
      @exp_leeway = 30
      @verify_iss = true
      @verify_jti = true
      @verify_aud = true
    end
  end
end
