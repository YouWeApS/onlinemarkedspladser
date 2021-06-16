require "rails_helper"

RSpec.describe ProductCache do
  let!(:product) { create :product }
  let!(:shadow1) { create :shadow_product, product: product }
  let!(:shadow2) { create :shadow_product, product: product }

  describe '.write' do
    context 'given a product' do
      subject { described_class.write product }

      it 're-writes the cache for each of the shadow products' do
        expect(ProductCache).to receive(:write).with(product).and_call_original
        expect(ProductCache).to receive(:write).with(shadow1)
        expect(ProductCache).to receive(:write).with(shadow2)
        subject
      end
    end

    context 'given a shadow product' do
      subject { described_class.write shadow1 }

      it 'writes the cache' do
        json = V1::Ui::ProductBlueprint.render_as_hash shadow1, vendor: shadow1.vendor
        expect(Rails.cache).to receive(:write).with [shadow1.vendor.id, shadow1.id], json
        subject
      end
    end
  end

  describe '.clear' do
    let(:shadow_products) { create_list :shadow_product, 2 }

    subject { described_class.clear shadow_products }

    before do
      shadow_products.each do |s|
        ProductCache.write s
      end
    end

    it 'clears the caches' do
      shadow_products.each do |s|
        expect(Rails.cache.read([s.vendor.id, s.id])).to be_present
      end

      subject

      shadow_products.each do |s|
        expect(Rails.cache.read([s.vendor.id, s.id])).to be_nil
      end
    end

    context 'given a product' do
      before { shadow_products << create(:product) }
      it { expect { subject } .to raise_error ArgumentError, 'only available for ShadowProduct instances' }
    end
  end

  describe '.fetch' do
    context 'given a product' do
      subject { described_class.fetch product, vendor }
      let(:vendor) { nil }

      it 're-writes the cache for each of the shadow products' do
        expect(ProductCache).to receive(:fetch).with(product, nil).and_call_original
        expect(ProductCache).to receive(:fetch).with(shadow1, nil)
        expect(ProductCache).to receive(:fetch).with(shadow2, nil)
        subject
      end

      context 'given vendor' do
        let(:vendor) { create :vendor }

        it 're-writes the cache for each of the shadow products with the vendor' do
          expect(ProductCache).to receive(:fetch).with(product, vendor).and_call_original
          expect(ProductCache).to receive(:fetch).with(shadow1, vendor)
          expect(ProductCache).to receive(:fetch).with(shadow2, vendor)
          subject
        end
      end
    end

    context 'given a shadow product' do
      subject { described_class.fetch shadow1, vendor }
      let(:vendor) { nil }

      it 'fetches the cache' do
        expect(Rails.cache).to receive(:fetch).with [shadow1.vendor.id, shadow1.id]
        subject
      end

      context 'given a vendor' do
        let(:vendor) { create :vendor }

        it 'fetches the cache with specific vendor' do
          expect(Rails.cache).to receive(:fetch).with [vendor.id, shadow1.id]
          subject
        end
      end
    end
  end
end
