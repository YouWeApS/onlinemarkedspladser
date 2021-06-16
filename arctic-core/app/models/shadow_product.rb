# frozen_string_literal: true

class ShadowProduct < ApplicationRecord #:nodoc:
  belongs_to :vendor_shop_configuration
  belongs_to :product, -> { with_deleted }, touch: true

  belongs_to :offer_price,
    class_name: 'ProductPrice',
    foreign_key: :offer_price_id,
    optional: true

  belongs_to :original_price,
    class_name: 'ProductPrice',
    foreign_key: :original_price_id,
    optional: true

  has_one :master, through: :product
  has_one :vendor, through: :vendor_shop_configuration

  has_many :dispersals, -> { without_deleted }, through: :product
  has_many :vendor_product_matches, through: :product
  has_many :failed_vendor_product_matches, -> { without_deleted }, through: :product
  has_many :product_errors

  delegate :last_dispersed_at_for, to: :product
  delegate :images, to: :product
  delegate :stock_count, to: :product
  delegate :vendor, to: :vendor_shop_configuration
  delegate :master?, to: :product

  before_save :enforce_vendor_shop_configuration_id
  before_create :enforce_vendor_shop_configuration_id

  Product::CHARACTERISTICS.except('description').each do |field|
    validates field, length: { maximum: 256 }
  end

  validates :description, length: { maximum: 2000 }
  validates :legal_disclaimer, length: { maximum: 500 }

  validate :key_features_value_length,
           :platinum_keywords_value_length,
           :sku_uniqueness

  INTERNAL_FIELDS = %w[
    id
    vendor_id
    product_id
    master_id
    ean
    variant_ids
    vendor_shop_configuration_id
    enabled
  ].freeze

  Product::CHARACTERISTICS.each do |char|
    define_method "#{char}=" do |value|
      super value.blank? ? nil : value
    end
  end

  def self.disabled_products
    where(enabled: false)
  end

  def self.enabled_products
    where(enabled: true)
  end

  private

    def key_features_value_length
      key_features.each do |value|
        errors.add(:key_features, "Can't be bigger than 500") if value[1].length > 500
      end
    end

    def platinum_keywords_value_length
      platinum_keywords.each do |value|
        errors.add(:platinum_keywords, "Can't be bigger than 50") if value[1].length > 50
      end
    end

    def sku_uniqueness
      if ShadowProduct.where(vendor_shop_configuration: vendor_shop_configuration)
             .where.not(product_id: product_id)
             .includes(:product)
             .map{ |shadow| shadow.sku.nil? ? shadow.product.sku : shadow.sku }.include? sku
        errors.add(:sku, "This SKU already taken!")
      end
    end

    def enforce_vendor_shop_configuration_id
      self.vendor_shop_configuration_id ||= product.shop.vendor_config_for(vendor).try(:id)
    end
end
