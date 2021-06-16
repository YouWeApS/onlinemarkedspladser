# frozen_string_literal: true

class V1::Ui::ErrorsController < V1::Ui::ApplicationController #:nodoc:
  def destroy_all
    doorkeeper_authorize! 'product:write'
    errors.map(&:really_destroy!)
    reload_and_render
  end

  def destroy
    doorkeeper_authorize! 'product:write'
    error.really_destroy!
    reload_and_render
  end

  private

    def reload_and_render
      set_product_pending

      shadow_product.reload

      json = ProductCache.write shadow_product

      ProductBroadcast.new(shadow_product).broadcast

      render json: json
    end

    def shadow_product
      current_vendor
        .shadow_products
        .where(product: current_shop.products)
        .find params[:product_id]
    end

    def errors
      @errors ||= shadow_product.product_errors
    end

    def error
      @error ||= errors.find params[:id]
    end

    def set_product_pending
      config = current_shop.vendor_config_for current_vendor

      shadow_product
        .product
        .dispersals
        .where(vendor_shop_configuration: config)
        .update(state: :pending)
    end
end
