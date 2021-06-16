# frozen_string_literal: true

class V1::UI::EnableShadowProductsWorker #:nodoc:
  include Sidekiq::Worker

  sidekiq_options \
    queue: :enable_shadow_products,
    backtrace: !Rails.env.production?,
    unique: :until_executed

  def perform(shadow_products_id, value)
    shadow_products = shadow_products_disabled(shadow_products_id)

    shadow_products.each do |shadow_product|
      shadow_product.update_attribute(:enabled, value)
    end
  end

  private

    def shadow_products_disabled(shadow_products_id)
      ShadowProduct
          .where('shadow_products.id::varchar in (:id) or master_id in (:id)', id: shadow_products_id)
    end
end
