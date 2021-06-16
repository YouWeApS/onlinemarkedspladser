require "spec_helper"

RSpec.describe Amazon::XML::Message::Image do
  include_context :product_data_instance do
    let(:instance) { described_class.new xml_builder, product, image, **options }

    let(:image) { product.fetch(:images).first }

    let(:options) do
      {
        idx: 0,
        operation: :Update,
      }
    end

    let(:expected_xml) do
      <<~XML.strip_heredoc
        <?xml version="1.0" encoding="UTF-8"?>
        <Message>
          <MessageID>1</MessageID>
          <OperationType>Update</OperationType>
          <ProductImage>
            <SKU>abcdef123</SKU>
            <ImageType>Main</ImageType>
            <ImageLocation>https://google.com/1</ImageLocation>
          </ProductImage>
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
