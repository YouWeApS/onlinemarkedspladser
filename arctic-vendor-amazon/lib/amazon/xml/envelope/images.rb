# frozen_string_literal: true

class Amazon::XML::Envelope::Images < Amazon::XML::Envelope::Base
  private

    def build_messages(xml)
      products.each do |product|
        product.fetch('images', []).each_with_index do |img, idx|
          opts = options.dup.reverse_merge idx: idx
          Amazon::XML::Message::Image.new(xml, product, img, **opts).build_xml
        end
      end
    end

    def message_type
      'ProductImage'
    end
end
