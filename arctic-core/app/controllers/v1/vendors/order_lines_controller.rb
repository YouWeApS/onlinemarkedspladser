# frozen_string_literal: true

class V1::Vendors::OrderLinesController < V1::Vendors::ApplicationController
  def create
    order_line = order.order_lines.find_or_initialize_by line_id: line_params[:line_id]
    return if line_params[:status] == 'returned'
    order_line.attributes = line_params
    order_line.product_id = create_mock_product.id
    order_line.save!
    head :created
  end

  def update
    order_line.attributes = line_params
    order_line.save!
    render json: V1::Vendors::OrderLineBlueprint.render(order_line)
  end

  def statuses
    render json: OrderLine::STATUSES.keys
  end

  private

    def order_line
      @order_line ||= order.order_lines.find params[:id]
    end

    def order
      @order ||= shop.orders.with_deleted.find params[:order_id]
    rescue ActiveRecord::RecordNotFound
      shop.orders.with_deleted.find_by order_id: params[:order_id]
    end

    def shop
      @shop ||= current_vendor.shops.find params[:shop_id]
    end

    def create_mock_product
      prod = Product.unscoped.where(sku: params[:product_id]).take
      prod ||= Product.create! \
        sku: params[:product_id],
        name: "Mock product for #{params[:product_id]}",
        shop: order.shop,
        deleted_at: 1.second.ago
      prod
    end

    def line_params
      params.permit \
        :line_id,
        :status,
        :quantity,
        :track_and_trace_reference,
        :cents_without_vat,
        :cents_with_vat
    end
end
