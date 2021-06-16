# frozen_string_literal: true

class Vendor < ApplicationRecord #:nodoc:
  belongs_to :channel

  has_many :collection_shop_configurations, class_name: 'VendorShopCollectionConfiguration'
  has_many :collection_shops, through: :collection_shop_configurations, source: :shop
  has_many :dispersal_shop_configurations, class_name: 'VendorShopDispersalConfiguration'
  has_many :dispersal_shops, through: :dispersal_shop_configurations, source: :shop
  has_many :dispersal_categories, through: :dispersal_shop_configurations, source: :category_maps
  has_many :vendor_shop_configurations
  has_many :dispersals, through: :vendor_shop_configurations
  has_many :vendor_product_matches, through: :vendor_shop_configurations
  has_many :shadow_products, through: :vendor_shop_configurations

  validates :validation_url,
    presence: true,
    format: RubyRegex::Url

  # Returns collection of both dispersal and collection shops
  def shops
    dispersal_shops.union collection_shops
  end

  validates :token, presence: true

  def name
    if super.present?
      "#{channel.name} (#{super})"
    else
      channel.name
    end
  end

  def sku_formatter
    super.to_s.classify.constantize
  end
end
