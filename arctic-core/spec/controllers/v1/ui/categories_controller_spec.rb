# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Ui::CategoriesController, type: :controller do
  it { is_expected.to be_a V1::Ui::ApplicationController }

  let(:account) { create :account }

  let(:user) { create :user, accounts: [account] }

  let(:shop) { create :shop, account: account }

  let(:vendor) { create :vendor }

  let!(:config) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: vendor }

  let(:params) do
    {
      vendor_id: vendor.id,
      account_id: account.id,
      shop_id: shop.id,
    }
  end

  describe '#index' do
    let(:action) { get :index, params: params }

    let!(:category_map1) { create :category_map, vendor_shop_configuration: config }

    it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'product:read'

      it_behaves_like :http_status, 200

      it { expect(action).to match_response_schema 'ui/category_maps' }

      it 'only shows categories for the current vendor and shop' do
        other_shop = create :shop, account: account
        config = create :vendor_shop_dispersal_configuration, shop: other_shop, vendor: vendor
        other_category = create :category_map, vendor_shop_configuration: config
        action
        ids = JSON.parse(response.body).collect { |j| j['id'] }
        expect(ids).not_to include other_category.id
        expect(ids).to include category_map1.id
      end
    end
  end

  describe '#destroy' do
    let(:action) { delete :destroy, params: params }

    let!(:category_map1) { create :category_map, vendor_shop_configuration: config }

    before { params.merge! id: category_map1.id }

    it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'product:write'

      it_behaves_like :http_status, 204

      it { expect { action }.to change { config.reload.category_maps.count }.by(-1) }
    end
  end

  describe '#create' do
    let(:action) { post :create, params: params }

    before do
      params.merge! \
        source: 'hjelme',
        value: {
          browser_node: '1939590031',
          classification: 'Clothing',
          type: 'Hat',
          variation_theme: 'SizeColor',
        }
    end

    it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'product:write'

      it_behaves_like :http_status, 201

      it { expect(action).to match_response_schema 'ui/category_map' }

      it { expect { action }.to change { config.reload.category_maps.count }.by(1) }
    end
  end
end
