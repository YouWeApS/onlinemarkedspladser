# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

namespace :sync do
  desc 'Sync all products'
  task all: %i[sync:v1:all]

  desc 'Sync all orders'
  task orders: %i[sync:v1:orders]

  namespace :v1 do
    desc 'Sync all products and orders'
    task all: %i[products:all orders:all]

    namespace :products do
      task all: %i[disperse]

      desc 'Sync products from Core API -> CDON'
      task :disperse do
        core_api = Arctic::Vendor::Dispersal::API.new

        core_api.list_shops do |shop|
          products = core_api.list_products(shop.fetch('id')).uniq
          CDON::V1::Products.new(shop, products).submit

          core_api.synced shop['id'], :products
        end
      end
    end

    namespace :orders do
      task all: %i[collect disperse]

      desc 'Sync orders from Core API -> CDON'
      task :disperse do
        # 1. List shops
        core_api = Arctic::Vendor::Dispersal::API.new

        # 1. List shops
        core_api.list_shops do |shop|
          shop_id = shop['id']

          # 2. Fetch orders from Core API
          last_synced_at = core_api.last_synced_at shop['id'], :orders
          orders = core_api.orders(shop_id, since: last_synced_at)
          Arctic.logger.info "Last synced orders for Shop(#{shop_id}): #{last_synced_at}"
          Arctic.logger.info "Found #{orders.size} orders for Shop(#{shop_id})"

          # 3. Update orders on CDON
          # NOTE: CDON does not support creating orders via API.
          orders.each do |order|
            order['order_lines'].each do |ol|
              ol = CDON::V1::OrderLine.new shop, ol, order['order_id']
              ol.deliver! if ol.track_and_trace_reference
            rescue CDON::V1::OrderLine::InvalidOrderState => e
              core_api.update_order_line shop_id, order['id'], ol.id, status: e.message.to_s.downcase
            rescue CDON::V1::OrderLine::Error => e
              msg = <<~MSG
                Unable to mark order line #{ol} as delivered for Order(#{order['order_id']}) (#{e.class}).
                #{e.message}
              MSG
              Arctic.logger.warn msg
            end
          end

          # 4. Once synced report completion
        end
      end

      desc 'Sync orders from CDON -> Core API'
      task :collect do
        core_api = Arctic::Vendor::Dispersal::API.new

        # 1. List shops
        core_api.list_shops do |shop|
          shop_id = shop['id']

          # 2. Fetch orders from CDON shop
          last_synced_at = core_api.last_synced_at shop['id'], :orders
          orders = CDON::V1::Order.new(shop).since last_synced_at
          Arctic.logger.info "Last synced orders for Shop(#{shop_id}): #{last_synced_at}"
          Arctic.logger.info "Found #{orders.size} orders for Shop(#{shop_id})"

          # 3. Send orders to Core API
          orders.each do |order|
            order = CDON::V1::Order.new shop, order

            formatted_order = order.format

            # 3a. Send base order information
            begin
              core_api.create_order shop_id, formatted_order
            rescue Arctic::Vendor::API::InvalidResponse
              core_api.update_order shop_id, formatted_order
            end

            # 3b. Send all invoices related to the order
            formatted_order.fetch(:invoices, []).each do |invoice|
              core_api.collect_invoice shop_id, formatted_order.fetch(:id), invoice
            end

            # 3c. Send all invoices related to the order
            formatted_order.fetch(:order_lines, []).each do |line|
              core_api.collect_order_line shop_id, formatted_order.fetch(:id), line
            end
          end

          # 4. Once synced report completion
          core_api.synced shop['id'], :orders

          Arctic.logger.info "Completed order synchronization for Shop(#{shop_id})"
        end
      end
    end
  end
end

# rubocop:enable Metrics/BlockLength
