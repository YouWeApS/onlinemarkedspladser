# frozen_string_literal: true

# rubocop:disable Lint/ShadowingOuterLocalVariable

class Amazon::XML::Message::Inventory < Amazon::XML::Message::Base
  private
    MAX_COUNT = 99_999_999

    def build_message_content(xml)
      xml.Inventory do |xml|
        xml.SKU product.fetch('sku')
        xml.Quantity valid_stock_count
      end
    end

    def valid_stock_count
      count = product.fetch('stock_count')
      count > MAX_COUNT ? MAX_COUNT : count
    end
end

# rubocop:enable Lint/ShadowingOuterLocalVariable
