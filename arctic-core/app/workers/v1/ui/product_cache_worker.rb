# frozen_string_literal: true

require 'product_validator'

class V1::Ui::ProductCacheWorker
  include Sidekiq::Worker

  sidekiq_options \
    queue: :product_caches,
    backtrace: true,
    lock: :until_executing

  attr_reader :product

  def perform(sku)
    @product = Product.find sku

    if product.variant?
      self.class.perform_async product.master_id
      return
    end

    clear_cache
  rescue ActiveRecord::RecordNotFound => e
    err = "Unable to clear cache for Product(#{sku}) (#{e.class}): #{e.message}"
    logger.error err
  end

  private

    def clear_cache
      ProductCache.write product
      product.variants.each do |prod|
        ProductCache.write prod
      end
    end
end
