# frozen_string_literal: true

class Amazon::XML::ProductData::Builder
  attr_reader :xml_builder, :product, :options

  def initialize(xml_builder, product, **options)
    @xml_builder = xml_builder
    @product = product.deep_stringify_keys
    @options = options
  end

  def instance
    klass = "Amazon::XML::ProductData::#{type.to_s.classify}".constantize
    klass.new xml_builder, product, **options
  end

  private

    def type
      product.fetch('categories', []).first.fetch('type')
    end
end
