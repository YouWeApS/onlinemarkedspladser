require "spec_helper"

RSpec.describe Amazon::XML::Message::Product do
  include_context :product_data_instance do
    let(:product) do
      {
        sku: 'abcdef123',
        name: 'product a',
        master_sku: nil,
        ean: 'ean123456',
        brand: 'aclima',
        categories: [
          {
            "browser_node": "1939590031",
            "type": "Clothing",
            "classification": "Accessory",
            "variation_theme": "SizeColor"
          }
        ],
        key_features: {
            "1": "66",
            "2": "33",
        },
        "legal_disclaimer": "Legal Disclaimer 1",
        "platinum_keywords": {
            "1": "44",
            "2": "55",
        },
        "search_terms": "Search Terms",
      }
    end

    let(:options) do
      {
        idx: 1,
        operation: :Update,
      }
    end

    let(:expected_xml) do
      <<~XML.strip_heredoc
        <?xml version="1.0" encoding="UTF-8"?>
        <Message>
          <MessageID>1</MessageID>
          <OperationType>Update</OperationType>
          <Product>
            <SKU>abcdef123</SKU>
            <StandardProductID>
              <Type>EAN</Type>
              <Value>ean123456</Value>
            </StandardProductID>
            <ProductTaxCode>A_GEN_NOTAX</ProductTaxCode>
            <Condition>
              <ConditionType>New</ConditionType>
            </Condition>
            <DescriptionData>
              <Title>product a</Title>
              <Brand>aclima</Brand>
              <BulletPoint>66</BulletPoint>
              <BulletPoint>33</BulletPoint>
              <LegalDisclaimer>Legal Disclaimer 1</LegalDisclaimer>
              <SearchTerms>Search Terms</SearchTerms>
              <PlatinumKeywords>44</PlatinumKeywords>
              <PlatinumKeywords>55</PlatinumKeywords>
              <RecommendedBrowseNode>1939590031</RecommendedBrowseNode>
            </DescriptionData>
            <ProductData>
              <Clothing>
                <VariationData>
                  <Parentage>parent</Parentage>
                  <VariationTheme>SizeColor</VariationTheme>
                </VariationData>
                <ClassificationData>
                  <ClothingType>Accessory</ClothingType>
                </ClassificationData>
              </Clothing>
            </ProductData>
          </Product>
        </Message>
      XML
    end

    it_behaves_like :product_data_base

    it 'generates valid xml' do
      instance.build_xml
      expect(xml_builder.to_xml).to eql expected_xml
    end
  end
end
