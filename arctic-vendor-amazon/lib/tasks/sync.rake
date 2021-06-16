# frozen_string_literal: true

# rubocop:disable Style/RescueStandardError

namespace :sync do
  desc 'Sync all amazon products, orders etc.'
  task all: %i[products orders]

  desc 'Sync all amazon products'
  task :products do
    core_api = Arctic::Vendor::Dispersal::API.new

    core_api.list_shops do |shop|
      Amazon::Workers::Products.perform_async shop['id'], continue: true
    end
  end

  desc 'Sync product inventory'
  task :inventory do
    core_api = Arctic::Vendor::Dispersal::API.new

    core_api.list_shops do |shop|
      Amazon::Workers::Inventory.perform_async shop['id'], ignore_errors: true
    end
  end

  desc 'Sync all amazon orders'
  task :orders do
    core_api = Arctic::Vendor::Dispersal::API.new

    core_api.list_shops do |shop|
      shop_id = shop.fetch 'id'

      last_synced_at = 1.days.ago

      credentials = Amazon::Credentials.parse shop.fetch('auth_config')
      marketplace = credentials.fetch 'marketplace'

      az_client = MWS.orders credentials

      # Request orders since last synced
      response = az_client.list_orders marketplace, last_updated_after: last_synced_at
      response_hash = Hash.from_xml response.body

      # Extract orders from response
      orders = response_hash.dig('ListOrdersResponse', 'ListOrdersResult', 'Orders', 'Order')
      orders = [orders].flatten(1).compact

      shipping_mappings = core_api.get_shipping_mappings_for_shop(shop_id)
      p "Shipping mappings: #{shipping_mappings}"
      # Loop through each order. If we already have it in the
      orders.each do |order|
        order_id = order['AmazonOrderId']

        order_status = order['OrderStatus'].to_s.downcase
        next if %w[canceled].include? order_status

        existing_order = core_api.lookup_order(shop_id, order_id)

        items_response = az_client.list_order_items order_id
        items_response_hash = Hash.from_xml items_response.body
        items = items_response_hash.dig('ListOrderItemsResponse', 'ListOrderItemsResult', 'OrderItems', 'OrderItem')
        items = [items].flatten(1).compact

        order_data = Amazon::Formatters::Order.new(order, items, shipping_mappings).for :core_api

        empty_billing_address = order_data.as_json['shipping_address'].values.compact.uniq.empty?

        if empty_billing_address
          Arctic.logger.info "Empty billing address for Shop(#{shop_id})/Order(#{order_id}): Skipping"
          next
        end

        if order_data[:shipping_address].blank? || order_data[:billing_address].blank?
          Arctic.logger.info "Skipping order #{order_id}: Missing billing address and/or shipping address"
          next
        end

        order_response = if existing_order.status < 400
          order_data['id'] = existing_order.body['id']
          core_api.update_order shop_id, order_data.without(:order_lines_attributes)
        else
          core_api.create_order shop_id, order_data.without(:order_lines_attributes)
                         end

        if order_response.status < 400
          # Send all OrderLines related to the order
          order_data.fetch(:order_lines_attributes, []).each do |line|
            core_api.collect_order_line shop_id, order_data.fetch(:order_id), line
          end
        end

        raise order_response.body.to_s if order_response.status >= 400
      rescue => e
        Rollbar.error e,
          shop_id: shop_id,
          order_id: order_id,
          order_data: order
      end

      core_api.synced shop_id, :orders
    end
  end
end

# rubocop:enable Style/RescueStandardError
