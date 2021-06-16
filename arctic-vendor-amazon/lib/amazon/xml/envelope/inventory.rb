# frozen_string_literal: true

class Amazon::XML::Envelope::Inventory < Amazon::XML::Envelope::Base
  private

    def build_messages(xml)
      products.each_with_index do |product, idx|
        opts = options.dup.reverse_merge idx: idx + 1
        Amazon::XML::Message::Inventory.new(xml, product, **opts).build_xml
      end
    end

    def message_type
      'Inventory'
    end
end
