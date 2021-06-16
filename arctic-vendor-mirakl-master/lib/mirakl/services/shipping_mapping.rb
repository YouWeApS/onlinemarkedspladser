# frozen_string_literal: true

class Mirakl::Services::ShippingMapping
  attr_reader :shipping_mappings, :order

  UNKNOWN = 'unknown'

  def initialize(shipping_mappings, order)
    @shipping_mappings = shipping_mappings
    @order             = order
  end

  def method_id
    if shipping_mapping.nil? || shipping_mapping['shipping_method_id'].blank?
      unknown_shipping_method_id
    else
      shipping_mapping['shipping_method_id']
    end
  end

  def carrier_id
    if shipping_mapping.nil? || shipping_mapping['shipping_carrier_id'].blank?
      unknown_shipping_carrier_id
    else
      shipping_mapping['shipping_carrier_id']
    end
  end

  private

  def shipping_mapping
    @shipping_mapping ||= shipping_mappings.find do |mapping|
      mapping['vendor_method'] == shipping_method && mapping['vendor_carrier'] == shipping_carrier
    end
  end

  def shipping_method
    @shipping_method ||= order['shipping_type_label'].presence
  end

  def shipping_carrier
    @shipping_carrier ||= order['shipping_company'].presence
  end

  def unknown_shipping_mapping
    @unknown_shipping_mapping ||= shipping_mappings.find do |mapping|
      mapping['vendor_method'].eql?(UNKNOWN) && mapping['vendor_carrier'].eql?(UNKNOWN)
    end
  end

  def unknown_shipping_method_id
    return nil unless unknown_shipping_mapping.present?

    unknown_shipping_mapping['shipping_method_id']
  end

  def unknown_shipping_carrier_id
    return nil unless unknown_shipping_mapping.present?

    unknown_shipping_mapping['shipping_carrier_id']
  end
end
