# frozen_string_literal: true

class V1::Ui::VendorBlueprint < Blueprinter::Base #:nodoc:
  identifier :id

  fields :name

  field :last_synced_at do |vendor, options|
    shop = options[:shop]

    if shop
      config = shop.vendor_config_for vendor
      config.last_synced_at
    end
  end

  field :enabled do |vendor, options|
    shop = options[:shop]

    if shop
      config = shop.vendor_config_for vendor
      config.enabled
    else
      false
    end
  end

  field :webhooks do |vendor, options|
    shop = options[:shop]

    if shop
      config = shop.vendor_config_for vendor
      config.webhooks
    else
      {}
    end
  end

  field :config do |vendor, options|
    shop = options[:shop]

    if shop
      config = shop.vendor_config_for vendor
      view = config.collection? ? :collection : :dispersal
      V1::Ui::VendorShopConfigurationBlueprint.render_as_hash config, view: view
    else
      {}
    end
  end

  field :type do |vendor, options|
    shop = options[:shop]

    if shop
      config = shop.vendor_config_for vendor
      case config.type.to_s
      when 'VendorShopCollectionConfiguration' then :collection
      else :dispersal
      end
    end
  end

  association :channel, blueprint: V1::Ui::ChannelBlueprint
end
