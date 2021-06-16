# frozen_string_literal: true

# rubocop:disable Lint/ShadowingOuterLocalVariable

class Amazon::XML::Message::Price < Amazon::XML::Message::Base
  private

    def build_message_content(xml)
      xml.Price do |xml|
        xml.SKU product.fetch('sku')

        # Because Nokogiri can't bulid <node attr=value>text</node> directly
        xml << "<StandardPrice currency=\"#{currency}\">#{price}</StandardPrice>"
      end
    end

    def currency
      price_obj.fetch 'currency', :no_currency_available
    end

    def price
      format '%.2f', (Float(price_obj.fetch('cents')) / 100.0)
    rescue KeyError
      :no_price_available
    end

    def price_obj
      product['offer_price'].presence || product['original_price'].presence || {}
    end
end

# rubocop:enable Lint/ShadowingOuterLocalVariable
