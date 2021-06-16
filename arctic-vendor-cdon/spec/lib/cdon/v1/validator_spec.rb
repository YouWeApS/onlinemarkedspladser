require "spec_helper"

RSpec.describe CDON::V1::Validator do
  include_context :v1_products

  let(:instance) { described_class.new product1, options }

  let(:options) do
    {
      'a' => 'b',
      shop: {
        id: 'shop1',
        config: {
          source_id: 'xxx',
          country: 'dk',
          vat: 25.0,
        },
      },
    }
  end

  subject { instance }

  its(:product) { is_expected.to eql product1.as_json }
  its(:options) { is_expected.to eql options.deep_symbolize_keys }
  its(:errors) { is_expected.to be_a Hash }
  its(:errors) { is_expected.to be_blank }
  it { is_expected.to be_valid }

  context 'missing shop from options' do
    before { options.delete :shop }
    it { expect { subject.valid? }.to raise_error KeyError, 'key not found: :shop' }
  end

  context 'missing product category' do
    before { product1.delete :categories }
    it { is_expected.not_to be_valid }
  end

  context 'empty product categories' do
    before { product1[:categories] = [] }
    it { is_expected.not_to be_valid }
  end
end
