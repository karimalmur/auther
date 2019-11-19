# frozen_string_literal: true

RSpec.describe ::Auther::Confirmable do
  class User
    include Auther::Confirmable
  end

  let(:user) { User.new }

  describe "#set_confirmation_details" do
    it "sets resource's confirmation_token & confirmation_set_at" do
      user.set_confirmation_details
      expect(user.confirmation_token).not_to be_empty
      expect(user.confirmation_set_at).to be_within(1.second).of(Time.now.utc)
    end
  end

  describe "#confirm" do
    before(:each) do
      user.set_confirmation_details
    end

    context "when token is invalid" do
      it "returns invalid_confirmation_token error" do
        result = user.confirm("invalid token")
        expect(result.failure?).to be(true)
        expect(result.failure.type).to eq(::Auther::Confirmable::ERROR_INVALID_CONFIRMATION_TOKEN)
      end
    end

    context "when token is expired" do
      before(:each) do
        allow(Time).to(
          receive(:now)
            .and_return(
              Time.now +
              ::Auther.configuration.confirmation_epxpiry_period_seconds +
              2.seconds
            )
        )
      end

      it "returns expired_confirmation_token error" do
        result = user.confirm(user.confirmation_token)
        expect(result.failure?).to be(true)
        expect(result.failure.type).to eq(::Auther::Confirmable::ERROR_EXPIRED_CONFIRMATION_TOKEN)
      end
    end

    context "when resource is already confirmed" do
      before(:each) { allow(user).to receive(:confirmed?).and_return(true) }

      it "returns resource_already_confirmed error" do
        result = user.confirm(user.confirmation_token)
        expect(result.failure?).to be(true)
        expect(result.failure.type).to eq(::Auther::Confirmable::ERROR_RESOURCE_ALREADY_CONFIRMED)
      end
    end

    context "when confirmation token is valid and not expired and resource is not confirmed" do
      before(:each) do
        @result = user.confirm(user.confirmation_token)
      end

      it "returns success" do
        expect(@result.success?).to be(true)
        expect(@result.success).to eq(user)
      end

      it "sets confirmed_at" do
        expect(@result.success.confirmed?).to be(true)
        expect(@result.success.confirmed_at).to be_within(1.second).of(Time.now.utc)
      end
    end
  end
end
