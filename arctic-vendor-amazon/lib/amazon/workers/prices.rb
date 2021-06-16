# frozen_string_literal: true

class Amazon::Workers::Prices < Amazon::Workers::Base
  FEED_TYPE = '_POST_PRODUCT_PRICING_DATA_'
  ENVELOPE_CLASS = 'Prices'

  private

    def log_msg
      "Prices feed: Shop(#{shop_id})/Marketplace(#{marketplace})"
    end

    def submit_next
      Amazon::Workers::Relationships.perform_async shop_id, options
    end
end
