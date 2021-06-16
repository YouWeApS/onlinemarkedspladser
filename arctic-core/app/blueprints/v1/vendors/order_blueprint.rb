# frozen_string_literal: true

class V1::Vendors::OrderBlueprint < Blueprinter::Base #:nodoc:
  identifier :id

  fields \
    :order_id,
    :status,
    :payment_reference,
    :vendor_id,
    :vat,
    :currency,
    :shipping_method,
    :shipping_carrier

  field :shipping_fee do |o|
    Money.new(o.shipping_fee, o.currency).to_s
  end

  field :payment_fee do |o|
    Money.new(o.payment_fee, o.currency).to_s
  end

  field :order_receipt_id, name: :receipt_id

  field :purchased_at, datetime_format: DATE_FORMAT

  field :total do |order|
    order.total_with_vat.to_s
  end

  field :total_without_vat do |order|
    order.total_without_vat.to_s
  end

  association :billing_address, blueprint: V1::Vendors::AddressBlueprint
  association :shipping_address, blueprint: V1::Vendors::AddressBlueprint
  association :order_lines, blueprint: V1::Vendors::OrderLineBlueprint
end
