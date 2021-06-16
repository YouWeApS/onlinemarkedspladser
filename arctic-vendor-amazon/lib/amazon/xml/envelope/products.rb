# frozen_string_literal: true

class Amazon::XML::Envelope::Products < Amazon::XML::Envelope::Base
  private

    def build_messages(xml)
      products.each_with_index do |product, idx|
        opts = options.dup.reverse_merge idx: idx + 1
        Amazon::XML::Message::Product.new(xml, product, **opts).build_xml
      end
    end

    def message_type
      'Product'
    end
end
