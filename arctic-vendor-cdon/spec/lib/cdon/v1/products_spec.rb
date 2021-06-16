require "spec_helper"
require 'pp'

RSpec.describe CDON::V1::Products do
  include_context :v1_products

  let(:instance) { described_class.new shop, products }

  let(:shop) do
    {
      config: {
        source_id: 'xxx',
        country: 'se',
        vat: 25.00,
      },
    }
  end

  subject { instance }

  it { is_expected.to be_a CDON::V1::Feed }

  its(:valid?) { is_expected.to be_truthy }
  its(:errors) { is_expected.to be_empty }
end
