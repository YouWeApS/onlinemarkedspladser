require "rails_helper"

RSpec.describe ProductValidator do
  let(:instance) { described_class.new product, options }

  let(:vendor) { create :vendor, :amazon }
  let(:shop) { create :shop, account: account }
  let(:account) { create :account }
  let!(:config) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: vendor }
  let(:product) { create :product, :with_prices, :with_images, shop: shop, categories: %w[a] }
  let!(:category) do
    create :category_map,
      vendor_shop_configuration: config,
      value: {
        browser_node: '1939590031',
        type: 'Clothing',
        classification: 'Outerwear',
        variatiwon_theme: 'Size-Material',
      }
  end

  let(:options) do
    {
      vendor: vendor,
    }
  end

  let(:expected_json) do
    V1::Vendors::ProductBlueprint.render_as_hash product, **options
  end

  describe '.new' do
    subject { instance }

    its(:product) { is_expected.to eql product }
    its(:options) { is_expected.to eql options }
    its(:json) { is_expected.to eql expected_json }
  end

  describe '#valid?' do
    subject { instance.valid? }

    it 'is valid' do
      VCR.use_cassette("product_validator") do
        is_expected.to be_truthy
      end
    end

    context 'validation_url is blank' do
      before { vendor.update validation_url: nil }

      it { is_expected.to be_falsey }

      it 'adds an error about the missing validation_url' do
        subject
        expect(instance.errors[:validation_url]).to \
          eql 'Validation url is missing from the vendor'
      end
    end

    context 'missing category' do
      before { category.destroy }

      it 'is invalid' do
        VCR.use_cassette("product_validator_missing_category") do
          is_expected.to be_falsey
        end
      end
    end
  end

  describe '#errors' do
    subject { instance.valid?; instance.errors }

    it 'is valid' do
      VCR.use_cassette("product_validator") do
        is_expected.to be_empty
      end
    end

    context 'missing category' do
      before { category.destroy }

      it 'is invalid' do
        VCR.use_cassette("product_validator_missing_category") do
          is_expected.to eql error: "undefined method `classify' for :missing_category_type:Symbol\nDid you mean?  class"
        end
      end
    end
  end

  describe '#validate_match (private)' do
    subject { instance.send :validate_match }

    before do
      expect(instance).to receive(:response).and_raise Faraday::ConnectionFailed, 'test'
    end

    it 'handles Faraday::ConnectionFailed' do
      expect(subject).to eql no_connection: 'Could not reach the vendor'
    end
  end
end
