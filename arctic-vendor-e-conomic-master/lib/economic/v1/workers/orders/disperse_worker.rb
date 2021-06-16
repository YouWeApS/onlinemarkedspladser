# frozen_string_literal: true

class Economic::V1::Workers::Orders::DisperseWorker < Economic::V1::Workers::BaseWorker
  sidekiq_options \
    queue: :orders_disperse

  attr_reader :shop_id

  def perform(shop_id)
    @shop_id = shop_id

    logger.info "Dispersing orders since #{last_synced_at} from Shop(#{shop_id}) -> E-conomic"

    collected_at = Time.current

    core_api.orders(shop_id, since: last_synced_at).each do |order|
      customer = Economic::V1::Customer.new(shop: shop, order: order).find_or_create!

      Economic::V1::Order.new(shop: shop, customer_number: customer['customerNumber'], order: order).save!

      core_api.order_dispersed(shop_id, order['id'])
    rescue => e
      logger.error "Unable to disperse Order(#{order['id']}) => (#{e.class}): #{e.message}"

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
