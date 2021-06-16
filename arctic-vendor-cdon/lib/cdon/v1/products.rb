# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

require_relative '../v1'
require_relative 'product_variation'

class CDON::V1::Products < CDON::V1::Feed
  CHARACTERISTICS = {
    TITLE: :name,
    DESCRIPTION: :description,
  }.freeze

  attr_reader :shop, :masters, :product, :variants

  def initialize(shop, products)
    @shop = shop.as_json

    products = products.collect { |pr| Hashie::Mash.new pr }
    @variants = products.select { |pr| pr.master_sku.present? }.group_by(&:master_sku)
    @masters = products.select { |pr| pr.master_sku.blank? }
  end

  def valid?
    validator.valid?
  end

  def errors
    validator.valid?
    validator.errors
  end

  def to_xml
    xml.to_xml
  end

  private

    def skip_submit?
      masters.empty?
    end

    def validator
      @validator ||= CDON::V1::Schema.new to_xml
    end

    def xml
      @xml ||= begin
        Nokogiri::XML::Builder.new do |xml|
          shopping_mall_wrapper xml
        end
      end
    end

    def source_id
      @source_id ||= config.fetch('source_id')
    end

    def shopping_mall_wrapper(xml)
      options = {
        source_id: source_id,
        xmlns: 'http://schemas.cdon.com/product/2.0/shopping-mall.xsd',
        version: 1,
        import_id: 2,
        import_type: 'FULL',
        import_date: Time.now.to_s(:xml_date),
        import_previous_id: 1,
      }

      xml.cdon_shopping_mall_import(**options) do |xml|
        xml.documents do |xml|
          products_xml xml
        end
      end
    end

    def products_xml(xml)
      xml.products do |xml|
        masters.each do |product|
          @product = product

          options = {
            id: product.sku,
          }

          xml.product(**options) do |xml|
            product_class_xml xml
            gtin_xml xml
            art_no_xml xml
            characteristics_xml xml
            status_xml xml
            sales_channels_xml xml if (variants[product.sku] || []).empty?
            variations_xml xml
          end
        end
      end
    end

    def product_class_xml(xml)
      product.categories.each do |cat|
        xml.class_ id: cat.id
      end
    end

    def gtin_xml(xml)
      xml.gtin value: product.sku
    end

    def art_no_xml(xml)
      xml.manufacturerArtNo value: product.ean
    end

    def status_xml(xml)
      xml.productStatus do |xml|
        xml.status 'ONLINE'
        xml.exposeStatus 'BUYABLE'
        xml.inStock product.stock_count
      end
    end

    def characteristics_xml(xml)
      xml.values do |xml|
        attributes_xml xml
        available_variations_xml xml
      end
    end

    def variations_xml(xml)
      CDON::V1::ProductVariation.new \
        product,
        variants[product.sku],
        variations,
        shop,
        xml
    end

    def attributes_xml(xml)
      CHARACTERISTICS.each do |k, v|
        xml.attribute id: k do |xml|
          xml.value product.public_send(v)
        end
      end
    end

    def available_variations_xml(xml)
      return if variations.empty?

      xml.variations do |xml|
        variations.each do |field|
          xml.key attribute: field do |xml|
            (variants[product.sku] || []).each do |var|
              # Becuase the `field` can have the `count` value we can't use
              # public_send, and will need to use the #[] method instead.
              xml.variation value: var[field] do |xml|
              end
            end
          end
        end
      end
    end

    def sales_channels_xml(xml)
      xml.salesChannels do |xml|
        xml.channel iso: country do
          xml.price \
            current: offer_price,
            vat: vat,
            ordinary: ordinary_price,
            currency: currency
          xml.sellable variations.empty?
        end
      end
    end

    def country
      config.fetch('country')
    end

    def vat
      config.fetch('vat')
    end

    def offer_price
      product.offer_price.cents / 100.0
    end

    def ordinary_price
      product.original_price.cents / 100.0
    end

    def currency
      product.original_price.currency
    end

    def variations
      product.categories.collect(&:variations).flatten.compact
    end

    def config
      shop.fetch('config')
    end
end

# rubocop:enable Metrics/ClassLength
