# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductMerger do
  subject { instance }

  let(:instance) { described_class.new product, options }

  let(:shop) { create :shop }
  let(:vendor) { create :vendor }
  let!(:config) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: vendor }

  let(:product) { create :product, :with_prices, master: master, shop: shop, categories: [] }

  let!(:shadow_product) { create :shadow_product, product: product, vendor_shop_configuration: config, brand: 'Addidas', categories: %w[shadow] }

  let(:master) { create :product, color: 'Blue', shop: shop, categories: %w[master] }

  let!(:master_shadow) do
    create :shadow_product, product: master, vendor_shop_configuration: config, material: 'Silk'
  end

  let(:category) { create :category_map, vendor_shop_configuration: config, source: 1, value: { a: :b } }

  let(:options) do
    {
      vendor: vendor,
    }
  end

  its(:product) { is_expected.to eql product }
  its(:master) { is_expected.to eql master }
  its(:vendor) { is_expected.to eql vendor }
  its(:shadow) { is_expected.to eql product.shadow_product(vendor) }

  describe '#result' do
    subject { instance.result }

    its(:color) { is_expected.to eql 'Blue' }
    its(:material) { is_expected.to eql 'Silk' }
    its(:brand) { is_expected.to eql 'Addidas' }
    its(:categories) { is_expected.to match_array %w[shadow] }
    its(:deleted_at) { is_expected.to be_nil }

    describe 'original_price' do
      subject { instance.result.original_price.price }
      it { is_expected.to eql Money.new(2000, 'SEK') }
    end

    describe 'offer_price' do
      subject { instance.result.offer_price.price }
      it { is_expected.to eql Money.new(1000, 'USD') }
    end

    context 'missing vendor' do
      before { options.delete :vendor }

      its(:color) { is_expected.to eql 'Blue' }
      its(:material) { is_expected.to be_nil }
      its(:brand) { is_expected.to be_nil }
      its(:categories) { is_expected.to match_array %w[master] }
    end

    context 'no master' do
      before { product.update master: nil }

      its(:color) { is_expected.to be_nil }
      its(:material) { is_expected.to be_nil }
      its(:brand) { is_expected.to eql 'Addidas' }
    end

    context 'is master' do
      before { master.update ean: nil }
      let(:instance) { described_class.new master, options }
      its(:ean) { is_expected.to eql product.ean }
    end

    describe 'deleted master_product' do
      before { master_shadow.destroy }
      its(:deleted_at) { is_expected.to be_present }
    end

    describe 'deleted shadow product' do
      before { shadow_product.destroy }
      its(:deleted_at) { is_expected.to be_present }
    end

    describe 'updated shadow product' do
      before { shadow_product.update name: 'abc' }
      its(:updated_at) { is_expected.to be_within(1.second).of shadow_product.updated_at }
    end

    describe 'shadow product price' do
      context 'overriding original price' do
        subject { instance.result.original_price.price }

        before do
          shadow_product.update \
            original_price: create(:product_price, cents: 1244, currency: 'DKK')
        end

        it { is_expected.to eql Money.new(1244, 'DKK') }
      end

      context 'overriding offer price' do
        subject { instance.result.offer_price.price }

        before do
          shadow_product.update \
            offer_price: create(:product_price, cents: 10, currency: 'EUR')
        end

        it { is_expected.to eql Money.new(10, 'EUR') }
      end
    end
  end
end
