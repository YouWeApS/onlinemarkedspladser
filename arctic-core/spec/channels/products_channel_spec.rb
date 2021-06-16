require "rails_helper"

RSpec.describe ProductsChannel, type: :channel do
  let(:user) { create :user }

  before do
    # initialize connection with identifiers
    stub_connection current_user: user
  end

  it "streams to products:user_id" do
    subscribe
    expect(subscription).to be_confirmed
    expect(streams).to include("products:#{user.id}")
  end
end
