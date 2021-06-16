# frozen_string_literal: true

class Mirakl::XML::Product::Builder
  include Mirakl::Helpers::ProductDataHelper
  include Mirakl::Helpers::ProductCodeHelper

  attr_reader :xml_builder, :product, :mirakl_api

  def initialize(xml_builder, product, mirakl_api)
    @xml_builder = xml_builder
    @product     = product
    @mirakl_api  = mirakl_api
  end

  def build_xml
    build_base_attributes
  end

  private

  def build_base_attributes
    build_category
    build_sku
    build_title
    build_ean
    build_brand
    build_short_description
    build_images
  end

  def attribute_builder(code, value)
    xml_builder.attribute do |xml|
      xml.code  code
      xml.value value
    end
  end

  def build_category
    attribute_builder(CODE_CATEGORY, category['code'])
  end

  def build_sku
    attribute_builder(CODE_SKU, sku)
  end

  def build_title
    attribute_builder(CODE_TITLE_EN, title)
  end

  def build_ean
    attribute_builder(CODE_EAN, ean)
  end

  def build_short_description
    attribute_builder(CODE_SHORT_DESCR_EN, short_description)
  end

  def build_images
    images.each_with_index do |image, index|
      attribute_builder(CODE_IMAGE + (index + 1).to_s, image['url'])
    end
  end

  def build_brand
    attribute_builder(CODE_BRAND, mirakl_api.get_brand_code(brand))
  end

  def true_false(value)
    value ? CODE_TRUE : CODE_FALSE
  end
end