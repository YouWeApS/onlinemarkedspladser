require 'rails_helper'

RSpec.describe V1::Ui::Admin::AccountsController, type: :controller do
  it { is_expected.to be_a V1::Ui::Admin::ApplicationController }

  let!(:account1) { create :account }
  let!(:account2) { create :account }

  let(:user) { create :user }

  describe '#index' do
    let(:action) { get :index }

    it_behaves_like :admin_authenticated_endpoint

    context 'authenticated correctly' do
      include_context :authenticated_admin, scopes: 'admin:account:read'

      it_behaves_like :http_status, 200

      it { expect(action).to match_response_schema 'ui/admin/accounts' }

      it 'returns the right accounts' do
        action
        ids = JSON.parse(response.body).map { |j| j['id'] }
        expect(ids).to match_array [account1.id, account2.id]
      end
    end
  end

  describe '#create' do
    let(:params) do
      {
        name: 'New Account',
      }
    end

    let(:action) { post :create, params: params }

    it_behaves_like :admin_authenticated_endpoint, scopes: 'admin:account:write'

    context 'authenticated correctly' do
      include_context :authenticated_admin, scopes: 'admin:account:write'

      it_behaves_like :http_status, 200

      it { expect(action).to match_response_schema 'ui/admin/account' }

      it { expect { action }.to change { Account.count }.by(1) }
    end
  end
end
