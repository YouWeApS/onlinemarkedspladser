require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  let(:instance) { described_class.new }

  let(:user) { create :user }
  let(:session_token) { user.session_tokens.create!.id }

  before do
    _request = double \
      session: {
        session_token: session_token,
      }

    instance.instance_variable_set :@_request, _request
  end

  describe '#rollbar_user' do
    subject { instance.rollbar_user }

    it { is_expected.to eql instance.current_user }
  end

  describe '#current_user' do
    subject { instance.current_user }

    it { is_expected.to eql user }

    context 'invalid session_token' do
      let(:session_token) { 'hello' }

      it { is_expected.to be_nil }
    end
  end
end
