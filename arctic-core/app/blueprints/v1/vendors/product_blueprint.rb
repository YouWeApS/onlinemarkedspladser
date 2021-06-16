# frozen_string_literal: true

require 'private_currency_exchange'

class V1::Vendors::ProductBlueprint < Blueprinter::Base #:nodoc:
  field :sku do |product, options|
    if options[:vendor]
      options[:vendor].sku_formatter.new(product.sku).to_s
    else
      product.sku
    end
  end

  field :brand,             if: ->(_, options) { display_field? :brand, options }
  field :color,             if: ->(_, options) { display_field? :color, options }
  field :description,       if: ->(_, options) { display_field? :description, options }
  field :ean,               if: ->(_, options) { display_field? :ean, options }
  field :manufacturer,      if: ->(_, options) { display_field? :manufacturer, options }
  field :name,              if: ->(_, options) { display_field? :name, options }
  field :size,              if: ->(_, options) { display_field? :size, options }
  field :stock_count,       if: ->(_, options) { display_field? :stock_count, options }
  field :material,          if: ->(_, options) { display_field? :material, options }
  field :scent,             if: ->(_, options) { display_field? :scent, options }
  field :count,             if: ->(_, options) { display_field? :count, options }
  field :gender,            if: ->(_, options) { display_field? :gender, options }
  field :key_features,      if: ->(_, options) { display_field? :key_features, options }
  field :platinum_keywords, if: ->(_, options) { display_field? :platinum_keywords, options }
  field :legal_disclaimer,  if: ->(_, options) { display_field? :legal_disclaimer, options }
  field :search_terms,      if: ->(_, options) { display_field? :search_terms, options }

  # association :offer_price, blueprint: V1::Vendors::ProductPriceBlueprint
  association :original_price,
    if: ->(_, options) { display_field? :original_price, options },
    blueprint: V1::Vendors::ProductPriceBlueprint
  association :offer_price,
    if: ->(_, options) { display_field? :offer_price, options },
    blueprint: V1::Vendors::ProductPriceBlueprint

  field :dispersed_at,
    if: ->(_, options) { display_field? :dispersed_at, options } do |product, options|
    product.last_dispersed_at_for options[:vendor]
  end

  field :master_sku,
    if: ->(_, options) { display_field? :master_id, options } do |product, options|
    Product.find(product.master_id).sku if product.master_id
  end

  association :images,
    blueprint: V1::Vendors::ProductImageBlueprint,
    if: ->(_, options) { display_field? :images, options }

  field :categories,
    if: ->(_, options) { display_field? :categories, options } do |product, options|
    vendor = options[:vendor]
    if vendor
      vendor.dispersal_categories.where(source: product.categories).pluck(:value)
    else
      product.categories
    end
  end

  def self.display_field?(field, options)
    if options[:fields]
      options[:fields].include? field.to_s
    else
      true
    end
  end
end
