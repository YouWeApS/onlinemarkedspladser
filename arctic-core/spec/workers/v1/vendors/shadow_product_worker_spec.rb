# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Vendors::ShadowProductWorker, type: :worker do
  it { is_expected.to be_processed_in :shadow_products }
  it { is_expected.to save_backtrace }
  it { is_expected.to be_retryable true }

  let(:shop) { create :shop }
  let(:product) { create :product, shop: shop, sku: 'product #1' }

  let(:vendor1) { create :vendor }
  let!(:config1) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: vendor1 }

  let(:vendor2) { create :vendor }
  let!(:config2) { create :vendor_shop_collection_configuration, shop: shop, vendor: vendor2 }

  let(:instance) { described_class.new }
  let(:perform) { instance.perform(product_id) }
  let(:product_id) { product.id }

  it 'creates a shadow instance for each of the shops vendors' do
    expect { perform }.to change { ShadowProduct.count }.by(2)
  end

  it 'handles pre-existing shadow' do
    create :shadow_product, product: product, vendor_shop_configuration: config1
    create :shadow_product, product: product, vendor_shop_configuration: config2
    expect { perform }.not_to raise_error
  end

  context 'vendor has sku_formatter' do
    before { vendor1.update sku_formatter: 'AlphaNumSku' }
    let(:shadow) { product.shadow_product vendor1 }
    let(:master) { create :product, shop: shop }
    let!(:shadow_master) { master.shadow_product(vendor1) }
    before { product.update master: master }

    it "stores the custom formatted sku" do
      expect { perform }.to change { shadow.reload.sku }.from(nil).to('product1')
    end
  end

  context 'product is a variant' do
    before { product.update ean: 'ean-1' }
    let(:shadow) { product.shadow_product vendor1 }
    let(:master) { create :product, shop: shop, ean: nil }
    let!(:shadow_master) { master.shadow_product(vendor1) }
    before { product.update master: master }

    it "stores the master product's shadow's id as the master_id" do
      expect { perform }.to change { shadow.reload.master_id }.from(nil).to(shadow_master.id)
    end

    it "updates the master's EAN number" do
      expect { perform }.to change { shadow.reload.product.master.ean }.from('').to 'ean-1'
    end
  end

  context 'product is a master' do
    let(:shadow) { product.shadow_product vendor1 }
    let(:variant) { create :product, shop: shop, master: product }
    let!(:shadow_variant) { variant.shadow_product(vendor1) }

    it "stores the variant's shadow's ids in the variant_ids" do
      expect { perform }.to change { shadow.reload.variant_ids }.from([]).to match([ shadow.id, shadow_variant.id])
    end
  end
end
