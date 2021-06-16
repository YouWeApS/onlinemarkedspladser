# frozen_string_literal: true

class Mirakl::XML::Offer::Builder
  include Mirakl::Helpers::ProductDataHelper
  include Mirakl::Helpers::OfferCodeHelper

  attr_reader :xml_builder, :product

  def initialize(xml_builder, product)
    @xml_builder = xml_builder
    @product     = product
  end

  def build_xml
    build_sku
    build_product_id
    build_product_id_type
    build_description
    build_price
    build_quantity
    build_state
    build_discount_price
  end

  def build_sku
    xml_builder.send(CODE_SKU, sku)
  end

  def build_product_id
    xml_builder.send(CODE_PRODUCT_ID, ean)
  end

  def build_product_id_type
    xml_builder.send(CODE_PRODUCT_ID_TYPE, ID_TYPE)
  end

  def build_description
    xml_builder.send(CODE_DESCRIPTION, short_description)
  end

  def build_price
    xml_builder.send(CODE_PRICE, price['cents'])
  end

  def build_quantity
    xml_builder.send(CODE_QUANTITY, quantity)
  end

  def build_state
    xml_builder.send(CODE_BUILD_STATE, BUILD_STATE)
  end

  def build_discount_price
    xml_builder.send(CODE_DISCOUNT_PRICE, discount_price['cents'])
  end
end