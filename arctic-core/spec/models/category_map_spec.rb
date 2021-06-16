# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CategoryMap, type: :model do
  let(:instance) { build :category_map }

  it { is_expected.to belong_to :vendor_shop_configuration }
  it { is_expected.to have_one :shop }
  it { is_expected.to have_one :vendor }
  it { is_expected.to have_one :channel }

  it { is_expected.to validate_presence_of :source }
  it { is_expected.to validate_presence_of :value }

  describe '#schema' do
    let(:channel) { create :channel, category_map_json_schema: { a: :b } }

    let(:vendor) { create :vendor, channel: channel }

    let(:config) { create :vendor_shop_dispersal_configuration, vendor: vendor }

    before { instance.vendor_shop_configuration = config }

    subject { instance.schema }

    it { is_expected.to eql 'a' => 'b' }
  end
end
