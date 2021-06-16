# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Ui::VendorShopConfigurationBlueprint do
  subject { instance }

  let(:instance) { Hashie::Mash.new described_class.render_as_hash(config, view: :dispersal) }

  let(:config) { create :vendor_shop_configuration }

  its(:id) { is_expected.to eql(config.id) }
  its(:auth_config) { is_expected.to eql(config.auth_config) }
  its(:currency_config) { is_expected.to eql(config.currency_config) }

  it { is_expected.to match_schema('ui/vendor_shop_configuration') }

  context 'collection config' do
    let(:instance) { Hashie::Mash.new described_class.render_as_hash(config, view: :collection) }
    let(:config) { create :vendor_shop_collection_configuration }
    let!(:importmap1) { create :import_map, position: 2, vendor_shop_configuration: config }
    let!(:importmap2) { create :import_map, position: 1, vendor_shop_configuration: config }

    its(:product_parse_config) { is_expected.to eql V1::Vendors::ImportMapBlueprint.render_as_hash([importmap2, importmap1]).as_json }
  end

  context 'dispersal config' do
    let(:instance) { Hashie::Mash.new described_class.render_as_hash(config, view: :dispersal) }
    let(:config) { create :vendor_shop_collection_configuration }
    let!(:importmap1) { create :import_map, position: 2, vendor_shop_configuration: config }
    let!(:importmap2) { create :import_map, position: 1, vendor_shop_configuration: config }

    its(:product_parse_config) { is_expected.to eql V1::Vendors::ImportMapBlueprint.render_as_hash([importmap2, importmap1]).as_json }
  end
end
