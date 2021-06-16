# frozen_string_literal: true

class V1::Ui::OrderBlueprint < Blueprinter::Base #:nodoc:
  identifier :id

  fields :status, :order_id, :payment_reference

  field :shipping_fee do |o|
    Money.new(o.shipping_fee, o.currency).format
  end

  field :payment_fee do |o|
    Money.new(o.payment_fee, o.currency).format
  end

  field :order_receipt_id, name: :receipt_id

  field :purchased_at,
    datetime_format: DATE_FORMAT

  field :updated_at,
    datetime_format: DATE_FORMAT

  field :all_track_and_trace_references,
    name: :track_and_trace_reference

  association :shipping_carrier, blueprint: V1::Ui::ShippingCarrierBlueprint
  association :shipping_method, blueprint: V1::Ui::ShippingMethodBlueprint

  view :order_lines do
    association :order_lines, blueprint: V1::Ui::OrderLineBlueprint
    association :shipping_address, blueprint: V1::Ui::AddressBlueprint
    association :billing_address, blueprint: V1::Ui::AddressBlueprint

    fields :vat

    field :total do |order|
      order.total_with_vat.format
    end

    field :total_without_vat do |order|
      order.total_without_vat.format
    end
  end
end
