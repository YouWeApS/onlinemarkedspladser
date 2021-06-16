# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Ui::ProductBlueprint do
  subject { instance }

  let(:vendor) { create :vendor }

  let(:shop) { create :shop }

  let!(:config) { create :vendor_shop_dispersal_configuration, shop: shop, vendor: vendor }

  let(:instance) do
    Hashie::Mash.new described_class.render_as_hash \
      shadow_product,
      vendor: vendor
  end

  let(:master_product) do
    create :product,
    shop: shop,
      material: 'Leather'
  end

  let(:master_shadow_product) { master_product.shadow_product(vendor) }

  let(:product) do
    create :product,
      :with_prices,
      shop: shop,
      color: 'Blue',
      master: master_product
  end

  let(:shadow_product) do
    product.shadow_product(vendor).tap do |shadow|
      shadow.update manufacturer: 'Adiddas'
    end
  end

  let(:expected_offer_price) do
    {
      cents: 1000,
      currency: 'USD',
      expires_at: nil,
    }.as_json
  end

  let(:expected_original_price) do
    {
      cents: 2000,
      currency: 'SEK',
      expires_at: nil,
    }.as_json
  end

  it { is_expected.to match_schema('ui/product') }

  its(:id) { is_expected.to eql shadow_product.id }
  its(:name) { is_expected.to be_nil }
  its(:description) { is_expected.to be_nil }
  its(:color) { is_expected.to be_nil }
  its(:brand) { is_expected.to eql(product.brand) }
  its(:manufacturer) { is_expected.to eql('Adiddas') }
  its(:material) { is_expected.to be_nil }
  its(:sku) { is_expected.to be_nil }
  its(:master_sku) { is_expected.to be_nil }
  its(:offer_price) { is_expected.to be_nil }
  its(:original_price) { is_expected.to be_nil }
  its(:enabled) { is_expected.to eql false }

  # Different because size is an internal method in Hashie::Mash
  it { expect(subject['size']).to be_nil }

  describe '#dispersal_state' do
    subject { instance.dispersal_state }

    it 'returns the latest updated dispersal state' do
      dispersal1 = create :dispersal, state: :completed, vendor_shop_configuration: config, product: product
      dispersal2 = create :dispersal, state: :inprogress, vendor_shop_configuration: config, product: product
      expect(subject).to eql 'inprogress'
    end
  end

  describe '#variants' do
    subject { instance.variants }

    it 'returns a list of master and variants' do
      expect(subject).to eql \
        instance.id => product.sku
    end
  end

  describe '#last_dispersed_at' do
    subject { instance.last_dispersed_at }
    it { is_expected.to be_nil }

    context 'inprogress dispersal' do
      before { create :dispersal, product: product, vendor_shop_configuration: config, state: :inprogress }
      it { is_expected.to be_nil }
    end

    context 'completed dispersal' do
      before { create :dispersal, product: product, vendor_shop_configuration: config, state: :completed }
      it { is_expected.to be_present }
    end

    context 'prv completed dispersal, current inprogress' do
      let!(:completed) { create :dispersal, product: product, vendor_shop_configuration: config, state: :completed }
      before { create :dispersal, product: product, vendor_shop_configuration: config, state: :inprogress }
      it { is_expected.to be_within(1.second).of completed.updated_at }
    end
  end

  describe '#preview' do
    subject { instance.preview }

    its(:name) { is_expected.to eql product.name }
    its(:description) { is_expected.to eql product.description }
    its(:color) { is_expected.to eql product.color }
    its(:brand) { is_expected.to eql(product.brand) }
    its(:manufacturer) { is_expected.to eql('Adiddas') }
    its(:material) { is_expected.to eql master_product.material }
    its(:sku) { is_expected.to eql(product.sku) }
    its(:master_sku) { is_expected.to eql master_product.sku }
    its(:offer_price) { is_expected.to eql expected_offer_price }
    its(:original_price) { is_expected.to eql expected_original_price }
  end

  describe '#errors' do
    let!(:error1) { create :product_error, shadow_product: shadow_product }
    let!(:error2) { create :product_error, shadow_product: master_shadow_product }

    its(:errors) { is_expected.to include \
      V1::Ui::ProductErrorBlueprint.render_as_hash(error1).as_json }
  end

  describe '#match_errors' do
    let!(:match1) { create :vendor_product_match, product: product, matched: false, error: ['failed'], vendor_shop_configuration: config }
    let!(:match2) { create :vendor_product_match, product: product, matched: true }
    let!(:match3) { create :vendor_product_match, product: master_product, matched: false }
    let!(:match4) { create :vendor_product_match, product: product, matched: false, error: ['failed again'] }

    its(:match_errors) { is_expected.to eql \
      V1::Ui::VendorProductMatchBlueprint.render_as_hash([match1], vendor: vendor).as_json }
  end
end
