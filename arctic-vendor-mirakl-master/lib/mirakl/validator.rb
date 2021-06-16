# frozen_string_literal: true

module Mirakl
  class Validator
    attr_reader :product, :options, :errors

    def initialize(product, options = {})
      @product = product
      @options = options
      @errors  = {}
    end

    def valid?
      validate_missing(:ean)
      validate_missing(:brand)
      validate_missing(:description)
      # validate_missing(:categories)
      validate_missing(:images)

      errors.empty?
    end

    private

    def validate_missing(attr_name)
      add_error attr_name, 'is missing' if product[attr_name.to_s].blank?
    end

    def add_error(key, message)
      errors[key] ||= []
      errors[key] << message
    end
  end
end

Arctic.validator_class = ::Mirakl::Validator