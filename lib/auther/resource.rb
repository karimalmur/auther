# frozen_string_literal: true

require "dry/monads"
require_relative "util/error"

module Auther
  # Authentication logic for a `Resource` (like a rails User model).
  # Classes that includes this module is assumed to have __password_digest=__
  # method.
  #
  # To use with rails, be sure your model has __password_digest__ column, if not, add it:
  #     # If your resource is called User
  #     rails g migration add_password_digest_to_users password_digest:string
  #
  # == Examples
  #
  #     class User < ActiveRecord::Base
  #       include Auther::Resource
  #     end
  #     # Then you can set a user's password
  #     user = User.new
  #     user.set_password("password")
  #     # OR
  #     user.
  #       set_password("password").
  #       either(
  #         -> user { user.save }, # Success
  #         -> user { user.errors.add(:invalid_password) } # Failure
  #       )
  #     # NOTE: You are responsible of persisting changes to the resource
  #     # And you can validate password:
  #     user.authenticate_password("password") #=> Success(user)
  module Resource
    include Dry::Monads[:result, :do]

    def self.included(base)
      base.class_eval { attr_reader :password }
    end

    # Borrowed from SecurePassword - Rails
    # BCrypt hash function can handle maximum 72 bytes, and if we pass
    # password of length more than 72 bytes it ignores extra characters.
    # Hence need to put a restriction on password length.
    MAX_PASSWORD_LENGTH_ALLOWED = 72

    ERROR_PASSWORD_CANT_BE_NIL = :password_cant_be_nil
    ERROR_PASSWORD_TO_LONG = :password_is_too_long
    ERROR_INVALID_PASSWORD_CONFIRMATION = :invalid_password_confirmation

    # @description: Hashes a user's password.
    # @param [String] password: The unencrypted user's __password__.
    # @param [String] password_confirmation(Option):
    #   Password confirmation provided by user. Default: nil.
    # @param [Boolean] validate_confirmation(Option):
    #   If true, __Auther__ will validate the equality of __password__ and __password_confirmation__.
    #   Otherwise, __Auther__ will ignore __password_confirmation__. Default: false.
    # @return Result::Success[Resource]: self.
    # @errors [ERROR_PASSWORD_CANT_BE_NIL, ERROR_PASSWORD_TO_LONG].
    def set_password(password, password_confirmation: nil, validate_confirmation: false)
      yield validated_password_presence(password)
      yield validated_password_length(password)
      yield validated_password_confirmation(password, password_confirmation, validate_confirmation)

      self.password_digest = ::Auther::Encryption.password_digest(password)
      Success(self)
    end

    # Returns +self+ if the password is correct, otherwise +false+.
    # @param [string] password: The unencrypted password to be authenticated.
    # @return [Self, nil]: The resource being authenticated on success. +nil+ otherwise.
    def authenticate_password(password)
      return Success(self) if ::Auther::Encryption.compare_password(password_digest, password)

      Failure()
    end

    protected

    def validated_password_presence(password)
      return Success() unless password.nil?

      Failure(
        Error.new(
          ERROR_PASSWORD_CANT_BE_NIL,
          "password can not be nil"
        )
      )
    end

    def validated_password_length(password)
      return Success() if password.bytesize <= MAX_PASSWORD_LENGTH_ALLOWED

      Failure(
        Error.new(
          ERROR_PASSWORD_TO_LONG,
          "extra characters in passwords of length more than 72 bytes are ignored by BCrypt"
        )
      )
    end

    def validated_password_confirmation(password, password_confirmation, validate_confirmation)
      if validate_confirmation && password_confirmation != password
        return Failure(
          Error.new(
            ERROR_INVALID_PASSWORD_CONFIRMATION,
            "invalid password confirmation"
          )
        )
      end

      Success()
    end
  end
end
