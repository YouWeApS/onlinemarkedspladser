# frozen_string_literal: true

class Amazon::Workers::Products < Amazon::Workers::Base
  FEED_TYPE = '_POST_PRODUCT_DATA_'
  ENVELOPE_CLASS = 'Products'

  private

    def log_msg
      "Product feed: Shop(#{shop_id})/Marketplace(#{marketplace})"
    end

    def submit_next
      Amazon::Workers::Inventory.perform_async shop_id, options
    end
end
