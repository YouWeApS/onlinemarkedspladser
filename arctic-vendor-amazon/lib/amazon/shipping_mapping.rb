# frozen_string_literal: true

class Amazon::ShippingMapping
  attr_reader :shipping_mappings, :shipment_service_level, :fulfillment_channel
  UNKNOWN = 'unknown'
  NON_SHIP = 'non_ship'
  FULFILLMENT_BY_AMAZON = 'afn'
  FULFILLMENT_BY_SELLER = 'mfn'

  def initialize(shipping_mappings, shipment_service_level, fulfillment_channel)
    @shipping_mappings = shipping_mappings
    @shipment_service_level = normalized_shipment_service_level(shipment_service_level)
    @fulfillment_channel = fulfillment_channel.downcase
  end

  # Amazon does not have a normalized value for "Standard"
  # therefore we need to look up some different possibilites
  # this could for instance be: Std ES Dom_3
  def normalized_shipment_service_level(shipment_service_level)
    if shipment_service_level.downcase[0..2] == 'std'
      'standard'
    else
      shipment_service_level.downcase
    end
  end

  def method_id_for_service_level
    return fba_shipping_method_id if fulfillment_by_amazon?

    mapping = @shipping_mappings.detect { |m| m.dig('vendor_method').downcase.include?(@shipment_service_level) }
    mapping.fetch('shipping_method_id') { unknown_shipping_method_id }
  end

  # Amazon only uses method and not carrier
  # so we use the 'vendor_method' as key for carrier also
  def carrier_id_for_service_level
    return fba_shipping_carrier_id if fulfillment_by_amazon?

    mapping = @shipping_mappings.detect { |m| m.dig('vendor_method').downcase.include?(@shipment_service_level) }
    mapping.fetch('shipping_carrier_id') { unknown_shipping_carrier_id }
  end

  def fulfillment_by_amazon?
    @fulfillment_channel == FULFILLMENT_BY_AMAZON
  end

  def unknown_shipping_method_id
    shipping_mappings.detect { |m| m.dig('vendor_carrier').eql?(UNKNOWN) }.dig('shipping_method_id')
  end

  def unknown_shipping_carrier_id
    shipping_mappings.detect { |m| m.dig('vendor_carrier').eql?(UNKNOWN) }.dig('shipping_carrier_id')
  end

  def fba_shipping_method_id
    shipping_mappings.detect { |m| m.dig('vendor_method').eql?(NON_SHIP) }.dig('shipping_method_id')
  end

  def fba_shipping_carrier_id
    shipping_mappings.detect { |m| m.dig('vendor_carrier').eql?(NON_SHIP) }.dig('shipping_carrier_id')
  end
end
