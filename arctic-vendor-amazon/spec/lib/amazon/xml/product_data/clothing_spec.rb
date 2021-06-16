require "spec_helper"

RSpec.describe Amazon::XML::ProductData::Clothing do
  include_context :product_data_instance

  let(:product) do
    {
      name: 'product a',
      color: 'black',
      size: 'Medium',
      material: 'Leather',
      master_sku: nil,
      categories: [
        {
          classification: 'Accessory',
          variation_theme: 'SizeColor',
        },
      ],
    }
  end

  let(:expected_xml) do
    <<~XML.strip_heredoc
      <?xml version="1.0" encoding="UTF-8"?>
      <Clothing>
        <VariationData>
          <Parentage>parent</Parentage>
          <VariationTheme>SizeColor</VariationTheme>
        </VariationData>
        <ClassificationData>
          <ClothingType>Accessory</ClothingType>
          <ColorMap>Black</ColorMap>
          <MaterialComposition>Leather</MaterialComposition>
          <SizeMap>Medium</SizeMap>
        </ClassificationData>
      </Clothing>
    XML
  end

  it_behaves_like :product_data_base

  it_behaves_like :validator_schema_name, 'ProductClothing'

  it_behaves_like :generates_valid_xml, 'ProductClothing'
end
