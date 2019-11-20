# frozen_string_literal: true

RSpec.describe Auther::Resource do
  class User
    include Auther::Resource
  end

  let(:user) { User.new }

  describe "#set_password" do
    context "when password is nil" do
      it "returns password_cant_be_nil error" do
        result = user.set_password(nil)
        expect(result.failure?).to be(true)
        expect(result.failure.type).to eq(Auther::Resource::ERROR_PASSWORD_CANT_BE_NIL)
      end
    end

    context "when password has more than 72 bytes" do
      it "returns password_is_too_long error" do
        result = user.set_password("a" * 73)
        expect(result.failure?).to be(true)
        expect(result.failure.type).to eq(Auther::Resource::ERROR_PASSWORD_TO_LONG)
      end
    end

    context "when validate_confirmation is true" do
      context "when password_confirmation is invalid" do
        it "returns invalid_password_confirmation error" do
          result = user.set_password(
            "password",
            password_confirmation: nil,
            validate_confirmation: true
          )

          expect(result.failure?).to be(true)
          expect(result.failure.type).to eq(Auther::Resource::ERROR_INVALID_PASSWORD_CONFIRMATION)

          result = user.set_password(
            "password",
            password_confirmation: "wrong",
            validate_confirmation: true
          )

          expect(result.failure?).to be(true)
          expect(result.failure.type).to eq(Auther::Resource::ERROR_INVALID_PASSWORD_CONFIRMATION)
        end
      end

      context "when password_confirmation is valid" do
        it "returns success with the resource" do
          result = user.set_password(
            "password",
            password_confirmation: "password",
            validate_confirmation: true
          )

          expect(result.success?).to be(true)
          expect(result.success).to eq(user)
          expect(
            Auther::Encryption.compare_password(result.success.password_digest, "password")
          ).to be(true)
        end
      end
    end

    context "when password is valid" do
      it "returns the hashed password" do
        result = user.set_password("my*password")
        expect(result.success?).to be(true)
        expect(
          Auther::Encryption.compare_password(result.success.password_digest, "my*password")
        ).to be(true)
      end
    end
  end

  describe "#authenticate_password" do
    before(:each) do
      user.set_password("password")
    end

    context "when password is invalid" do
      it "returns a failure" do
        expect(user.authenticate_password(nil).failure?).to be(true)
        expect(user.authenticate_password("wrong").failure?).to be(true)
      end
    end

    context "when password is valid" do
      it "returns a failure" do
        result = user.authenticate_password("password")
        expect(result.success?).to be(true)
        expect(result.value!).to eq(user)
      end
    end
  end
end
