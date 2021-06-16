# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Ui::ErrorsController, type: :controller do
  let(:account) { create :account }
  let!(:user) { create :user, accounts: [account] }
  let(:shop) { create :shop, account: account }
  let(:vendor) { create :vendor }
  let!(:config) { create :vendor_shop_configuration, shop: shop, vendor: vendor }

  let(:product) { create :product, shop: shop }
  let!(:shadow_product) { product.shadow_product vendor }
  let!(:error) { create :product_error, shadow_product: shadow_product }
  let!(:dispersal) { create :dispersal, product: product, vendor_shop_configuration: config, state: :failed }

  let(:params) do
    {
      account_id: account.id,
      shop_id: shop.id,
      vendor_id: vendor.id,
    }
  end

  describe '#destroy_all' do
    let(:action) { delete :destroy_all, params: params }

    before do
      params.merge! \
        product_id: shadow_product.id
    end

    it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'product:write'

      it_behaves_like :http_status, 200

      it { expect(action).to match_response_schema 'ui/product' }

      it { expect { action }.to change { shadow_product.reload.product_errors.count }.from(1).to(0) }

      it "sets the product's vendor-dispersal to pending" do
        expect { action }.to change { dispersal.reload.state }.from('failed').to('pending')
      end

      it "sets the updates the product's updated_at" do
        expect { action }.to change { product.reload.updated_at }
      end

      it 'removes all errors on the product' do
        error2 = create :product_error, shadow_product: shadow_product
        expect { action }.to change { shadow_product.reload.product_errors.count }.by(-2)
      end

      it 'fetches the product json' do
        expect(ProductCache).to receive(:write).with(shadow_product)
        action
      end

      it 'broadcasts the change' do
        expect(ProductBroadcast).to receive(:new).with(shadow_product).and_call_original
        action
      end
    end
  end

  describe '#destroy' do
    let(:action) { delete :destroy, params: params }

    before do
      params.merge! \
        product_id: shadow_product.id,
        id: error.id
    end

    it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'product:write'

      it_behaves_like :http_status, 200

      it { expect(action).to match_response_schema 'ui/product' }

      it { expect { action }.to change { shadow_product.reload.product_errors.count }.from(1).to(0) }

      it "sets the product's vendor-dispersal to pending" do
        expect { action }.to change { dispersal.reload.state }.from('failed').to('pending')
      end

      it "sets the updates the product's updated_at" do
        expect { action }.to change { product.reload.updated_at }
      end

      it 'fetches the product json' do
        expect(ProductCache).to receive(:write).with(shadow_product)
        action
      end

      it 'broadcasts the change' do
        expect(ProductBroadcast).to receive(:new).with(shadow_product).and_call_original
        action
      end
    end
  end
end
