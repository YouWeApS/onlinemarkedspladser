# frozen_string_literal: true

# CDON documentation: http://bit.ly/2SBDYEr
class CDON::V2::ProductBuilder
  attr_reader :product, :builder, :options, :variants

  def initialize(product, builder, **options)
    @product = Hashie::Mash.new product
    @builder = builder
    @options = options.as_json
    @variants = @options.fetch('variants', []).collect { |pr| Hashie::Mash.new pr }
  end

  def build
    builder.product do |xml|
      identity_xml xml
      title_xml xml
      description_xml xml
      category_xml xml
      variants_xml xml
    end
  end

  private

    def variants_xml(xml)
      return if variants.empty? || category.variation_theme.blank?

      xml.variants do |xml|
        variants.each do |var|
          variant_xml var, xml
        end
      end
    end

    def variant_xml(var, xml)
      xml.send(category.variation_theme) do |xml|
        xml.identity do |xml|
          xml.id var.sku
        end

        xml.send(category.variation_field) do |xml|
          xml.default var.public_send(category.variation_field)
        end
      end
    end

    def category
      @category ||= Hashie::Mash.new((product.categories || []).first || {})
    end

    def category_xml(xml)
      return if category.main.to_s.strip.blank?

      xml.category do |xml|
        if category.secondary.present?
          secondary_category_xml xml
        else
          primary_category_xml xml
        end
      end
    end

    def primary_category_xml(xml)
      xml.public_send(category.main, category.value)
    end

    def secondary_category_xml(xml)
      xml.public_send(category.main) do |xml|
        xml.public_send(category.secondary, category.value)
      end
    end

    def identity_xml(xml)
      xml.identity do |xml|
        xml.id product.sku
      end
    end

    def title_xml(xml)
      xml.title do |xml|
        xml.default product.name
      end
    end

    def description_xml(xml)
      xml.description do |xml|
        xml.default product.description
      end
    end
end
