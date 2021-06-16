# frozen_string_literal: true

class V1::Ui::VendorShopConfigurationBlueprint < Blueprinter::Base #:nodoc:
  identifier :id

  fields \
    :config,
    :auth_config,
    :price_adjustment_value,
    :price_adjustment_type,
    :currency_config,
    :webhooks

  view :collection do
    field :product_parse_config do |config, *|
      config.import_maps.collect do |im|
        V1::Vendors::ImportMapBlueprint.render_as_hash(im)
      end
    end
    field :shipping_mappings do |config, options|
      config.shipping_configurations.includes(:shipping_carrier, :shipping_method).collect do |s_config|
        V1::Vendors::ShippingMappingBlueprint.render_as_hash s_config
      end
    end
  end

  view :dispersal do
    field :product_parse_config do |config, *|
      config.import_maps.collect do |im|
        V1::Vendors::ImportMapBlueprint.render_as_hash(im)
      end
    end
    field :shipping_mappings do |config, options|
      config.shipping_configurations.includes(:shipping_carrier, :shipping_method).collect do |s_config|
        V1::Vendors::ShippingMappingBlueprint.render_as_hash s_config
      end
    end
  end
end
