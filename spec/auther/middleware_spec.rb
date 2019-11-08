# frozen_string_literal: true

RSpec.describe Auther::Middleware do
  it "should insert auther instance into rack env" do
    env = env_with_params
    setup_rack(success_app).call(env)

    expect(env["auther"]).to be_an_instance_of(Auther::Auther)
  end
end
