# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Ui::VendorsController, type: :controller do
  it { is_expected.to be_a V1::Ui::ApplicationController }

  let!(:user) { create :user }

  let(:account) { create :account, users: [user] }

  let(:shop) { create :shop, account: account }

  let!(:vendor1) { create :vendor }
  let!(:vendor2) { create :vendor }

  let(:params) { {} }

  describe '#all' do
    let(:action) { get :all, params: params }

    it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'product:read'

      it_behaves_like :http_status, 200

      it { expect(action).to match_response_schema 'ui/vendors' }
    end
  end

  describe '#create' do
    before do
      params.merge! \
        account_id: account.id,
        shop_id: shop.id,
        vendor_id: vendor1.id
    end

    let(:action) { post :create, params: params }

    # it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'product:write'

      it_behaves_like :http_status, 201

      it { expect(action).to match_response_schema 'ui/vendor' }
    end
  end

  describe '#index' do
    before do
      params.merge! \
        account_id: account.id,
        shop_id: shop.id
    end

    let!(:config1) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: vendor1 }
    let!(:config2) { create :vendor_shop_collection_configuration, shop: shop, vendor: vendor2 }

    let(:action) { get :index, params: params }

    it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'product:read'

      it_behaves_like :http_status, 200

      it { expect(action).to match_response_schema 'ui/vendors' }

      it 'only returns the vendors configured for the shop' do
        action

        json = JSON.parse(response.body)
        ids = json.collect { |j| j['id'] }

        expect(ids).to match_array [vendor1.id, vendor2.id]
      end

      context 'filtering on vendor type' do
        context 'dispersal' do
          before { params.merge! type: :dispersal }

          it 'only returns the vendors configured as dispersal for the shop' do
            action

            json = JSON.parse(response.body)
            ids = json.collect { |j| j['id'] }

            expect(ids).to match_array [vendor1.id]
          end
        end

        context 'collection' do
          before { params.merge! type: :collection }

          it 'only returns the vendors configured as collection for the shop' do
            action

            json = JSON.parse(response.body)
            ids = json.collect { |j| j['id'] }

            expect(ids).to match_array [vendor2.id]
          end
        end
      end
    end
  end
end
