# frozen_string_literal: true

# The V1::Ui::ProductBlueprint really masquarades the shadow product as the
# product for UI purposes. This is because the UI shouldn't edit the real
# product record.
class V1::Ui::ProductBlueprint < Blueprinter::Base #:nodoc:
  identifier :id

  fields \
    :brand,
    :color,
    :description,
    :ean,
    :manufacturer,
    :master_sku,
    :material,
    :name,
    :size,
    :sku,
    :categories,
    :count,
    :scent,
    :gender,
    :enabled,
    :key_features,
    :platinum_keywords,
    :legal_disclaimer,
    :search_terms

  association :original_price, blueprint: V1::Vendors::ProductPriceBlueprint
  association :offer_price, blueprint: V1::Vendors::ProductPriceBlueprint

  field :vendor_id do |shadow|
    shadow.vendor.id
  end

  field :enabled_for_vendors do |shadow|
    ids = shadow.product.shop.vendor_shop_configurations.pluck(:id)

    Hash[
      shadow
        .product
        .shadow_products
        .with_deleted
        .includes(vendor_shop_configuration: [vendor: :channel])
        .where(vendor_shop_configuration_id: ids)
        .joins(:vendor)
        .collect do |s|
          [
            s.vendor.name,
            [s.enabled, s.id]
          ]
        end
    ]
  end

  field :master_id do |shadow|
    shadow.master_id if shadow.master_id.present?
  end

  field :deleted_at do |shadow|
    shadow.deleted_at.strftime(DATE_FORMAT) if shadow.deleted_at.present?
  end

  field :variants do |shadow|
    ids = (shadow.variant_ids + [shadow.master_id, shadow.id]).uniq.compact
    list = {}

    ShadowProduct.with_deleted
      .where(id: ids)
      .includes(:vendor_shop_configuration, product: %i[master shop original_price offer_price])
      .find_each do |s|
      merged_product = ProductMerger.new(s.product, vendor: s.vendor)
      list[s.id] = merged_product.result.sku
    end

    Hash[list.sort_by { |_, sku| sku }]
  end

  field :created_at do |shadow|
    shadow.created_at.strftime(DATE_FORMAT)
  end

  field :updated_at do |shadow|
    shadow.updated_at.strftime(DATE_FORMAT) if shadow.updated_at.present?
  end

  field :dispersal_state do |shadow, options|
    config = shadow.product.shop.vendor_config_for options[:vendor]

    shadow
      .product
      .dispersals
      .where(vendor_shop_configuration: config)
      .order(updated_at: :desc)
      .limit(1)
      .take
      .try(:state)
  end

  field :last_dispersed_at do |shadow|
    shadow.product.last_dispersed_at_for shadow.vendor
  end

  field :errors do |shadow|
    shadow.errors.messages.reject { |c| c.empty? }.each do |er|
      new_error = ProductError.new(message: er[0].to_s + ': ' + er[1][0])
      unless shadow.product_errors.map{ |e| e.message }.include? new_error.message
        shadow.product_errors << new_error
      end
    end

    V1::Ui::ProductErrorBlueprint.render_as_hash shadow.product_errors
  end

  field :match_errors do |shadow, options|
    config = shadow.product.shop.vendor_config_for options[:vendor]

    V1::Ui::VendorProductMatchBlueprint.render_as_hash shadow
      .product
      .vendor_product_matches
      .unmatched
      .where(vendor_shop_configuration: config)
  end

  field :preview do |shadow, options|
    merged_product = ProductMerger.new(shadow.product, vendor: shadow.vendor)
    # Need to preload images association
    merged_product.product.images.where(position: 1).take
    V1::Vendors::ProductBlueprint.render_as_hash merged_product.result, options
  end
end
