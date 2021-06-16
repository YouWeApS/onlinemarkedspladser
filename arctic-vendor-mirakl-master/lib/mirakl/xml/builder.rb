# frozen_string_literal: true

class Mirakl::XML::Builder
  PRODUCT_BASE_BUILDER_NAME = 'Builder'

  attr_reader :xml_builder, :products, :mirakl_api

  def initialize(products, mirakl_api)
    @xml_builder = ::Nokogiri::XML::Builder.new encoding: 'UTF-8'
    @products    = products
    @mirakl_api  = mirakl_api
  end

  def to_xml
    build_xml
    xml_builder.to_xml
  end

  private

  def build_xml
    xml_builder.import do |xml|
      build_products xml
      build_offers xml
    end
  end

  def build_products(xml)
    xml.products do
      products.each do |product|
        xml.product do
          build_product_attrs xml, product
        end
      end
    end
  end

  def build_offers(xml)
    xml.offers do
      products.each do |product|
        xml.offer do
          build_offer_attrs xml, product
        end
      end
    end
  end

  def build_product_attrs(xml, product)
    category_name = product.dig('categories', 0, 'mirakl_vendor_category', 'name').gsub(' ', '_').classify

    class_name = Mirakl::XML::Product.const_defined?(category_name) ? category_name : PRODUCT_BASE_BUILDER_NAME

    klass = "Mirakl::XML::Product::#{class_name}".constantize

    klass.new(xml_builder, product, mirakl_api).build_xml
  end

  def build_offer_attrs(xml, product)
    Mirakl::XML::Offer::Builder.new(xml, product).build_xml
  end
end