# frozen_string_literal: true

require 'product_validator'

class V1::Vendors::ChannelProductMatchWorker #:nodoc:
  include Sidekiq::Worker

  sidekiq_options \
    queue: :product_matches,
    backtrace: true,
    lock: :until_executed,
    on_conflict: :replace

  attr_reader :product, :shop

  # Matches the product to each of the channels configured as distribution for
  # the shop.
  def perform(shop_id, product_id)
    @shop = Shop.find shop_id
    @product = shop.products.find product_id
    calculate_match
    ProductCache.write product
    ProductBroadcast.broadcast product
  rescue ActiveRecord::RecordNotFound
    logger.warn "Failed to find Product(#{product_id}) in Shop(#{shop_id})"
    false
  end

  private

    def update_vendors
      shop.dispersal_vendors.each do |vendor|
        update_vendor vendor
      end
    end

    # rubocop:disable Metrics/AbcSize

    def update_vendor(vendor)
      options = {
        shop: shop,
        vendor: vendor,
        channel: vendor.channel,
      }

      Rails.logger.info "Calculating match for Shop(#{shop.name}) for Vendor(#{vendor.name}) for Product(#{product.id})"
      validator = ::ProductValidator.new product, options

      product_match(product, vendor).update \
        matched: validator.valid?,
        error: validator.errors.collect { |k, v| "#{k}: #{v}" }
    end

    # rubocop:enable Metrics/AbcSize

    def product_match(product, vendor)
      config = product.shop.vendor_config_for vendor
      product.vendor_product_matches.find_or_create_by \
        vendor_shop_configuration: config
    end

    def calculate_match
      update_vendors

      # If this is a master product match variants also
      calculate_variants
    end

    def calculate_variants
      return unless product.master?

      product.variants.each do |v|
        self.class.perform_async shop.id, v.id
      end
    end
end
