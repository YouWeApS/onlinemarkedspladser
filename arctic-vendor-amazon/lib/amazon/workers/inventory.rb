# frozen_string_literal: true

class Amazon::Workers::Inventory < Amazon::Workers::Base
  FEED_TYPE = '_POST_INVENTORY_AVAILABILITY_DATA_'
  ENVELOPE_CLASS = 'Inventory'

  private

    def log_msg
      "Inventory feed: Shop(#{shop_id})/Marketplace(#{marketplace})"
    end

    def submit_next
      Amazon::Workers::Prices.perform_async shop_id, options
    end

    # Override products to allow including products with errors
    def products
      @products ||= core_api.list_products shop_id, all: options[:ignore_errors]
    end
end
