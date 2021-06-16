# frozen_string_literal: true

class Smartweb::V1::Workers::Orders::CollectionWorker < Smartweb::V1::Workers::BaseWorker
  sidekiq_options \
    queue: :orders_collection

  attr_reader :shop_id

  def perform(shop_id)
    @shop_id = shop_id

    logger.info 'Collect Orders Vendor -> Core'

    smartweb_api.orders.each do |order|
      next unless order[:reference_number].present?
      next unless order[:tracking_code].present?

      core_api.update_order shop_id, id: order[:reference_number], track_and_trace_reference: order[:tracking_code]
    rescue => e
      # Rollbar.error 'Failed to update Order on Core', order: order
      Arctic.logger.error "Failed to update Order on Core #{e.inspect}"
      next
    end
  end

  private

  def core_api
    @core_api ||= Arctic::Vendor::Collection::API.new
  end

  def shop
    @shop ||= core_api.get_shop(shop_id)
  end

  def smartweb_api
    @smartweb_api ||= Smartweb::V1::API.new(shop)
  end
end
