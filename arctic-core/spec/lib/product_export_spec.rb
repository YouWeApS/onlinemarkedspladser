require 'rails_helper'

RSpec.describe ProductExport do
  let(:instance) { described_class.new vendor, shop }

  let(:vendor) { create :vendor }
  let(:shop) { create :shop }
  let!(:config) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: vendor }

  let!(:product1) { create :product, :with_prices, shop: shop, material: 'Leather' }
  let!(:product2) { create :product, shop: shop }
  let!(:product3) { create :product, shop: shop }

  let!(:shadow1) do
    product1.shadow_product(vendor).tap do |s|
      s.update \
        color: 'Blue',
        original_price: ProductPrice.create(cents: 8000, currency: 'DKK')
    end
  end

  let!(:shadow3) do
    product3.shadow_product(vendor).tap do |s|
      s.destroy
    end
  end

  let(:expected_csv) do
    <<~CSV.strip_heredoc
      brand;color;description;ean;manufacturer;master_sku;material;name;size;sku;gender;count;scent;original_currency;original_price;offer_currency;offer_price
      ;Blue;Product description;#{product1.ean};;;Leather;#{product1.name};;#{product1.sku};;;;GBP;9.34;GBP;7.67
      ;;Product description;#{product2.ean};;;;#{product2.name};;#{product2.sku};;;
    CSV
  end

  subject { instance }

  its(:shop) { is_expected.to eql shop }
  its(:vendor) { is_expected.to eql vendor }
  its(:url) { is_expected.to be_nil }

  before do
    allow(EuCentralBankWrapper.instance).to receive(:exchange_with)
      .with(Money.new(1000, 'USD'), 'GBP')
      .and_return Money.new(767, 'GBP')

    allow(EuCentralBankWrapper.instance).to receive(:exchange_with)
      .with(Money.new(8000, 'DKK'), 'GBP')
      .and_return Money.new(934, 'GBP')
  end

  describe '#generate', vcr: { name: :product_export, match_requests_on: %i[method] } do
    it 'generates the url' do
      expect { instance.generate }.to change { instance.url }.from(nil)
    end

    it 'generates a CSV file' do
      expect(FileUtils).to receive(:rm)
      instance.generate
      expect(File.read(instance.file)).to eql expected_csv
      FileUtils.rm_rf instance.file
    end
  end
end
