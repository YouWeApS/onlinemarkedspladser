require "rails_helper"

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:user) { create :user }
  let(:access_token) { user.access_tokens.create!.token }

  it "successfully connects" do
    connect "/cable?access_token=#{access_token}"
    expect(connection.current_user).to eq user
  end

  it "rejects connection" do
    expect { connect "/cable" }.to have_rejected_connection
  end
end
