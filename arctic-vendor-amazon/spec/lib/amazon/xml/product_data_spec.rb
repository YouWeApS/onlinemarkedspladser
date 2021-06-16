require "spec_helper"

RSpec.describe Amazon::XML::ProductData do
  let(:instance) { described_class.new builder, product }
  let(:product) do
    {
      name: 'product a',
      categories: [
        {
          type: :Clothing,
        },
      ],
    }
  end

  let(:builder) { ::Nokogiri::XML::Builder.new encoding: 'UTF-8' }

  subject { instance }

  it 'returns an instance of the right product data builder' do
    is_expected.to be_a Amazon::XML::ProductData::Clothing
  end
end
