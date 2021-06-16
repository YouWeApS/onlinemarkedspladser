# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Vendors::ProductBlueprint do
  subject { Hashie::Mash.new described_class.render_as_hash(product, options) }
  let(:product) { create :product, :with_prices }

  let(:options) { {} }

  let(:expected_price) do
    {
      cents: 2000,
      currency: 'SEK',
      expires_at: nil,
    }.as_json
  end

  let(:expected_offer_price) do
    {
      cents: 1000,
      currency: 'USD',
      expires_at: nil,
    }.as_json
  end

  its(:name) { is_expected.to eql(product.name) }
  its(:sku) { is_expected.to eql(product.sku) }
  its(:stock_count) { is_expected.to eql(product.stock_count) }
  its(:original_price) { is_expected.to eql expected_price }
  its(:offer_price) { is_expected.to eql expected_offer_price }

  it { is_expected.to match_schema('vendors/product') }

  context 'with vendor option' do
    let(:vendor) { create :vendor }

    let!(:config) do
      create :vendor_shop_dispersal_configuration, vendor: vendor
    end

    let!(:category_map) do
      create :category_map,
        vendor_shop_configuration: config,
        source: 'a',
        value: { group: 'A' }
    end

    before { options[:vendor] = vendor }

    its(:categories) { is_expected.to match_array [category_map.value] }
  end

  describe 'filtered product fields' do
    before { options[:fields] = %i[sku] }

    it { expect(subject).to eql 'sku' => product.sku }
  end

  describe 'currency conversion' do
    let(:shop) { product.shop }
    let(:vendor) { config.vendor }

    let!(:config) do
      create :vendor_shop_configuration,
        shop: shop,
        currency_config: {
          currency: 'GBP',
        }
    end

    let!(:conversion1) do
      create :currency_conversion,
        shop: shop,
        from_currency: 'SEK',
        to_currency: 'GBP',
        rate: 2
    end

    let!(:conversion2) do
      create :currency_conversion,
        shop: shop,
        from_currency: 'USD',
        to_currency: 'GBP',
        rate: 2
    end

    let(:expected_price) do
      {
        cents: 4000,
        currency: 'GBP',
        expires_at: nil,
      }.as_json
    end

    let(:expected_offer_price) do
      {
        cents: 2000,
        currency: 'GBP',
        expires_at: nil,
      }.as_json
    end

    before do
      options[:shop] = shop.reload
      options[:vendor] = vendor
    end

    its(:original_price) { is_expected.to eql expected_price }
    its(:offer_price) { is_expected.to eql expected_offer_price }

    context 'no matching currency conversion' do
      before do
        conversion1.destroy
        conversion2.destroy
      end
      its(:original_price) { is_expected.not_to eql expected_price }
      its(:offer_price) { is_expected.not_to eql expected_offer_price }
    end
  end
end
