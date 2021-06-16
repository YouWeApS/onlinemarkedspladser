require "spec_helper"

RSpec.describe Amazon::XML::Message::Relationship do
  include_context :product_data_instance do
    include_context :child_product
    let(:product) { child_product }

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
          <Relationship>
            <ParentSKU>abcdef123</ParentSKU>
            <Relation>
              <SKU>ghijkl456</SKU>
              <Type>Variation</Type>
            </Relation>
          </Relationship>
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
