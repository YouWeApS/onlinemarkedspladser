# frozen_string_literal: true

# rubocop:disable Lint/ShadowingOuterLocalVariable

class Amazon::XML::Message::Relationship < Amazon::XML::Message::Base
  private

    def build_message_content(xml)
      xml.Relationship do |xml|
        xml.ParentSKU product.fetch('master_sku')

        xml.Relation do |xml|
          xml.SKU product.fetch('sku')
          xml.Type 'Variation'
        end
      end
    end

    def skip_message?
      master?
    end
end

# rubocop:enable Lint/ShadowingOuterLocalVariable
