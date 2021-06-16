# frozen_string_literal: true

# rubocop:disable Lint/ShadowingOuterLocalVariable

class Amazon::XML::Envelope::Base
  attr_reader :xml_builder, :products, :options

  def initialize(products, **options)
    @xml_builder = ::Nokogiri::XML::Builder.new encoding: 'UTF-8'
    @products = products.as_json
    @options = options.deep_symbolize_keys
  end

  def to_xml
    return unless should_submit?

    build_xml
    xml_builder.to_xml
  end

  private

    def build_xml
      xml_builder.AmazonEnvelope do |xml|
        build_header xml
        build_message_type xml
        build_purge_and_replace xml
        build_messages xml
      end
    end

    def should_submit?
      true
    end

    def build_message_type(xml)
      xml.MessageType message_type
    end

    def message_type
      raise NotImplementedError, 'descendents must implement this'
    end

    def build_purge_and_replace(xml)
      xml.PurgeAndReplace options.fetch(:purge, false) ? 'true' : 'false'
    end

    def build_header(xml)
      xml.Header do |xml|
        xml.DocumentVersion 1.02
        xml.MerchantIdentifier options.fetch(:credentials).fetch(:merchant_id)
      end
    end

    def build_messages(*)
      raise NotImplementedError, 'descendents must implement this'
    end
end

# rubocop:enable Lint/ShadowingOuterLocalVariable
