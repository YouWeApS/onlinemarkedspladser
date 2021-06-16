# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VendorShopConfiguration, type: :model do
  let(:instance) { build :vendor_shop_configuration }
  subject { instance }

  it { is_expected.to belong_to :vendor }
  it { is_expected.to belong_to :shop }

  it { is_expected.to have_one :channel }

  it { is_expected.to have_many :category_maps }
  it { is_expected.to have_many :shadow_products }
  it { is_expected.to have_many :vendor_product_matches }
  it { is_expected.to have_many :dispersals }
  it { is_expected.to have_many :import_maps }

  it { is_expected.to validate_inclusion_of(:type).in_array(VendorShopConfiguration::TYPES) }

  it 'is possible to connect two of the same vendor to a shop' do
    shop = create :shop
    vendor = create :vendor
    expect { create :vendor_shop_configuration, shop: shop, vendor: vendor }.not_to raise_error
    expect { create :vendor_shop_configuration, shop: shop, vendor: vendor }.not_to raise_error
  end

  describe '.enabled' do
    let!(:enabled_config) { create :vendor_shop_configuration }
    let!(:disabled_config) { create :vendor_shop_configuration, enabled: false }
    it { expect(described_class.enabled).to match_array [enabled_config] }
  end

  describe '.disabled' do
    let!(:enabled_config) { create :vendor_shop_configuration }
    let!(:disabled_config) { create :vendor_shop_configuration, enabled: false }
    it { expect(described_class.disabled).to match_array [disabled_config] }
  end

  describe '#dispersal?' do
    subject { instance.dispersal? }

    context 'VendorShopDispersalConfiguration' do
      let(:instance) { build :vendor_shop_dispersal_configuration }
      it { is_expected.to be_truthy }
    end

    context 'VendorShopCollectionConfiguration' do
      let(:instance) { build :vendor_shop_collection_configuration }
      it { is_expected.to be_falsey }
    end
  end

  describe '#collection?' do
    subject { instance.collection? }

    context 'VendorShopDispersalConfiguration' do
      let(:instance) { build :vendor_shop_dispersal_configuration }
      it { is_expected.to be_falsey }
    end

    context 'VendorShopCollectionConfiguration' do
      let(:instance) { build :vendor_shop_collection_configuration }
      it { is_expected.to be_truthy }
    end
  end

  describe '#auth_config' do
    subject { instance.auth_config }

    it { is_expected.to eql 'password' => 'secret' }

    it 'is encrypted in the database' do
      instance.save # trigger encryption
      expect(instance.read_attribute_before_type_cast(:auth_config)).to match /\\xc/
    end

    it "validates the auth_config against the channe's auth_config_schema" do
      instance.channel.update auth_config_schema: {
        type: :object,
        required: %i[a b],
        properties: {
          a: {
            type: :array,
          },
          b: {
            type: :string,
          },
        },
      }

      # Invalid auth config
      expect(instance.save).to be_falsey
      expect(instance.errors[:auth_config]).to match_array [
        "The property '#/' did not contain a required property of 'a'",
      ]

      # valid auth config
      instance.auth_config = {
        a: [],
        b: :hello,
      }
      expect(instance.save).to be_truthy
      expect(instance.errors).to be_empty
    end
  end
end
