# frozen_string_literal: true

class Amazon::Validator
  attr_reader :product, :options, :errors

  def initialize(product, options = {})
    @product = product.as_json
    @options = options.deep_symbolize_keys
    @errors = {}
  end

  def valid?
    validate_categories
    validate_images
    validate_schema
    errors.empty?
  end

  private

    def validate_categories
      add_error :categories, 'is missing' if product.fetch('categories', []).empty?
    end

    def validate_images
      add_error :images, 'is missing' if product.fetch('images', []).empty?
    end

    def validate_schema
      # We need the category to build the XML, so without it we don't bother
      # progressing from here.
      return if errors.fetch(:categories, []).any?

      validator.validate

      validator.errors.collect do |error_string|
        key, msg = error_string.scan(/Element '([^']+)':\ (.+)/).flatten
        add_error key, msg
      end
    end

    def add_error(key, message)
      errors[key] ||= []
      errors[key] << message
    end

    def validator
      @validator ||= begin
        xml_builder = ::Nokogiri::XML::Builder.new encoding: 'UTF-8'
        instance = Amazon::XML::ProductData.new(xml_builder, product, **options)
        instance.build_xml
        AmazonFeedValidator.new xml_builder.to_xml, name: instance.validator_schema_name
      end
    end
end

Arctic.validator_class = ::Amazon::Validator
