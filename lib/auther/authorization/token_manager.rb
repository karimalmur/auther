# frozen_string_literal: true

module Auther
  module Authorization
    class TokenManager
      class << self
        include Dry::Monads[:result]

        # @param [Auther::Authorization::Token] token: an instance of Token to be encoded.
        # @return [Array]: The encoded token.
        def encode(token)
          encoded_token = JWT.encode(
            token.payload.merge(token.claims),
            ::Auther.token_options.secret,
            ::Auther.token_options.algorithm,
            token.header
          )

          Success(encoded_token)
        rescue JWT::EncodeError, JWT::DecodeError => e
          Failure(e)
        end

        def decode(
          encoded_token,
          aud: ::Auther.token_options.aud,
          verify_aud: ::Auther.token_options.verify_aud
        )
          raw_token = JWT.decode(
            encoded_token,
            ::Auther.token_options.secret,
            ::Auther.token_options.algorithm != ::Auther::TokenConfig::NO_SIGNING,
            decoding_options(verify_aud, aud)
          )

          Success(Token.from_decoded_token(raw_token))
        rescue JWT::DecodeError => e
          Failure(e)
        end

        def decoding_options(verify_aud, aud = ::Auther.token_options.aud)
          {
            algorithm: ::Auther.token_options.algorithm,
            exp_leeway: ::Auther.token_options.exp_leeway,
            iss: ::Auther.token_options.iss,
            verify_iss: ::Auther.token_options.verify_iss,
            verify_jti: ::Auther.token_options.verify_jti,
            aud: aud,
            verify_aud: verify_aud
          }
        end
      end
    end
  end
end
