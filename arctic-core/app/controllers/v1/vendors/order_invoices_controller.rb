# frozen_string_literal: true

class V1::Vendors::OrderInvoicesController < V1::Vendors::ApplicationController
  def create
    invoice = order.invoices.find_or_initialize_by invoice_id: invoice_params[:invoice_id]
    invoice.attributes = invoice_params
    invoice.save!
    head :created
  end

  private

    def order
      @order ||= shop
        .orders
        .where('id::text = :id or order_id = :id', id: params[:order_id])
        .take!
    end

    def shop
      @shop ||= current_vendor.shops.find params[:shop_id]
    end

    def invoice_params
      params.permit \
        :invoice_id,
        :amount,
        :currency,
        :status,
        order_lines: []
    end
end
