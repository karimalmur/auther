# frozen_string_literal: true

module Auther
  module Authorization
    class Token
      CLAIMS = %w[aud iss iat exp jti sub exp_leeway].freeze

      attr_reader :payload, :header, :aud, :iss, :iat, :exp, :jti, :sub, :exp_leeway

      def initialize(payload: {}, header: {}, claims: {}, with_claim_defaults: false)
        @payload = payload
        @header = header
        with_claim_defaults ? claims_with_defaults(claims) : self.claims = claims
      end

      def claims
        @claims ||= {
          aud: aud,
          iss: iss,
          iat: iat,
          exp: exp,
          jti: jti,
          sub: sub,
          exp_leeway: exp_leeway
        }.reject { |_, v| v.nil? }
      end

      def self.from_decoded_token(decoded_token)
        payload = decoded_token[0]
        header = decoded_token[1]

        claims = payload.slice(*Token::CLAIMS)

        Token.new(
          payload: payload.reject { |k, _| Token::CLAIMS.include?(k) },
          header: header,
          claims: claims
        )
      end

      def self.expiration_time(issued_at)
        issued_at + ::Auther.token_options.exp
      end

      def self.new_jti(issued_at, secret = ::Auther.token_options.secret)
        Digest::MD5.hexdigest("#{secret}:#{issued_at}")
      end

      private

      def claims=(claims = {})
        @aud = Array.wrap(claims["aud"])
        @iss = claims["iss"]
        @iat = claims["iat"]
        @exp = claims["exp"]
        @jti = claims["jti"]
        @exp_leeway = claims["exp_leeway"]
        @sub = claims["sub"]
      end

      def claims_with_defaults(claims = {})
        @aud = default_audience(claims["aud"])
        @iss = default_issuer(claims["iss"])
        @iat = default_issued_at(claims["iat"])
        @exp = default_expires_at(claims["exp"])
        @jti = default_jti(claims["jti"])
        @exp_leeway = default_exp_leeway(claims["exp_leeway"])
        @sub = claims["sub"]
      end

      def default_audience(aud)
        Array.wrap(aud || ::Auther.token_options.aud)
      end

      def default_issuer(iss)
        iss || ::Auther.token_options.iss
      end

      def default_issued_at(iat)
        iat || Time.now.to_i
      end

      def default_expires_at(exp, iat = self.iat)
        exp || Token.expiration_time(iat)
      end

      def default_jti(jti, iat = self.iat)
        jti || Token.new_jti(iat)
      end

      def default_exp_leeway(leeway)
        leeway || ::Auther.token_options.exp_leeway
      end
    end
  end
end
