# frozen_string_literal: true

class V1::Ui::OrdersController < V1::Ui::ApplicationController #:nodoc:
  def index
    doorkeeper_authorize! 'order:read'

    json = Rails.cache.fetch [current_shop, current_vendor, orders] do
      V1::Ui::OrderBlueprint.render orders
    end

    render json: json if http_cache(orders)
  end

  def statuses
    doorkeeper_authorize! 'order:read'

    render json: OrderLine::STATUSES.keys
  end

  def show
    doorkeeper_authorize! 'order:read'
    return unless stale? etag: order, last_modified: order.updated_at

    json = Rails.cache.fetch order do
      V1::Ui::OrderBlueprint.render order,
        view: :order_lines,
        vendor: order.vendor
    end

    render json: json
  end

  private

    def order
      @order ||= orders.find params[:id]
    end

    def orders
      @orders ||= begin
        ox = Order
          .where(shop: current_shop)
          .order('orders.updated_at desc') # newest first

        per_page = filter_params[:per_page] || 20

        paginate apply_filters(ox), per_page: per_page
      end
    end

    def filter_params
      params.permit :state, :start_date, :end_date, :search, :per_page
    end

    def apply_filters(collection)
      filter_params.to_h.each do |k, v|
        case k.to_s
        when 'state' then collection = apply_state collection, v
        when 'search' then collection = collection.search v
        when 'start_date' then collection = collection.after v
        when 'end_date' then collection = collection.before v
        end
      end

      collection
    end

    def apply_state(collection, status)
      return collection if status == 'all'
      status = (OrderLine::STATUSES.keys & [status]).first
      collection.joins(:order_lines).where(order_lines: { status: status }).distinct if status.present?
    end

    def http_cache(orders)
      stale? etag: orders, last_modified: orders.maximum(:updated_at)
    end
end
