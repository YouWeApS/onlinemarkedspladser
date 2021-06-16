require "spec_helper"

RSpec.describe Amazon::XML::Envelope::Images do
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
        <MessageType>ProductImage</MessageType>
        <PurgeAndReplace>false</PurgeAndReplace>
        <Message>
          <MessageID>1</MessageID>
          <OperationType>Update</OperationType>
          <ProductImage>
            <SKU>abcdef123</SKU>
            <ImageType>Main</ImageType>
            <ImageLocation>https://google.com/1</ImageLocation>
          </ProductImage>
        </Message>
        <Message>
          <MessageID>2</MessageID>
          <OperationType>Update</OperationType>
          <ProductImage>
            <SKU>abcdef123</SKU>
            <ImageType>PT1</ImageType>
            <ImageLocation>https://google.com/2</ImageLocation>
          </ProductImage>
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

  context 'lots of images' do
    before do
      product[:images] = 20.times.collect do |n|
        {
          position: n,
          url: "https://google.com/#{n+1}",
        }
      end
    end

    let(:expected_xml) do
      <<~XML.strip_heredoc
        <?xml version="1.0" encoding="UTF-8"?>
        <AmazonEnvelope>
          <Header>
            <DocumentVersion>1.02</DocumentVersion>
            <MerchantIdentifier>1</MerchantIdentifier>
          </Header>
          <MessageType>ProductImage</MessageType>
          <PurgeAndReplace>false</PurgeAndReplace>
          <Message>
            <MessageID>1</MessageID>
            <OperationType>Update</OperationType>
            <ProductImage>
              <SKU>abcdef123</SKU>
              <ImageType>Main</ImageType>
              <ImageLocation>https://google.com/1</ImageLocation>
            </ProductImage>
          </Message>
          <Message>
            <MessageID>2</MessageID>
            <OperationType>Update</OperationType>
            <ProductImage>
              <SKU>abcdef123</SKU>
              <ImageType>PT1</ImageType>
              <ImageLocation>https://google.com/2</ImageLocation>
            </ProductImage>
          </Message>
          <Message>
            <MessageID>3</MessageID>
            <OperationType>Update</OperationType>
            <ProductImage>
              <SKU>abcdef123</SKU>
              <ImageType>PT2</ImageType>
              <ImageLocation>https://google.com/3</ImageLocation>
            </ProductImage>
          </Message>
          <Message>
            <MessageID>4</MessageID>
            <OperationType>Update</OperationType>
            <ProductImage>
              <SKU>abcdef123</SKU>
              <ImageType>PT3</ImageType>
              <ImageLocation>https://google.com/4</ImageLocation>
            </ProductImage>
          </Message>
          <Message>
            <MessageID>5</MessageID>
            <OperationType>Update</OperationType>
            <ProductImage>
              <SKU>abcdef123</SKU>
              <ImageType>PT4</ImageType>
              <ImageLocation>https://google.com/5</ImageLocation>
            </ProductImage>
          </Message>
          <Message>
            <MessageID>6</MessageID>
            <OperationType>Update</OperationType>
            <ProductImage>
              <SKU>abcdef123</SKU>
              <ImageType>PT5</ImageType>
              <ImageLocation>https://google.com/6</ImageLocation>
            </ProductImage>
          </Message>
          <Message>
            <MessageID>7</MessageID>
            <OperationType>Update</OperationType>
            <ProductImage>
              <SKU>abcdef123</SKU>
              <ImageType>PT6</ImageType>
              <ImageLocation>https://google.com/7</ImageLocation>
            </ProductImage>
          </Message>
          <Message>
            <MessageID>8</MessageID>
            <OperationType>Update</OperationType>
            <ProductImage>
              <SKU>abcdef123</SKU>
              <ImageType>PT7</ImageType>
              <ImageLocation>https://google.com/8</ImageLocation>
            </ProductImage>
          </Message>
          <Message>
            <MessageID>9</MessageID>
            <OperationType>Update</OperationType>
            <ProductImage>
              <SKU>abcdef123</SKU>
              <ImageType>PT8</ImageType>
              <ImageLocation>https://google.com/9</ImageLocation>
            </ProductImage>
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
end
