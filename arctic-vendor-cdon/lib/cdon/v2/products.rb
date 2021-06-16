# frozen_string_literal: true

require 'hashie/mash'
require 'nokogiri'

class CDON::V2::Products < CDON::V2::Feed
  attr_reader :products, :options, :errors

  def initialize(products, **options)
    raise ArgumentError, 'products must be an array' unless products.is_a? Array
    raise ArgumentError, 'options must be a Hash' unless options.is_a? Hash

    @products = products.as_json
    @options = Hashie::Mash.new options
    @errors = []
  end

  def valid?
    validator.validate
    @errors = validator.errors
    validator.valid?
  end

  def to_xml
    @to_xml ||= xml.to_xml
  end

  private

    def validator
      @validator ||= CDONFeedValidator::Product.new to_xml
    end

    def xml
      Nokogiri::XML::Builder.new do |xml|
        xml.marketplace(xmlns: 'https://schemas.cdon.com/product/4.0/4.1.0/product') do |xml|
          master_products.each do |master|
            CDON::V2::ProductBuilder.new(master, xml, variants: variants(master)).build
          end
        end
      end
    end

    def master_products
      @master_products ||= products.select { |pr| pr['master_sku'].blank? }
    end

    def variants(master)
      products.select { |pr| pr['master_sku'] == master['sku'] }
    end

    def endpoint
      'product'
    end
end
