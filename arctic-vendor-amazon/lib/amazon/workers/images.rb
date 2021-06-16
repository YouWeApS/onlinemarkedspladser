# frozen_string_literal: true

class Amazon::Workers::Images < Amazon::Workers::Base
  FEED_TYPE = '_POST_PRODUCT_IMAGE_DATA_'
  ENVELOPE_CLASS = 'Images'

  private

    def log_msg
      "Images feed: Shop(#{shop_id})/Marketplace(#{marketplace})"
    end

    def completed
      update_states :completed
      core_api.synced shop_id, :products
    end
end
