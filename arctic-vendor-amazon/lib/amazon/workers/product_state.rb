# frozen_string_literal: true

class Amazon::Workers::ProductState < Amazon::Workers::Base
  def perform(shop_id, sku, state)
    core_api.update_product_state shop_id, sku, state
  end
end
