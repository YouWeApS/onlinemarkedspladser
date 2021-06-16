# frozen_string_literal: true

class V1::Ui::ImagesController < V1::Ui::ApplicationController # :nodoc:
  def update
    doorkeeper_authorize! 'product:write'

    change_position

    shadow_product.save

    V1::Vendors::ChannelProductMatchWorker.perform_async \
      shadow_product.product.shop_id,
      shadow_product.product_id

    render json: V1::Vendors::ProductImageBlueprint.render(image)
  end

  private

    def image
      @image ||= current_user
        .shops
        .find(params[:shop_id])
        .products
        .find(product_id)
        .images
        .find(params[:id])
    end

    def product_id
      @product_id ||= shadow_product.product_id
    end

    def shadow_product
      @shadow_product ||= current_vendor.shadow_products.find params[:product_id]
    end

    def change_position
      position = params[:position].to_s.strip.to_i
      image.insert_at position if position.positive?
    end
end
