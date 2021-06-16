# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RawProductData, type: :model do
  let(:instance) { build :raw_product_data }
  subject { instance }

  it { is_expected.to belong_to :product }

  it { is_expected.to validate_uniqueness_of :data }
  it { is_expected.to validate_presence_of :data }

  it 'is not possible to add two, identical raw product blobs to the same product' do
    product = create :product
    raw_data = { a: :b }
    expect { product.raw_product_data.create! data: raw_data }.not_to raise_error
    expect { product.raw_product_data.create! data: raw_data }.to raise_error
  end
end
