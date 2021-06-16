# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:instance) { build :product }
  subject { instance }

  it { is_expected.to belong_to :shop }
  it { is_expected.to belong_to :master }
  it { is_expected.to belong_to :offer_price }
  it { is_expected.to belong_to :original_price }

  it { is_expected.to have_many(:raw_product_data).dependent(:destroy) }
  it { is_expected.to have_many(:images).dependent(:destroy) }
  it { is_expected.to have_many(:shadow_products).dependent(:destroy) }
  it { is_expected.to have_many(:vendor_product_matches).dependent(:destroy) }
  it { is_expected.to have_many(:variants).dependent(:destroy) }
  it { is_expected.to have_many(:dispersals).dependent(:destroy) }
  it { is_expected.to have_many :vendors }

  it_behaves_like :having_product_attributes

  it 'sanitizes the sku at assignment' do
    expect { instance.sku = "hello å'&." }.to change { instance.sku }.to('hello+')
  end

  it 'sanitizes the master_sku at assignment' do
    expect { instance.master_sku = "hello å'&." }.to change { instance.master_sku }.to('hello+')
  end

  it 'prevents setting master sku if equal to sku' do
    instance.sku = "hello å'&."
    instance.master_sku = "hello å'&."
    expect(instance.master_sku).to be_blank
    expect(instance.sku).to be_present
  end

  it 'cannot assing blank master_sku' do
    instance.master_sku = ' '
    expect(instance.master_sku).to be_nil
  end

  describe '#offer_price' do
    let(:product) { create :product, :with_prices }

    subject { product.offer_price }

    it { is_expected.to be_a ProductPrice }

    its(:price) { is_expected.to eql Money.new 1000, 'USD' }
  end

  describe '#original_price' do
    let(:product) { create :product, :with_prices }

    subject { product.original_price }

    it { is_expected.to be_a ProductPrice }

    its(:price) { is_expected.to eql Money.new 2000, 'SEK' }
  end

  describe '#master?' do
    before { instance.master_sku = 'something' }

    it 'returns false if master sku is present' do
      expect(instance.master?).to be_falsey
    end

    it 'returns true if master_sku is nil' do
      instance.master_sku = nil
      expect(instance.master?).to be_truthy
    end
  end

  describe '#variant?' do
    before { instance.master_sku = 'something' }

    it 'returns true if master sku is present' do
      expect(instance.variant?).to be_truthy
    end

    it 'returns false if master_sku is nil' do
      instance.master_sku = nil
      expect(instance.variant?).to be_falsey
    end
  end

  describe '#shadow_product' do
    let(:vendor) { create :vendor }
    let(:product) { create :product }
    let!(:config) { create :vendor_shop_configuration, vendor: vendor, shop: product.shop }
    subject { product.shadow_product vendor }

    it { is_expected.to be_a ShadowProduct }

    context 'shadow product has been destroyed' do
      let(:shadow_product) { create :shadow_product, product: product, vendor_shop_configuration: config }
      before { shadow_product.destroy }
      it { is_expected.to eql shadow_product }
    end
  end

  describe '#last_dispersed_at_for', :freeze do
    let!(:product) { create :product }
    let!(:vendor) { create :vendor }
    let(:config) { create :vendor_shop_collection_configuration, shop: product.shop, vendor: vendor }

    let!(:dispersal1) do
      create :dispersal,
        product: product,
        vendor_shop_configuration_id: config.id,
        updated_at: 5.minutes.ago
    end

    let!(:dispersal2) do
      create :dispersal,
        product: product,
        vendor_shop_configuration_id: config.id,
        state: :completed,
        updated_at: 2.minutes.ago
    end

    subject { product.last_dispersed_at_for(vendor) }

    it { is_expected.to be_nil }

    context 'with dispersal vendor' do
      let!(:config) { create :vendor_shop_dispersal_configuration, shop: product.shop, vendor: vendor }

      it { is_expected.to be_within(1.second).of(dispersal2.updated_at) }
    end
  end
end
