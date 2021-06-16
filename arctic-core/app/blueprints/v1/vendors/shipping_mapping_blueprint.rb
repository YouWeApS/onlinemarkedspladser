# frozen_string_literal: true

class V1::Vendors::ShippingMappingBlueprint < Blueprinter::Base #:nodoc:
  identifier :id
  fields :vendor_method, :vendor_carrier, :shipping_method_id, :shipping_carrier_id

  field :shipping_method_name do |mapping, *|
    mapping.shipping_method.name
  end

  field :shipping_carrier_name do |mapping, *|
    mapping.shipping_carrier.name
  end
end
