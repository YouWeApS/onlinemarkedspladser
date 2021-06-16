require 'rails_helper'

RSpec.describe V1::Ui::ImagesController, type: :controller do
  let!(:account) { create :account }
  let!(:shop) { create :shop, account: account }
  let!(:vendor) { create :vendor }
  let!(:user) { create :user, accounts: [account] }
  let!(:config) { create :vendor_shop_configuration, shop: shop, vendor: vendor }

  let!(:product) { create :product, shop: shop }
  let!(:shadow_product) { create :shadow_product, product: product, vendor_shop_configuration: config }
  let!(:image1) { create :product_image, product: product, position: 1 }
  let!(:image2) { create :product_image, product: product, position: 2 }
  let!(:image3) { create :product_image, product: product, position: 3 }

  let(:params) do
    {
      account_id: account.id,
      shop_id: shop.id,
      vendor_id: vendor.id,
      product_id: shadow_product.id,
      id: image1.id,
      position: 2,
    }
  end

  describe '#update' do
    let(:action) { patch :update, params: params }

    it_behaves_like :http_status, 401

    context 'authenticated with incorrect scopes' do
      include_context :authenticated

      it_behaves_like :http_status, 403
    end

    context 'authenticated correctly' do
      include_context :authenticated, scopes: 'product:write'

      it_behaves_like :http_status, 200

      it 'changes the image posision' do
        expect { action }.to change { image1.reload.position }.from(1).to(2)
      end

      it 'moves the image at the new position' do
        expect { action }.to change { image2.reload.position }.from(2).to(1)
      end

      it 'does not move unaffected images' do
        expect { action }.not_to change { image3.reload.position }
      end

      it 'runs vendor matches' do
        expect(V1::Vendors::ChannelProductMatchWorker).to \
          receive(:perform_async).with(shop.id, product.sku)
        action
      end
    end
  end
end
