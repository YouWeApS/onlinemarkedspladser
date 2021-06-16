# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Style/RescueStandardError
# rubocop:disable Style/RedundantBegin

class V1::Vendors::OrdersController < V1::Vendors::ApplicationController
  def last_synced_at
    shop = current_vendor.shops.find params[:shop_id]
    config = shop.vendor_config_for current_vendor
    render json: V1::Vendors::LastSyncedAtBlueprint.render(config, view: :orders)
  end

  def show
    order = orders.where('id::text = :id::text or order_id = :id', id: params[:id]).take

    if order
      render json: V1::Vendors::OrderBlueprint.render(order)
    else
      head :not_found
    end
  end

  def update
    internal_error = nil

    Order.transaction do
      update_order
      render json: V1::Vendors::OrderBlueprint.render(order)
      return
    rescue ActiveRecord::ActiveRecordError => e
      internal_error = e
      raise ActiveRecord::Rollback
    end

    raise internal_error
  end

  def create
    @order = vendor_orders.new order_params

    nested_error = nil

    Order.transaction do
      begin
        create_order

        render \
          json: V1::Vendors::OrderBlueprint.render(order),
          status: :created

        return
      rescue => e
        logger.error e
        nested_error = e
        raise ActiveRecord::Rollback
      end
    end

    raise HttpError::BadRequest, nested_error.message if nested_error

    raise HttpError::InternalServerError
  end

  def index
    render json: V1::Vendors::OrderBlueprint.render(orders)
  end

  def lock
    VendorLock.create! vendor: current_vendor, target: order
    head :created
  end

  def unlock
    order.vendor_locks.find_by(vendor: current_vendor).really_destroy!
    head :ok
  end

  private

    def update_order
      order.attributes = update_order_params
      order.save!
      Rails.cache.delete order
      update_all_order_lines
    end

    def update_all_order_lines
      return if params[:track_and_trace_reference].blank?

      # update_all does not trigger Active Record callbacks or validations.
      order.order_lines.find_each do |m|
        m.update_attributes(track_and_trace_reference: params[:track_and_trace_reference])
      end
    end

    def create_order
      set_billing_address
      set_shipping_address

      order.save!

      add_raw_data
    end

    def add_raw_data
      return unless params[:raw_data]

      order.raw_data.create! data: params[:raw_data].permit!
    end

    def set_billing_address
      billing_address = Address.find_or_initialize_by address_params(:billing)
      billing_address.save!
      order.billing_address = billing_address
    end

    def set_shipping_address
      params[:shipping_address] ||= params[:billing_address]
      shipping_address = Address.find_or_initialize_by address_params(:shipping)
      shipping_address.save!
      order.shipping_address = shipping_address
    end

    def order
      @order ||= begin
        order_id = params[:order_id]
        id = params[:id] || params[:order_id]
        orders.where('order_id = ? or id::text = ?', order_id, id).take!
      end
    end

    def shop
      @shop ||= current_vendor.dispersal_shops.find_by(id: params[:shop_id]) ||
                current_vendor.collection_shops.find_by(id: params[:shop_id])
    end

    def order_params
      params.permit \
        :order_id,
        :payment_reference,
        :puchased_at,
        :receipt_id,
        :vat,
        :currency,
        :shipping_fee,
        :payment_fee,
        :shipping_carrier_id,
        :shipping_method_id,
        order_lines_attributes: %i[line_id quantity product_id cents_with_vat cents_without_vat]
    end

    def update_order_params
      params.permit \
        :payment_reference,
        :puchased_at,
        :receipt_id,
        :vat,
        :currency,
        :shipping_fee,
        :payment_fee
    end

    def orders
      sx = shop.orders.unlocked(current_vendor)
      sx = sx.where('updated_at > ?', since) if since
      sx.order updated_at: :desc
    end

    def since
      Time.parse params[:since]
    rescue
      nil
    end

    def vendor_orders
      orders.where(vendor: current_vendor)
    end

    def address_params(type)
      params.require("#{type}_address").permit \
        :name,
        :address1,
        :address2,
        :zip,
        :city,
        :country,
        :phone,
        :email
    end
end

# rubocop:enable Style/RescueStandardError
# rubocop:enable Metrics/ClassLength
# rubocop:enable Style/RedundantBegin
