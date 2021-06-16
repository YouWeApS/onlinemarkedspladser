# frozen_string_literal: true

class Smartweb::V1::Workers::Categories::CollectionWorker < Smartweb::V1::Workers::BaseWorker
  sidekiq_options \
    queue: :categories_collection

  attr_reader :shop_id

  def perform(shop_id)
    @shop_id = shop_id
    logger.info "Collecting categories from Smartweb -> Core API"

    smartweb.categories.each do |category|
      core.create_product_category(shop_id: shop_id, category: category)
    rescue => e
      Rollbar.error e, "Failed to create Product Category (SHOP_ID: #{shop['id']})", category: category
    end
  end

  private
    def core
      @core ||= Arctic::Vendor::Collection::API.new
    end

    def shop
      @shop ||= core.get_shop(shop_id)
    end

    def smartweb
      @smartweb ||= Smartweb::V1::API.new(shop)
    end

    def create_smartweb_vendor_category(category)
      endpoint = "shops/#{shop_id}/smartweb_vendor_categories"

      core.connection.public_send :post, endpoint do |request|
        request.body = category.to_json
      end
    end
end
