# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductPriceExchange do
  let(:instance) { described_class.new pp, options }
  let(:shop) { create :shop }
  let(:vendor) { create :vendor }
  let(:pp) { create :product_price, price: Money.new(100, 'DKK') }
  let(:options) { {} }

  let!(:config) do
    create :vendor_shop_dispersal_configuration,
      shop: shop,
      vendor: vendor,
      currency_config: {
        currency: 'SEK',
      }
  end

  describe '#price' do
    subject { instance.price }

    it { is_expected.to eql Money.new(100, 'DKK') }

    context 'with options' do
      let(:options) do
        {
          shop: shop,
          vendor: vendor,
        }
      end

      context 'private exchange rates' do
        let!(:conversion_rate) do
          create :currency_conversion,
            shop: shop,
            from_currency: 'DKK',
            to_currency: 'SEK',
            rate: 1
        end

        it { is_expected.to eql Money.new(100, 'SEK') }

        context 'with price adjustment' do
          before { config.update price_adjustment_value: 15.0 }

          it { is_expected.to eql Money.new(115, 'SEK') }
        end

        context 'with negative price adjustment' do
          before { config.update price_adjustment_value: -7.5 }

          it { is_expected.to eql Money.new(92, 'SEK') }
        end
      end
    end
  end
end
