# frozen_string_literal: true

# The V1::Ui::ProductBlueprint really masquarades the shadow product as the
# product for UI purposes. This is because the UI shouldn't edit the real
# product record.
class V1::Ui::ProductListBlueprint < Blueprinter::Base #:nodoc:
  identifier :id

  fields \
    :master_id,
    :enabled

  field :master_sku do |shadow|
    shadow.master_sku.nil? ? shadow.product.master.try(:sku) : shadow.master_sku
  end

  field :name do |shadow|
    shadow.name.nil? ? shadow.product.name : shadow.name
  end

  field :ean do |shadow|
    shadow.ean.nil? ? shadow.product.ean : shadow.ean
  end

  field :sku do |shadow|
    shadow.sku.nil? ? shadow.product.sku : shadow.sku
  end

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

  field :deleted_at do |shadow|
    shadow.deleted_at.strftime(DATE_FORMAT) if shadow.deleted_at.present?
  end

  field :variants do |shadow|
    shadow.variant_ids
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

  field :match_errors do |shadow, options|
    config = shadow.product.shop.vendor_config_for options[:vendor]

    V1::Ui::VendorProductMatchBlueprint.render_as_hash shadow
                                                           .product
                                                           .vendor_product_matches
                                                           .unmatched
                                                           .where(vendor_shop_configuration: config)
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

  field :images do |shadow|
    V1::Vendors::ProductImageBlueprint.render_as_hash shadow.images.where(position: 1)
  end

end
