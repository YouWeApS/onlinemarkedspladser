# frozen_string_literal: true

require 'sku'

class Product < ApplicationRecord #:nodoc:

  CHARACTERISTICS = %w[
    sku
    brand
    color
    description
    ean
    manufacturer
    master_id
    material
    name
    size
    sku
    gender
    count
    scent
  ].freeze

  attr_accessor :legal_disclaimer
  attr_accessor :search_terms
  attr_accessor :key_features
  attr_accessor :platinum_keywords

  belongs_to :shop

  belongs_to :master,
    class_name: 'Product',
    foreign_key: :master_id,
    optional: true,
    counter_cache: :variants_count

  belongs_to :offer_price,
    class_name: 'ProductPrice',
    foreign_key: :offer_price_id,
    optional: true

  belongs_to :original_price,
    class_name: 'ProductPrice',
    foreign_key: :original_price_id,
    optional: true

  has_many :variants,
    class_name: 'Product',
    foreign_key: :master_id,
    dependent: :destroy

  has_many :raw_product_data,
    dependent: :destroy

  has_many :images,
    class_name: 'ProductImage',
    dependent: :destroy

  has_many :vendor_product_matches,
    dependent: :destroy

  has_many :failed_vendor_product_matches,
    -> { unmatched },
    class_name: 'VendorProductMatch',
    foreign_key: :product_id

  has_many :dispersals,
    dependent: :destroy

  has_many :vendor_shop_configurations,
    through: :vendor_product_matches

  has_many :vendors,
    through: :vendor_shop_configurations

  has_many :shadow_products,
    dependent: :destroy

  def sku=(value)
    super Sku.new(value).to_s[0, 256]
  end

  CHARACTERISTICS.except('sku', 'description').each do |field|
    define_method "#{field}=" do |value|
      super value.to_s[0, 256]
    end
  end

  def description=(value)
    super value.to_s[0, 2000]
  end

  def master?
    master_id.blank?
  end

  def variant?
    !master?
  end

  def shadow_product(vendor)
    config = shop.vendor_config_for vendor
    shadow_products.with_deleted.find_or_create_by vendor_shop_configuration: config
  end

  def last_dispersed_at_for(vendor)
    vendor = shop.dispersal_vendors.find vendor.try(:id)
    config = shop.vendor_config_for vendor
    dispersals
      .with_state(:completed)
      .where(vendor_shop_configuration: config)
      .maximum(:updated_at)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def most_recent_dispersal(vendor)
    config = shop.vendor_config_for vendor
    dispersals
      .where(vendor_shop_configuration: config)
      .order(updated_at: :desc)
      .take
  end
end
