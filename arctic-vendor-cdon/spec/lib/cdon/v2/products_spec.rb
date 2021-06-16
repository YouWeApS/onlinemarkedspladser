require "spec_helper"

RSpec.describe CDON::V2::Products do
  include_context :v2_products

  let(:products) { [product1, product2, product3] }
  let(:instance) { described_class.new products, options }
  let(:options) { { a: :b } }
  let(:expected_xml) { File.read File.expand_path '../../../fixtures/products.xml', __dir__ }

  subject { instance }

  it_behaves_like :feed, 'https://mis.cdon.com/api'

  its(:products) { is_expected.to eql products.map(&:as_json) }
  its(:options) { is_expected.to eql Hashie::Mash.new(options) }
  its(:valid?) { is_expected.to be_truthy }
  its(:to_xml) { is_expected.to eql expected_xml }

  context 'can handle missing categories' do
    before { product1.delete :categories }

    its(:valid?) { is_expected.to be_falsey }
  end

  context 'can handle missing name' do
    before { product2.delete :name }

    its(:valid?) { is_expected.to be_falsey }
  end

  context 'can handle missing description' do
    before { product1.delete :description }

    its(:valid?) { is_expected.to be_falsey }
  end

  context 'can handle missing sku' do
    before { product2.delete :sku }

    its(:valid?) { is_expected.to be_falsey }
  end

  context 'invalid products argument' do
    let(:products) { product1 }
    it { expect { instance }.to raise_error ArgumentError, 'products must be an array' }
  end
end
