# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Vendors::CurrenciesController, type: :controller do
  let(:shop) { create :shop }

  let!(:conversion) do
    create :currency_conversion,
      shop: shop,
      from_currency: :dkk,
      to_currency: :gbp,
      rate: 0.2
  end

  let(:params) { { shop_id: shop.id } }

  describe '#index' do
    let(:action) { get :index, params: params }

    it_behaves_like :unauthenticated

    context 'authenticated vendor' do
      include_context :authenticated_vendor

      let!(:config) { create :vendor_shop_collection_configuration, shop: shop, vendor: vendor }

      it { expect(action).to match_response_schema('vendors/currency_conversions') }
    end
  end

  describe '#update' do
    let(:action) { put :update, params: params }

    before do
      params.merge! \
        from_currency: :dkk,
        to_currency: :gbp,
        rate: 0.3
    end

    it_behaves_like :unauthenticated

    context 'authenticated vendor' do
      include_context :authenticated_vendor

      let!(:config) { create :vendor_shop_collection_configuration, shop: shop, vendor: vendor }

      it { expect { action }.to change { conversion.reload.rate }.from(0.2).to(0.3) }

      context 'create a new conversion' do
        before { params[:from_currency] = :usd }
        it { expect { action }.to change { shop.currency_conversions.count }.from(1).to(2) }
      end
    end
  end
end
