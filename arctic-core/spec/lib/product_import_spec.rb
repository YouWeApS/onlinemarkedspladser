require "rails_helper"

RSpec.describe ProductImport do
  let(:instance) { described_class.new vendor, shop, path }

  let(:path) { Rails.root.join('tmp' , 'products.csv').to_s }

  let(:shop) { create :shop }
  let(:vendor) { create :vendor }

  let!(:config) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: vendor }

  let(:product1) { create :product, :with_prices, shop: shop, color: 'Blue' }
  let!(:shadow1) { product1.shadow_product(vendor) }

  let(:product2) { create :product, shop: shop }

  let!(:shadow2) do
    product2.shadow_product(vendor).tap do |s|
      s.update \
        name: product2.name,
        ean: 'ean1'
    end
  end

  let(:product3) { create :product, shop: shop, color: 'Blue' }

  let!(:shadow3) do
    product3.shadow_product(vendor).tap do |s|
      s.update color: 'Red'
    end
  end

  let(:product4) { create :product, shop: shop }

  let!(:shadow4) do
    product3.shadow_product(vendor).tap do |s|
      s.destroy
    end
  end

  let(:desc) do
    <<~STR.strip_heredoc
      This is a
      multi-line

      description

      - with
      - some
      - formatting
    STR
  end

  before do
    CSV.open(path, "wb", col_sep: ';') do |csv|
      csv << %w[sku name description ean color original_price original_currency]
      csv << [product1.sku, 'Hello', desc, nil, 'Blue', '12', 'GBP']
      csv << [product2.sku, product2.name, nil, 'ean2', nil, nil, nil]
      csv << [product3.sku, nil, nil, nil, 'Blue', nil, nil]
      csv << [product4.sku, 'Bob', nil, nil, nil, nil, nil]
    end
  end

  subject { instance }

  describe '#initialize' do
    its(:path) { is_expected.to eql path }
    its(:shop) { is_expected.to eql shop }
    its(:vendor) { is_expected.to eql vendor }
  end

  describe '#save' do
    subject { Timecop.freeze(5.minutes.from_now) { instance.save } }

    it 'updates shadow product name' do
      expect { subject }.to change { shadow1.reload.name }.from(nil).to 'Hello'
    end

    it 'updates the product description' do
      expect { subject }.to change { shadow1.reload.description }.from(nil).to desc
    end

    it 'updates shadow product original price' do
      expect { subject }.to change { shadow1.reload.original_price.try :price }
        .from(nil)
        .to(Money.new(1200, 'GBP'))
    end

    it 'only updates shadow product values that differs from the product' do
      expect { subject }.not_to change { shadow1.reload.color }
    end

    it 'leaves other products alone' do
      expect { subject }.not_to change { shadow2.reload.name }
    end

    it 'clears product caches for changed products' do
      expect(ProductCache).to receive(:write).with(product1)
      expect(ProductCache).to receive(:write).with(product2)
      expect(ProductCache).to receive(:write).with(product3)
      expect(ProductCache).to receive(:write).with(product4)
      subject
    end

    it 'does not reactivate deleted products' do
      expect { subject }.not_to change { shadow4.reload.deleted_at }
    end

    it 'overrides the ean' do
      expect { subject }.to change { shadow2.reload.ean }.from('ean1').to('ean2')
    end

    it 'returns truthy' do
      expect(instance.save).to be_truthy
    end

    context 'shadow color and product color differs' do
      it 'updates the shadow color even if new color matches product color' do
        expect { subject }.to change { shadow3.reload.color }.from('Red').to('Blue')
      end
    end

    context 'with invalid sku' do
      let(:product3) { create :product, shop: shop }

      before do
        CSV.open(path, "wb") do |csv|
          csv << %w[sku name]
          csv << [product1.sku, 'Hello']
          csv << [product2.sku, product2.name]
          csv << [product3.sku, 'Product SKU injection']
        end
      end

      it "doesn't change any products" do
        expect { subject }.not_to change { product3.reload.name }
        expect { subject }.not_to change { product1.reload.name }
        expect { subject }.not_to change { product2.reload.name }
      end

      it 'returns falsey' do
        expect(instance.save).to be_falsey
      end
    end
  end
end
