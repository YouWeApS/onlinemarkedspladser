# frozen_string_literal: true

class Shop < ApplicationRecord #:nodoc:
  belongs_to :account

  has_many :collection_vendor_configurations, class_name: 'VendorShopCollectionConfiguration'
  has_many :collection_vendors, through: :collection_vendor_configurations, source: :vendor
  has_many :dispersal_vendor_configurations, class_name: 'VendorShopDispersalConfiguration'
  has_many :dispersal_vendors, through: :dispersal_vendor_configurations, source: :vendor
  has_many :vendor_shop_configurations
  has_many :vendors, through: :vendor_shop_configurations
  has_many :products
  has_many :currency_conversions
  has_many :orders

  def vendor_config_for(vendor)
    dispersal_vendor_configurations.where(vendor: vendor).take ||
      collection_vendor_configurations.where(vendor: vendor).take
  end

  def shipping_configurations_for(vendor)
    vendor_config_for(vendor).shipping_configurations
  end
end
