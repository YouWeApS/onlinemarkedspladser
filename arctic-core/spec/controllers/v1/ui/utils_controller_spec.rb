require 'rails_helper'

RSpec.describe V1::Ui::UtilsController, type: :controller do
  it { is_expected.to be_a V1::Ui::ApplicationController }

  let!(:user) { create :user }

  let(:params) { {} }

  describe '#currencies' do
    let(:action) { get :currencies, params: params }

    it_behaves_like :http_status, 401

    context 'authenticated correctly' do
      include_context :authenticated

      it_behaves_like :http_status, 200

      it { expect(action).to match_response_schema 'ui/currencies' }
    end
  end
end
