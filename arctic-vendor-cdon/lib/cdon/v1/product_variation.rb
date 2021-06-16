# frozen_string_literal: true

class CDON::V1::ProductVariation
  attr_reader :product, :variants, :builder, :permutations, :shop

  def initialize(product, variants, permutations, shop, builder)
    @product = product
    @variants = (variants || []).compact
    @builder = builder
    @permutations = permutations
    @shop = shop
    build_xml
  end

  private

    def country
      @country ||= shop.fetch('config').fetch('country')
    end

    def vat
      @vat ||= shop.fetch('config').fetch('vat')
    end

    def build_xml
      return if variants.empty?

      builder.productVariations do |xml|
        variants.each do |variant|
          xml.sku id: variant.sku do |xml|
            xml.status 'ONLINE'
            xml.exposeStatus 'BUYABLE'
            xml.inStock variant.stock_count
            xml.manufacturerArtNo value: variant.ean

            build_permutations_xml variant, xml
          end
        end
      end
    end

    def build_permutations_xml(variant, xml)
      return if permutations.empty?

      permutations.each do |field|
        # Becuase the `field` can have the `count` value we can't use
        # public_send, and will need to use the #[] method instead.
        xml.variation key: field, value: variant[field]
        xml.salesChannels do
          xml.channel iso: country do |xml|
            build_price_xml variant, xml
          end
        end
      end
    end

    def build_price_xml(variant, xml)
      xml.price \
        current: current_price(variant),
        ordinary: ordinary_price(variant),
        currency: currency(variant),
        vat: vat

      xml.sellable true
    end

    def current_price(variant)
      cents = variant.offer_price.cents.presence || variant.original_price.cents.presence || 0
      cents / 100.0
    end

    def ordinary_price(variant)
      cents = variant.original_price.cents.presence || variant.offer_price.cents.presence || 0
      cents / 100.0
    end

    def currency(variant)
      variant.offer_price.currency.presence || variant.original_price.current_price.presence
    end
end
