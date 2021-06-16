require "spec_helper"

RSpec.describe Amazon::XML::Message::Price do
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
          <Price>
            <SKU>abcdef123</SKU>
            <StandardPrice currency="GBP">123.45</StandardPrice>
          </Price>
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
