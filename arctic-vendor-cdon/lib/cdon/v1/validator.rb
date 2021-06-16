# frozen_string_literal: true

class CDON::V1::Validator
  attr_reader :product, :options, :errors

  def initialize(product, options = {})
    @product = product.as_json
    @options = options.deep_symbolize_keys
    @errors = {}
  end

  def valid?
    check_category_present

    validator.valid?.tap do
      validator.errors.each do |err|
        key, msg = err.scan(/Element '\{[^}]+}([^']+)':(.+)/).flatten
        add_error key, msg
      end
    end

    errors.empty?
  end

  private

    def check_category_present
      return if product.fetch('categories', []).first

      product['categories'] = [] # to allow validation to continue finding other, potenrial issues
      add_error 'category', 'missing category'
    end

    def add_error(key, message)
      errors[key] ||= []
      errors[key] << message
    end

    def validator
      @validator ||= begin
        CDON::V1::Schema.new CDON::V1::Products.new(shop, [product]).to_xml
      end
    end

    def shop
      Arctic.logger.info "Shop: #{options}"
      options.fetch(:shop)
    end
end

Arctic.validator_class = ::CDON::V1::Validator
