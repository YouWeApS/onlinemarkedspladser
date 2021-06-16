# frozen_string_literal: true

class V1::Vendors::ShopBlueprint < Blueprinter::Base #:nodoc:
  identifier :id

  field :collected_at do |shop, options|
    vendor = options[:vendor]
    shop.vendor_config_for(vendor).last_synced_at
  end

  field :config do |shop, options|
    shop.vendor_config_for(options[:vendor]).config
  end

  field :shipping_mappings do |shop, options|
    mappings = shop.shipping_configurations_for(options[:vendor]).collect do |s_config|
      V1::Vendors::ShippingMappingBlueprint.render_as_hash s_config
    end
    mappings
  end

  field :auth_config do |shop, options|
    vendor = options[:vendor]
    shop.vendor_config_for(vendor).auth_config
  end

  field :product_parse_config do |shop, options|
    vendor = options[:vendor]
    config = shop.vendor_config_for vendor
    config.import_maps.collect do |im|
      V1::Vendors::ImportMapBlueprint.render_as_hash im
    end
  end
end
