# frozen_string_literal: true

require("bcrypt")

module Auther
  # Helper for creating & comparing password digests
  module Encryption
    # Creates a hashed digest from the given __password__.
    # The cost factor is __config[:encryption_cost]__ if present.
    # Otherwise it defaults to BCrypt's default cost (12).
    # @param password [String]: the unencrypted password.
    # @return [String]: Password digest of __password__
    def self.password_digest(password)
      cost = ::Auther.configuration.encryption_cost || BCrypt::Engine.cost
      BCrypt::Password.create(password, cost: cost)
    end

    # Compares a potential secret against the hash
    # @param password_digest [String]: The password hash you want to compare against.
    # @param password [String]: The potential secret.
    def self.compare_password(password_digest, password)
      BCrypt::Password.new(password_digest).is_password?(password)
    end
  end
end
