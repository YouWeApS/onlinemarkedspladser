# frozen_string_literal: true

class Amazon::XML::ProductData::Base
  attr_reader :xml_builder, :product, :options

  def initialize(xml_builder, product, **options)
    @xml_builder = xml_builder
    @product = product.as_json
    @options = options.deep_symbolize_keys
  end

  def build_xml
    raise NotImplementedError, 'must be implemented by descendent'
  end

  def validator_schema_name
    raise NotImplementedError, 'must be implemented by descendent'
  end

  def mapped_value(key)
    if import_map[key.to_s].present?
      path = import_map[key.to_s].to_s.split('.')
      product.dig(*path)
    else
      product.fetch key
    end
  end

  private

    def import_map
      {}.tap do |h|
        options
          .fetch(:import_map, {})
          .slice(:from, :to)
          .values
          .each_slice(2)
          .each do |k, v|
          h[k] = v
        end
      end
    end

    def parentage
      @parentage ||= master? ? 'parent' : 'child'
    end

    def master?
      @master ||= product.fetch('master_sku').blank?
    end

    def child?
      !master?
    end

    def variation_theme
      @variation_theme ||= category.fetch 'variation_theme', 'SizeColor'
    end

    def category
      @category ||= product.fetch('categories', []).first || {}
    end

    def color
      @color ||= product.fetch('color', nil).to_s.strip.titleize
    end

    def material
      @material ||= product.fetch('material', nil).to_s.strip
    end

    def size
      @size ||= product.fetch('size', nil).to_s.strip
    end

    def brand
      @brand ||= product.fetch('brand', nil)
    end

    def ean
      @ean ||= product.fetch('ean', nil)
    end

    def manufacturer
      @manufacturer ||= product.fetch('manufacturer', nil)
    end

    def description
      @description ||= product.fetch('description', nil)
    end

    def key_features
      @key_features ||= product.fetch('key_features', []) || []
    end

    def legal_disclaimer
      @legal_disclaimer ||= product.fetch('legal_disclaimer', nil)
    end

    def search_terms
      @search_terms ||= product.fetch('search_terms', nil)
    end

    def platinum_keywords
      @platinum_keywords ||= product.fetch('platinum_keywords', []) || []
    end

    def browser_node
      @browser_node ||= category.fetch('browser_node', nil)
    end
end
