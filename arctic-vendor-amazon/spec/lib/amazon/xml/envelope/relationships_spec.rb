require "spec_helper"

RSpec.describe Amazon::XML::Envelope::Relationships do
  include_context :product
  include_context :child_product

  let(:instance) { described_class.new products, options }
  let(:no_instance) { described_class.new [products[0]], options }

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
        <MessageType>Relationship</MessageType>
        <PurgeAndReplace>false</PurgeAndReplace>
        <Message>
          <MessageID>2</MessageID>
          <OperationType>Update</OperationType>
          <Relationship>
            <ParentSKU>abcdef123</ParentSKU>
            <Relation>
              <SKU>ghijkl456</SKU>
              <Type>Variation</Type>
            </Relation>
          </Relationship>
        </Message>
      </AmazonEnvelope>
    XML
  end

  it 'generates valid xml' do
    expect(instance.to_xml).to eql expected_xml
    expect(no_instance.to_xml).to eql nil

    validator = AmazonFeedValidator.new instance.xml_builder.to_xml, name: 'amzn-envelope'
    valid = validator.validate

    expect(validator.errors).to be_empty
    expect(valid).to be_truthy
  end
end
