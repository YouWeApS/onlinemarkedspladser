# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Ui::AccountsController, type: :controller do
  it { is_expected.to be_a V1::Ui::ApplicationController }

  let!(:user) { create :user }

  let(:account1) { create :account }
  let(:account2) { create :account }

  before do
    user.accounts << account1
    user.accounts << account2
    user.reload
  end

  describe '#index' do
    let(:action) { get :index }

    it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'user:write'

      it_behaves_like :http_status, 200

      it { expect(action).to match_response_schema 'ui/accounts' }

      it 'returns the right accounts' do
        action
        ids = JSON.parse(response.body).map { |j| j['id'] }
        expect(ids).to match_array [account1.id, account2.id]
      end
    end
  end
end
