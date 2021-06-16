# frozen_string_literal: true

class Mirakl::Workers::Orders::VendorUpdateWorker < Mirakl::Workers::Base
  sidekiq_options \
    queue: :orders_update

  attr_reader :shop_id

  def perform(shop_id)
    @shop_id = shop_id

    collected_at = Time.current

    core_dispersal_api.orders(shop_id, since: last_synced_at).each { |order| process_order(order) }

    core_dispersal_api.synced shop_id: shop_id, routine: :orders, time: collected_at
  end

  private

  def process_order order
    track_and_trace_reference = order.dig('order_lines', 0, 'track_and_trace_reference')

    return unless track_and_trace_reference.present?

    mirakl_api.ship_order(order['order_id'])
    mirakl_api.update_order_tracking(order['order_id'], trackingNumber: track_and_trace_reference)
  end

  def last_synced_at
    @last_synced_at ||= core_dispersal_api.last_synced_at shop_id, :orders
  end
end