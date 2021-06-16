# frozen_string_literal: true

class Dandomain::V2::ShippingMapping
  Error = Class.new StandardError
  NonShipOrder = Class.new Error

  attr_reader :shipping_mappings,
              :shipping_method_id,
              :shipping_carrier_id,
              :config_shipping_id

  UNKNOWN = 'Unknown'
  NON_SHIP = 'None_assigned'

  def initialize(shipping_mappings,
                 shipping_method_id,
                 shipping_carrier_id,
                 config_shipping_id)
    @shipping_mappings = shipping_mappings
    @shipping_method_id = shipping_method_id
    @shipping_carrier_id = shipping_carrier_id
    @config_shipping_id = config_shipping_id
  end

  def mapped_shipping_method_id
    # In case there is config_shipping_id defined
    # we use this to be backwards compatible
    # this can be refactored at some point
    # when we have migrated to using new mapping system
    return config_shipping_id if config_shipping_id

    mapping = shipping_mappings.detect { |m| m.dig('shipping_method_id').eql?(shipping_method_id) && m.dig('shipping_carrier_id').eql?(shipping_carrier_id) }
    if mapping && mapping.dig('shipping_method_name').eql?(NON_SHIP)
      # In case this is a non ship order
      # in case mapping exists we use it
      # otherwise we ignore
      raise NonShipOrder, 'Should not be shipped'
    elsif mapping
      mapping.dig('vendor_method')
    else
      unknown_shipping_method_id
    end
  end

  private

    def unknown_shipping_method_id
      shipping_mappings.detect { |m| m.dig('shipping_method_name').eql?(UNKNOWN) }.dig('vendor_method')
    end

    def non_ship_shipping_method_id
      shipping_mappings.detect { |m| m.dig('shipping_method_name').eql?(NON_SHIP) }.dig('vendor_method')
    end
end
