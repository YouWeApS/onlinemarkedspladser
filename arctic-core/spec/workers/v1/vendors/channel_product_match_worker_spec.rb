# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Vendors::ChannelProductMatchWorker, type: :worker, vcr: :product_validator do
  it { is_expected.to be_processed_in :product_matches }
  it { is_expected.to save_backtrace }
  it { is_expected.to be_retryable true }

  let!(:channel1) { create :channel }
  let!(:vendor1) { create :vendor, channel: channel1 }
  let!(:vendor2) { create :vendor, channel: channel1 }

  let!(:channel2) { create :channel }
  let!(:vendor3) { create :vendor, channel: channel2 }
  let!(:vendor4) { create :vendor, channel: channel2 }

  let(:instance) { described_class.new }
  let(:perform) { instance.perform(shop_id, product_id) }

  let(:shop) { create :shop }
  let(:shop_id) { shop.id }

  let!(:user) { create :user, accounts: [shop.account] }

  let!(:config1) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: vendor2 }
  let!(:config2) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: vendor4 }

  let(:master) { create :product, shop: shop }

  let(:product) { create :product, shop: shop, master: master }
  let(:product_id) { product.id }

  context 'invalid shop_id' do
    let(:shop_id) { 'hello' }
    it 'Logs the warning' do
      expect(Sidekiq.logger).to receive(:warn)
        .with("Failed to find Product(#{product_id}) in Shop(hello)")
      perform
    end
  end

  context 'invalid product_id' do
    let(:product_id) { 'hello' }
    it 'Logs the warning' do
      expect(Sidekiq.logger).to receive(:warn)
        .with("Failed to find Product(hello) in Shop(#{shop.id})")
      perform
    end
  end

  context 'product not associated with shop' do
    let(:product) { create :product }
    it 'Logs the warning' do
      expect(Sidekiq.logger).to receive(:warn)
        .with("Failed to find Product(#{product_id}) in Shop(#{shop.id})")
      perform
    end
  end

  context 'matching master product' do
    let(:product_id) { master.id }

    it 'also matches variants' do
      expect(described_class).to receive(:perform_async).with(shop.id, product.id)
      perform
    end
  end

  it 'calls validates the product with the vendor' do
    expect(ProductValidator).to receive(:new).twice.and_call_original
    perform
  end

  it 'creates a channel-product match per distribution vendor' do
    expect { perform }.to change { VendorProductMatch.count }.by(2)
    expect(product.vendors).to match_array [vendor4, vendor2]
  end

  it 'broadcasts the change' do
    expect(ProductsChannel).to receive(:broadcast_to).twice
    perform
  end

  it 'preheats the product cache' do
    expect(ProductCache).to receive(:write)
    perform
  end

  it 'merges the shadow product in before matching' do
    skip "Fails periodically. Fail with seed 20870. Pass with seed 64998"
    create :shadow_product, product: product, vendor: vendor2, color: 'Blue'

    json = {
      sku: product.sku,
      brand: nil,
      categories: [],
      color: 'Blue',
      currency: '',
      description: 'Proudct description',
      dispersed_at: nil,
      ean: product.ean,
      images: [],
      manufacturer: nil,
      master_sku: nil,
      material: nil,
      name: product.name,
      price: '',
      size: nil,
      stock_count: 1,
    }.to_json

    expect(JSON::Validator).to receive(:fully_validate).with({}, json).at_least(:once).and_call_original

    perform
  end
end
