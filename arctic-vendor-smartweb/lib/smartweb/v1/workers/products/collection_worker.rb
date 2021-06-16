# frozen_string_literal: true

class Smartweb::V1::Workers::Products::CollectionWorker < Smartweb::V1::Workers::BaseWorker
  sidekiq_options \
    queue: :products_collection

  attr_reader :shop_id

  def perform(shop_id)
    @shop_id = shop_id

    logger.info "Collecting products since #{last_synced_at} from Shop(#{shop_id}) -> Core API"

    collected_at = Time.current

    smartweb.products(last_synced_at).each do |product|
      core_api.create_product(shop_id, product)
    rescue => e
      Rollbar.error e, 'Failed to send product to Core', shop_id: shop_id, product: product
    end

    core_api.synced shop_id: shop_id, routine: :products, time: collected_at

    Smartweb::V1::Workers::Categories::CollectionWorker.perform_async shop_id
  end

  private
    def core_api
      @core_api ||= Arctic::Vendor::API.new
    end

    def shop
      @shop ||= core_api.get_shop(shop_id)
    end

    def smartweb
      @smartweb ||= Smartweb::V1::API.new(shop)
    end

    def last_synced_at
      return @last_synced_at if defined? @last_synced_at

      @last_synced_at = core_api.last_synced_at(shop_id, :products)
    end
end
