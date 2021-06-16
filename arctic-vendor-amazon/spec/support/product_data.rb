RSpec.shared_context :product do
  let(:product) do
    {
      master_sku: nil,
      sku: 'abcdef123',
      ean: 'prod-ean',
      name: 'product name',
      stock_count: 1,
      original_price: {
        currency: 'GBP',
        cents: '12345',
      },
      offer_price: {},
      images: [
        {
          position: 1,
          url: 'https://google.com/1',
        },
        {
          position: 2,
          url: 'https://google.com/2',
        },
      ],
      categories: [
        {
          "browser_node": "1939590031",
          "type": "Clothing",
          "classification": "Accessory",
          "variation_theme": "SizeColor",
        },
      ],
    }
  end
end

RSpec.shared_context :other_product do
  let(:other_product) do
    {
      master_sku: nil,
      sku: 'qwertyu45678',
      ean: 'other-prod-ean',
      name: 'product name',
      stock_count: 1,
      original_price: {
        currency: 'GBP',
        cents: '12345',
      },
      offer_price: {},
      images: [
        {
          position: 1,
          url: 'https://google.com/1',
        },
        {
          position: 2,
          url: 'https://google.com/2',
        },
      ],
      categories: [
        {
          "browser_node": "1939590031",
          "type": "Clothing",
          "classification": "Accessory",
          "variation_theme": "SizeColor",
        },
      ],
    }
  end
end

RSpec.shared_context :child_product do
  let(:child_product) do
    {
      master_sku: 'abcdef123',
      sku: 'ghijkl456',
      ean: 'prod-ean',
      name: 'product name',
      stock_count: 99,
      original_price: {
        currency: 'GBP',
        cents: '67890',
      },
      offer_price: {},
      categories: [
        {
          "browser_node": "1939590031",
          "type": "Clothing",
          "classification": "Accessory",
          "variation_theme": "SizeColor",
        },
      ],
    }
  end
end

RSpec.shared_context :product_data_instance do
  let(:instance) { described_class.new xml_builder, product, **options }

  let(:xml_builder) { ::Nokogiri::XML::Builder.new encoding: 'UTF-8' }

  include_context :product

  let(:options) { {} }

  subject { instance }
end

RSpec.shared_examples :product_data_base do
  its(:product) { is_expected. to eql product.as_json }
  its(:options) { is_expected. to eql options.deep_symbolize_keys }
  its(:xml_builder) { is_expected. to eql xml_builder }
end

RSpec.shared_examples :generates_valid_xml do |name = 'Beauty'|
  describe '#build_xml' do
    it 'adds the clothing product data to the builder' do
      instance.build_xml

      expect(xml_builder.to_xml).to eql expected_xml
    end

    if name
      it 'generates valid xml' do
        instance.build_xml

        validator = AmazonFeedValidator.new xml_builder.to_xml, name: name
        valid = validator.validate

        expect(validator.errors).to be_empty
        expect(valid).to be_truthy
      end
    end
  end
end

RSpec.shared_examples :validator_schema_name do |name|
  it "equals #{name}" do
    expect(subject.validator_schema_name).to eql name
  end
end
