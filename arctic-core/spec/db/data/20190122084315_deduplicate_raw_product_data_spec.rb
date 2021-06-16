# frozen_string_literal: true

require 'rails_helper'

require Rails.root.join(
  'db',
  'data',
  '20190122084315_deduplicate_raw_product_data'
)

RSpec.describe DeduplicateRawProductData do
  subject(:migration) { described_class.new }

  describe '#up' do
    let(:migrate) { migration.up }

    let!(:product1) { create :product }
    let!(:product1_raw1) { build :raw_product_data, product: product1, data: { a: :b } }
    let!(:product1_raw2) { build :raw_product_data, product: product1, data: { a: :b } }

    let!(:product2) { create :product }
    let!(:product2_raw1) { build :raw_product_data, product: product2, data: { a: :b } }
    let!(:product2_raw2) { build :raw_product_data, product: product2, data: { c: :d } }

    before do
      product1_raw1.save validate: false
      product1_raw2.save validate: false
      product2_raw1.save validate: false
      product2_raw2.save validate: false
    end

    it { expect { migrate }.to change { RawProductData.count }.by(-1) }
  end
end
