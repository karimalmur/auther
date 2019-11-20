# frozen_string_literal: true

require "dry/monads"
require_relative "util/error"

module Auther
  module Confirmable
    include Dry::Monads[:result, :do]

    def self.included(base)
      base.class_eval do
        attr_accessor :confirmation_token, :confirmation_set_at, :confirmed_at
      end
    end

    ERROR_INVALID_CONFIRMATION_TOKEN = :invalid_confirmation_token
    ERROR_EXPIRED_CONFIRMATION_TOKEN = :expired_confirmation_token
    ERROR_RESOURCE_ALREADY_CONFIRMED = :resource_already_confirmed

    def set_confirmation_details
      self.confirmation_token = ::Auther::Encryption.secure_token
      self.confirmation_set_at = Time.now.utc
    end

    def confirm(token)
      yield validated_confirmation_token(token)
      yield validated_confirmation_token_expiry
      yield validated_resource_not_confirmed

      self.confirmation_token = self.confirmation_set_at = nil
      self.confirmed_at = Time.now.utc

      Success(self)
    end

    def confirmed?
      confirmed_at != nil
    end

    protected

    def validated_confirmation_token(token)
      return Success() if token == confirmation_token && token&.empty? == false

      Failure(
        Error.new(
          ERROR_INVALID_CONFIRMATION_TOKEN,
          "provided confirmation token is invalid"
        )
      )
    end

    def validated_confirmation_token_expiry
      return Success() unless token_epxired?

      Failure(
        Error.new(
          ERROR_EXPIRED_CONFIRMATION_TOKEN,
          "provided confirmation token is expired"
        )
      )
    end

    def validated_resource_not_confirmed
      return Success() if confirmed? != true

      Failure(
        Error.new(
          ERROR_RESOURCE_ALREADY_CONFIRMED,
          "can't confirm already confirmed resource"
        )
      )
    end

    def token_epxired?
      return true unless confirmation_set_at

      Time.now.utc >
        confirmation_set_at + ::Auther.configuration.confirmation_epxpiry_period_seconds
    end
  end
end
