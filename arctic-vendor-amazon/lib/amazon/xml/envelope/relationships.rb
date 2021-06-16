# frozen_string_literal: true

class Amazon::XML::Envelope::Relationships < Amazon::XML::Envelope::Base
  private

    def build_messages(xml)
      products.each_with_index do |product, idx|
        opts = options.dup.reverse_merge idx: idx + 1
        Amazon::XML::Message::Relationship.new(xml, product, **opts).build_xml
      end
    end

    def message_type
      'Relationship'
    end

    def should_submit?
      products.pluck('master_sku').any?
    end
end
