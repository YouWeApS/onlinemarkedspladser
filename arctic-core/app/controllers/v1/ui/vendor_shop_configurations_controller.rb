# frozen_string_literal: true

class V1::Ui::VendorShopConfigurationsController < V1::Ui::ApplicationController #:nodoc:
  def show
    doorkeeper_authorize! 'product:read'

    render_config if stale? config
  end

  def update
    doorkeeper_authorize! :'product:write'
    update_config
    force_import
    # clear_product_caches
    render_config
  end

  private

    # def clear_product_caches
    #   prod_ids = shop.products.pluck :sku
    #   ProductCache.clear config.vendor.shadow_products.where(product_id: prod_ids)
    # end

    def update_config
      config.update config_params
    end

    def render_config
      json = V1::Ui::VendorBlueprint.render config.vendor, shop: config.shop
      render json: json
    end

    def config_params
      params.permit \
        :price_adjustment_type,
        :price_adjustment_value,
        :enabled,
        auth_config: {},
        config: {},
        currency_config: {},
        webhooks: {}
    end

    def config
      @config ||= shop
        .vendor_shop_configurations
        .where(vendor_id: params[:vendor_id])
        .take!
    end

    def shop
      current_user.shops.find params[:shop_id]
    end

    def force_import
      return unless params[:force_import]

      config.update \
        last_synced_at: nil,
        orders_last_synced_at: nil
    end
end
