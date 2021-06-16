# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Vendors::ShopsController, type: :controller do
  describe '#index' do
    let(:action) { get :index }

    it_behaves_like :unauthenticated

    context 'authenticated vendor' do
      include_context :authenticated_vendor

      let!(:collection_config) { create :vendor_shop_collection_configuration, vendor: vendor }
      let!(:dispersal_config1) { create :vendor_shop_dispersal_configuration, vendor: vendor }
      let!(:dispersal_config2) { create :vendor_shop_dispersal_configuration, vendor: vendor, shop: dispersal_config1.shop }

      it_behaves_like :http_status, 200
      it_behaves_like :paginated

      it { expect(action).to match_response_schema 'vendors/shops' }

      it 'excludes disabled vendors' do
        dispersal_config1.update enabled: false
        action
        expect(JSON.parse(response.body)['dispersals']).to be_nil
        expect(JSON.parse(response.body)['collection']).not_to be_nil
      end
    end
  end

  describe '#show' do
    let(:action) { get :show, params: { id: id } }
    let(:id) { 1 }

    it_behaves_like :unauthenticated

    context 'authenticated vendor' do
      include_context :authenticated_vendor

      let!(:config) { create :vendor_shop_configuration, vendor: vendor }
      let(:id) { config.shop.id }

      it_behaves_like :http_status, 200

      it { expect(action).to match_response_schema 'vendors/shop' }
    end
  end

  describe '#products_synced' do
    let(:shop) { create :shop }

    let(:action) { patch :products_synced, params: { id: shop.id } }

    it_behaves_like :unauthenticated

    context 'authenticated vendor' do
      include_context :authenticated_vendor

      context 'collection vendor' do
        let!(:config) { create :vendor_shop_collection_configuration, vendor: vendor, shop: shop }

        it_behaves_like :http_status, 204

        it 'updates the collected_at', :freeze do
          action
          expect(config.reload.last_synced_at).to be_within(1.second).of(Time.zone.now)
        end
      end

      context 'dispersal vendor' do
        let!(:dispersal_config) { create :vendor_shop_dispersal_configuration, vendor: vendor, shop: shop }

        it_behaves_like :http_status, 204

        it 'updates the dispersed_at', :freeze do
          action
          expect(dispersal_config.reload.last_synced_at).to be_within(1.second).of(Time.zone.now)
        end
      end
    end
  end

  describe '#orders_synced' do
    let(:shop) { create :shop }

    let(:action) { patch :orders_synced, params: { id: shop.id } }

    it_behaves_like :unauthenticated

    context 'authenticated vendor' do
      include_context :authenticated_vendor

      context 'collection vendor' do
        let!(:config) { create :vendor_shop_collection_configuration, vendor: vendor, shop: shop }

        it_behaves_like :http_status, 204

        it 'updates the collected_at', :freeze do
          action
          expect(config.reload.orders_last_synced_at).to be_within(1.second).of(Time.zone.now)
        end
      end

      context 'dispersal vendor' do
        let!(:dispersal_config) { create :vendor_shop_dispersal_configuration, vendor: vendor, shop: shop }

        it_behaves_like :http_status, 204

        it 'updates the dispersed_at', :freeze do
          action
          expect(dispersal_config.reload.orders_last_synced_at).to be_within(1.second).of(Time.zone.now)
        end
      end
    end
  end
end
