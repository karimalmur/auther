# frozen_string_literal: true

require "dry/monads"
require_relative "util/error"

module Auther
  # Authentication logic for a `Resource` (like a rails User model).
  # Classes that includes this module is assumed to have __password_digest=__
  # method.
  # To use with rails, be sure your model has __password_digest__ column, if not, add it:
  #     # If your resource is called User
  #     rails g migration add_password_digest_to_users password_digest:string
  #     # then include __Resource__ into your rails model
  #     class User < ActiveRecord::Base
  #       include Auther::Resource
  #     end
  #     # Then you can set a user's password
  #     user = User.new
  #     user.set_password("password")
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

    # @description: Hashes a user's password
    # @param [string] password: The unencrypted user's __password__
    # @return Result::Success[String]: Hashed password
    # @errors [ERROR_PASSWORD_CANT_BE_NIL, ERROR_PASSWORD_TO_LONG]
    # rubocop:disable Naming/AccessorMethodName
    def set_password(password)
      yield validated_password_presence(password)
      yield validated_password_length(password)

      Success(self.password_digest = ::Auther::Encryption.password_digest(password))
    end
    # rubocop:enable Naming/AccessorMethodName

    # Returns +self+ if the password is correct, otherwise +false+.
    # @param [string] password: The unencrypted password to be authenticated.
    # @return [Self, nil]: The resource being authenticated on success. +nil+ otherwise.
    def authenticate_password(password)
      return Success(self) if ::Auther::Encryption.compare_password(password_digest, password)

      Failure()
    end

    protected

    def validated_password_presence(password)
      return Success(password) unless password.nil?

      Failure(
        Error.new(
          ERROR_PASSWORD_CANT_BE_NIL,
          "password can not be nil"
        )
      )
    end

    def validated_password_length(password)
      return Success(password) if password.bytesize <= MAX_PASSWORD_LENGTH_ALLOWED

      Failure(
        Error.new(
          ERROR_PASSWORD_TO_LONG,
          "extra characters in passwords of length more than 72 bytes are ignored by BCrypt"
        )
      )
    end
  end
end
