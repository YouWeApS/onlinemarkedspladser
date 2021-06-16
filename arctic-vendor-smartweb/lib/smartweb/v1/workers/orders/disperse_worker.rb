# frozen_string_literal: true

class Smartweb::V1::Workers::Orders::DisperseWorker < Smartweb::V1::Workers::BaseWorker
  sidekiq_options \
    queue: :orders_disperse

  attr_reader :shop_id

  def perform(shop_id)
    @shop_id = shop_id

    logger.info "Dispersing orders since #{last_synced_at} from Shop(#{shop_id}) -> Vendor"

    collected_at = Time.current

    core_api.orders(shop_id, since: last_synced_at).each do |order|
      next if order['smartweb_order_id'].present?

      Smartweb::V1::Order.new(order: order, shop: shop).create

      core_api.order_dispersed(shop_id, order['id'])
    rescue => e
      Arctic.logger.warn "Failed to disperse Order(#{order['id']}) (#{e.class}): #{e.message}"

      core_api.order_error(shop_id, order['id'], e)

      next
    end

    core_api.synced shop_id: shop_id, routine: :orders, time: collected_at
  end

  private

  def core_api
    @core_api ||= Arctic::Vendor::Collection::API.new
  end

  def shop
    @shop ||= core_api.get_shop shop_id
  end

  def last_synced_at
    return @last_synced_at if defined? @last_synced_at

    @last_synced_at ||= core_api.last_synced_at shop_id, :orders
  end
end
