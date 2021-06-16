# frozen_string_literal: true

class V1::Vendors::ShadowProductWorker #:nodoc:
  include Sidekiq::Worker

  sidekiq_options \
    queue: :shadow_products,
    backtrace: !Rails.env.production?,
    unique: :until_executed

  attr_reader :product

  def perform(product_id)
    @product = Product.find product_id

    # Create shadow products for each of the vendors for this product
    product.shop.vendors.each do |vendor|
      create_shadow vendor
    end
  end

  private

    def create_shadow(vendor)
      shadow = ShadowProduct.with_deleted.find_or_initialize_by \
        product: product,
        vendor_shop_configuration: product.shop.vendor_config_for(vendor)
      deteremine_master_id shadow
      deteremine_master_ean shadow
      format_sku shadow
      shadow.save!
      update_variant_ids shadow
    end

    def format_sku(shadow)
      sku = shadow.sku || shadow.product.sku
      formatted_sku = shadow.vendor.sku_formatter.new(sku).to_s
      shadow.sku = formatted_sku if sku != formatted_sku
    end

    def deteremine_master_id(shadow)
      return nil if shadow.product.master?

      master_shadow = shadow.product.master.try(:shadow_product, shadow.vendor)

      shadow.master_id = master_shadow.try(:id)
    end

    # If the master of the product does not have an EAN, set an EAN
    def deteremine_master_ean(shadow)
      return if shadow.product.master? || shadow.product.master.ean.present?

      new_ean = shadow.ean.presence || shadow.product.ean
      shadow.product.master.update ean: new_ean
    end

    def update_variant_ids(shadow)
      master = shadow.product.master? ? shadow.product : shadow.product.master

      shadow_product_vendor = shadow_product_vendor(shadow)

      shadow_variants = shadow_product_vendor.where(product: master.variants)
        .or(shadow_product_vendor.where(product: master))

      variants_ids = shadow_variants.pluck(:id)
      shadow_variants.update_all(variant_ids: variants_ids)
    end

    def shadow_product_vendor(shadow)
      ShadowProduct.with_deleted
        .where(vendor_shop_configuration: shadow.vendor_shop_configuration)
    end
end
