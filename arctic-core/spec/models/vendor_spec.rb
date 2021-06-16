# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vendor, type: :model do
  it { is_expected.to validate_presence_of :token }

  it { is_expected.to belong_to :channel }

  it { is_expected.to have_many :collection_shop_configurations }
  it { is_expected.to have_many :collection_shops }
  it { is_expected.to have_many :dispersal_categories }
  it { is_expected.to have_many :dispersal_shop_configurations }
  it { is_expected.to have_many :vendor_shop_configurations }
  it { is_expected.to have_many :dispersal_shops }
  it { is_expected.to have_many(:dispersals).through(:vendor_shop_configurations) }
  it { is_expected.to have_many :vendor_product_matches }
  it { is_expected.to have_many(:shadow_products).through(:vendor_shop_configurations) }

  it { is_expected.to validate_presence_of :validation_url }

  describe '#name' do
    let(:vendor) { create :vendor }
    subject { vendor.name }

    it { is_expected.to eql vendor.channel.name }

    context 'specific name' do
      before { vendor.update name: 'Hello' }
      it { is_expected.to eql "#{vendor.channel.name} (Hello)"}
    end
  end

  describe '#sku_formatter' do
    let(:vendor) { build :vendor }
    subject { vendor.sku_formatter }

    it { is_expected.to eql Sku }

    context 'AlphaNumSku' do
      before { vendor.sku_formatter = 'AlphaNumSku' }

      it { is_expected.to eql AlphaNumSku }
    end
  end
end
