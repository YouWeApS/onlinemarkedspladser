require "spec_helper"

RSpec.describe Amazon::XML::ProductData::Beauty do
  include_context :product_data_instance

  let(:product) do
    {
      name: 'product a',
      master_sku: nil,
      categories: [
        {
          type: 'Beauty',
          variation_theme: 'Size-Scent',
        },
      ],
    }
  end

  let(:expected_xml) do
    <<~XML.strip_heredoc
      <?xml version="1.0" encoding="UTF-8"?>
      <Beauty>
        <ProductType>
          <Fragrance>
            <VariationData>
              <Parentage>parent</Parentage>
              <VariationTheme>Size-Scent</VariationTheme>
            </VariationData>
          </Fragrance>
        </ProductType>
      </Beauty>
    XML
  end

  it_behaves_like :product_data_base

  it_behaves_like :validator_schema_name, 'Beauty'

  it_behaves_like :generates_valid_xml
end
