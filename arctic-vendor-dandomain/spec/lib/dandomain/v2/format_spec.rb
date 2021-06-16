require "spec_helper"

RSpec.describe Dandomain::V2::Format, :vcr do
  let(:instance) { described_class.new shop, product }

  let(:path) { $root.join('spec', 'fixtures', 'v2', 'product2.json') }
  let(:product) { JSON.parse(File.read(path)) }

  let(:f_path) { $root.join('spec', 'fixtures', 'v2', 'formatted_product2.json') }
  let(:expected_json) { JSON.parse(File.read(f_path)) }

  include_context :shop

  it 'formats the product correctly' do
    expect(instance.as_json).to eql expected_json
  end
end
