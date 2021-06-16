# frozen_string_literal: true

class Amazon::XML::Message::Base < Amazon::XML::ProductData::Base
  def build_xml
    return if skip_message?

    xml_builder.Message do |xml|
      build_message_id xml
      build_operation_type xml
      build_message_content xml
    end
  end

  private

    def skip_message?
      false
    end

    def build_message_id(xml)
      xml.MessageID idx
    end

    def build_operation_type(xml)
      xml.OperationType options.fetch(:operation)
    end

    def build_message_content
      raise NotImplementedError, 'descendents must implement'
    end

    def idx
      options.fetch(:idx)
    end
end
