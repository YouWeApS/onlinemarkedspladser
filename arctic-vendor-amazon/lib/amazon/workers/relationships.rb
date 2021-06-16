# frozen_string_literal: true

class Amazon::Workers::Relationships < Amazon::Workers::Base
  FEED_TYPE = '_POST_PRODUCT_RELATIONSHIP_DATA_'
  ENVELOPE_CLASS = 'Relationships'

  private

    def log_msg
      "Relationships feed: Shop(#{shop_id})/Marketplace(#{marketplace})"
    end

    def submit_next
      options["continue"] = false
      Amazon::Workers::Images.perform_async shop_id, options
    end
end
