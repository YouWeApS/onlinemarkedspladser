# frozen_string_literal: true

class Smartweb::V1::Order
  attr_reader :order, :shop

  ORDER_STATUS_RECEIVED = 1

  def initialize(order:, shop:)
    @order = order
    @shop  = shop
  end

  def create
    response = api.create_order(formatted_order)

    smartweb_order_id = response[:order_create_response][:order_create_result]

    update_to_received(smartweb_order_id)

    update_core(smartweb_order_id)
  end

  private

  def formatted_order
    @formatted_order ||= Smartweb::V1::Formatters::FormatOrder.new(order, shop['id']).format
  end

  def update_to_received(smartweb_order_id)
    api.update_order_status(smartweb_order_id, ORDER_STATUS_RECEIVED)
  end

  def update_core(smartweb_order_id)
    core_api.update_order shop['id'], id: order['id'], smartweb_order_id: smartweb_order_id
  end

  def config
    @config ||= shop.fetch 'config'
  end

  def core_api
    @core_api ||= Arctic::Vendor::Collection::API.new
  end

  def api
    @api ||= Smartweb::V1::API.new shop
  end
end
