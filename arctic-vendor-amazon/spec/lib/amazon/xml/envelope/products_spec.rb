require "spec_helper"

RSpec.describe Amazon::XML::Envelope::Products do
  include_context :product
  include_context :child_product

  let(:instance) { described_class.new products, options }

  let(:products) do
    [
      product,
      child_product,
    ]
  end

  let(:options) do
    {
      credentials: {
        merchant_id: 1,
      },
      type: :Product,
      operation: :Update
    }
  end

  let(:expected_xml) do
    <<~XML.strip_heredoc
      <?xml version="1.0" encoding="UTF-8"?>
      <AmazonEnvelope>
        <Header>
          <DocumentVersion>1.02</DocumentVersion>
          <MerchantIdentifier>1</MerchantIdentifier>
        </Header>
        <MessageType>Product</MessageType>
        <PurgeAndReplace>false</PurgeAndReplace>
        <Message>
          <MessageID>1</MessageID>
          <OperationType>Update</OperationType>
          <Product>
            <SKU>abcdef123</SKU>
            <StandardProductID>
              <Type>EAN</Type>
              <Value>prod-ean</Value>
            </StandardProductID>
            <ProductTaxCode>A_GEN_NOTAX</ProductTaxCode>
            <Condition>
              <ConditionType>New</ConditionType>
            </Condition>
            <DescriptionData>
              <Title>product name</Title>
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
        <Message>
          <MessageID>2</MessageID>
          <OperationType>Update</OperationType>
          <Product>
            <SKU>ghijkl456</SKU>
            <StandardProductID>
              <Type>EAN</Type>
              <Value>prod-ean</Value>
            </StandardProductID>
            <ProductTaxCode>A_GEN_NOTAX</ProductTaxCode>
            <Condition>
              <ConditionType>New</ConditionType>
            </Condition>
            <DescriptionData>
              <Title>product name</Title>
              <RecommendedBrowseNode>1939590031</RecommendedBrowseNode>
            </DescriptionData>
            <ProductData>
              <Clothing>
                <VariationData>
                  <Parentage>child</Parentage>
                  <Size/>
                  <Color/>
                  <VariationTheme>SizeColor</VariationTheme>
                </VariationData>
                <ClassificationData>
                  <ClothingType>Accessory</ClothingType>
                </ClassificationData>
              </Clothing>
            </ProductData>
          </Product>
        </Message>
      </AmazonEnvelope>
    XML
  end

  it 'generates valid xml' do
    expect(instance.to_xml).to eql expected_xml

    validator = AmazonFeedValidator.new instance.xml_builder.to_xml, name: 'amzn-envelope'
    valid = validator.validate

    expect(validator.errors).to be_empty
    expect(valid).to be_truthy
  end
end
