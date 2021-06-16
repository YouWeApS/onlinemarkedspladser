require "spec_helper"

RSpec.describe Dandomain::V2::API, :vcr do
  let(:instance) { described_class.new shop }

  include_context :shop

  subject { instance }

  its(:config) { is_expected.to eql shop['config'].as_json }
  its(:auth_config) { is_expected.to eql shop['auth_config'].as_json }

  # describe '#products' do
  #   let(:json) do
  #     prod = nil
  #     instance.products(**options) do |product|
  #       prod ||= product
  #     end
  #     JSON.pretty_generate prod
  #   end

  #   let(:options) { {} }
  #   let(:path) { $root.join('spec', 'fixtures', 'v2', 'formatted_product1.json') }
  #   let(:product) { JSON.pretty_generate JSON.parse(File.read(path)) }

  #   it{ expect(json).to eql product }

  #   context 'products since date' do
  #     let(:options) { { since: '2018-11-30' } }
  #     let(:path) { $root.join('spec', 'fixtures', 'v2', 'formatted_product2.json') }
  #     it { expect(json).to eql product }
  #   end
  # end

  describe '#create_product' do
    it { expect { instance.create_product }.to raise_error NotImplementedError }
  end

  describe '#create_order' do
    subject { instance.create_order order }

    let(:path) { $root.join('spec', 'fixtures', 'v2', 'core_order_data1.json') }
    let(:order) { JSON.pretty_generate JSON.parse(File.read(path)) }

    xit { expect { subject }.to raise_error NotImplementedError }
  end

  describe '#products' do
    product = HashWithIndifferentAccess.new({productNumber: 1})

    it 'Fetch works with paginated method' do
      allow(instance).to receive(:fetch_items).and_return([[product], false])
      allow(instance).to receive(:product).with(1).and_return('123')
      expect(instance.products(modifiedStartDate: nil) do |product|
        break product
      end).to eql('123')
    end
  end

  describe '#orders' do
    it 'Return orders' do
      expect(instance.orders(startLastModified: nil) do |order|
        break order
      end).to have_key('referenceNumber')
    end
  end
end
