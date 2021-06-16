# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize

# Merges the master product (and it's shadow) and the product's shadow into a
# single product.
class ProductMerger
  attr_reader \
    :product,
    :master,
    :vendor,
    :shadow

  def initialize(product, vendor: nil, **)
    raise ArgumentError, 'product must be a product' unless product.is_a? Product

    @product = product
    @master = product.master
    @vendor = vendor
    @shadow = product.shadow_product(vendor) if vendor
  end

  def result
    merge_master_product
    merge_shadow_product
    merge_shadow_product_prices
    merge_shadow_categories
    merge_master_categories
    merge_variant_ean
    product
  end

  private

    def merge_variant_ean
      return if product.variant? || product.variants.empty?

      product.ean = product.variants.order('ean asc nulls last').first.try(:ean)
    end

    def merge_shadow_product_prices(object = product)
      original_price = object.shadow_product(vendor).original_price
      original_price ||= object.original_price
      product.original_price = original_price

      offer_price = object.shadow_product(vendor).offer_price
      offer_price ||= object.offer_price
      product.offer_price = offer_price
    end

    def merge_shadow_product(object = product)
      object
        .shadow_product(vendor)
        .attributes
        .except(*ShadowProduct::INTERNAL_FIELDS, 'master_sku')
        .each do |k, v|
          product.public_send("#{k}=", v) if v.present?
        end

      product.deleted_at ||= object.deleted_at
    end

    def merge_shadow_categories
      return if product.categories.any? || !shadow

      product.categories.concat shadow.categories
    end

    def merge_master_categories
      return if product.categories.any? || !master

      product.categories.concat master.categories
    end

    def merge_master_product
      return unless master

      merge_shadow_product master

      master
        .attributes
        .slice(*Product::CHARACTERISTICS)
        .except('ean')
        .each do |k, v|
        product.public_send("#{k}=", v) if v.present? && product.public_send(k).blank?
      end

      product.deleted_at ||= master.deleted_at
    end
end

# rubocop:enable Metrics/AbcSize
