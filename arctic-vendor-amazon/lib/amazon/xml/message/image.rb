# frozen_string_literal: true

# rubocop:disable Lint/ShadowingOuterLocalVariable

class Amazon::XML::Message::Image < Amazon::XML::Message::Base
  attr_reader :image

  def initialize(xml_builder, product, image, **options)
    super xml_builder, product, **options
    @image = image.as_json
  end

  private

    def build_message_content(xml)
      xml.ProductImage do |xml|
        xml.SKU product.fetch('sku')
        xml.ImageType idx.zero? ? 'Main' : "PT#{idx}"
        xml.ImageLocation image.fetch('url')
      end
    end

    def skip_message?
      idx > 8
    end

    def build_message_id(xml)
      xml.MessageID idx + 1
    end
end

# rubocop:enable Lint/ShadowingOuterLocalVariable
