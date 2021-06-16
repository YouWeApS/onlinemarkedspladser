# frozen_string_literal: true

class V1::Vendors::OrderLineBlueprint < Blueprinter::Base #:nodoc:
  identifier :id

  field :product_id do |order_line|
    product = order_line.product
    if product
      original_sku = order_line.product.original_sku
      original_sku.present? ? original_sku : order_line.product.sku
    end
  end

  fields \
    :status,
    :line_id,
    :quantity,
    :track_and_trace_reference,
    :cents_with_vat,
    :cents_without_vat
end
