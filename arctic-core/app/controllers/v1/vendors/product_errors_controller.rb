# frozen_string_literal: true

class V1::Vendors::ProductErrorsController < V1::Vendors::ApplicationController #:nodoc:
  def create
    shadow_product.product_errors.find_or_create_by! error_params
    fail_dispersal if error_params[:severity] == 'error'

    ProductCache.write product

    render json: {}, status: 200
  end

  private

    def product
      @product ||= current_vendor
        .shops
        .find(params[:shop_id])
        .products
        .find(params[:product_id])
    end

    def shadow_product
      @shadow_product ||= product.shadow_product current_vendor
    end

    def error_params
      params.permit :message, :details, :severity, raw_data: {}
    end

    def fail_dispersal
      config = current_vendor.vendor_shop_configurations

      shadow_product
        .dispersals
        .where(vendor_shop_configuration: config)
        .with_state(:inprogress)
        .update_all state: :failed
    end
end
