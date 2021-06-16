# frozen_string_literal: true

class Mirakl::Workers::Orders::Collection < Mirakl::Workers::Base
  sidekiq_options \
    queue: :orders_collection

  def perform(shop_id)
    @shop_id = shop_id

    pending_orders.each { |order| process_pending_order(order) }
  end

  private

  def pending_orders
    @pending_orders ||= mirakl_api.get_orders(state: 'WAITING_ACCEPTANCE')
  end

  def process_pending_order(order)
    order_accept_data = { order_lines: [] }

    order['order_lines'].each do |order_line|
      core_product = core_dispersal_api.get_product(shop_id, order_line['product_sku'])

      accepted = core_product['stock_count'] >= order_line['quantity']

      order_accept_data[:order_lines] << { id: order_line['order_line_id'], accepted: accepted }
    end

    mirakl_api.accept_order(order['order_id'], order_accept_data)

    return unless order_accept_data[:order_lines].any? { |order_line| order_line[:accepted] == true }

    process_order(mirakl_api.get_order(order['order_id']))
  rescue => e
    Rollbar.error e, 'Failed to process pending order', shop_id: shop_id, order: order
  end

  def process_order(order)
    existing_order_response = core_dispersal_api.lookup_order(shop_id, order['id'])
    existing_order_data     = existing_order_response.success? ? existing_order_response.body : nil

    formatted_order = Mirakl::Formatters::Order.new(order, existing_order_data, shop['shipping_mappings']).format

    order_response = \
      if existing_order_data.present?
        formatted_order['id'] = existing_order_data['id']
        core_dispersal_api.update_order shop_id, formatted_order
      else
        core_dispersal_api.create_order shop_id, formatted_order
      end

    raise order_response.body.to_s unless order_response.success?
  rescue => e
    core_dispersal_api.order_error(shop_id, existing_order_data['id'], e) if existing_order_data.present?
  end
end