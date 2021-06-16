# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Ui::ShopsController, type: :controller do
  it { is_expected.to be_a V1::Ui::ApplicationController }

  let(:account) { create :account }

  let!(:user) { create :user, accounts: [account] }

  let!(:shop1) { create :shop, account: account }

  let!(:shop2) { create :shop, account: account }

  let(:params) do
    {
      account_id: account.id,
    }
  end

  describe '#index' do
    let(:action) { get :index, params: params }

    it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'product:read'

      it_behaves_like :http_status, 200

      it { expect(action).to match_response_schema 'ui/shops' }

      it 'returns the right accounts' do
        action
        ids = JSON.parse(response.body).map { |j| j['id'] }
        expect(ids).to match_array [shop1.id, shop2.id]
      end
    end
  end
end
