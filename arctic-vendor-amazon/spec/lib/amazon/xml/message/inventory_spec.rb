require "spec_helper"

RSpec.describe Amazon::XML::Message::Inventory do
  include_context :product_data_instance do
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
          <Inventory>
            <SKU>abcdef123</SKU>
            <Quantity>1</Quantity>
          </Inventory>
        </Message>
      XML
    end

    it_behaves_like :product_data_base

    it 'generates valid xml' do
      instance.build_xml
      expect(xml_builder.to_xml).to eql expected_xml
    end

    it 'change quantity to valid count' do
      instance.product['stock_count'] = 100_000_000
      expected_xml.to_s.sub! '<Quantity>1</Quantity>', '<Quantity>99999999</Quantity>'
      instance.build_xml
      expect(xml_builder.to_xml).to eql expected_xml
    end
  end
end
