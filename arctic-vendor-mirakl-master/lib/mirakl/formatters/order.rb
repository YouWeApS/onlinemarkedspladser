# frozen_string_literal: true

class Miinto::V1::Formatters::Order
  attr_reader :order, :existing_order_data, :shipping_mappings

  def initialize(order, existing_order_data, shipping_mappings)
    @order               = order
    @existing_order_data = existing_order_data
    @shipping_mappings   = shipping_mappings
  end

  def format
    {
      order_id: order['order_id'],
      purchased_at: order['created_date'],
      currency: order['currency_iso_code'],
      shipping_method_id: shipping_mapping.method_id,
      shipping_carrier_id: shipping_mapping.carrier_id,
      shipping_address: {
        email: nil,
        name: customer_name(order.dig('customer', 'shipping_address')),
        phone: nil,
        address1: order.dig('customer', 'shipping_address', 'street_1'),
        address2: order.dig('customer', 'shipping_address', 'street_2'),
        city: order.dig('customer', 'shipping_address', 'city'),
        zip: order.dig('customer', 'shipping_address', 'zip_code'),
        country: order.dig('customer', 'shipping_address', 'country_iso_code')
      },
      billing_address: {
        email: nil,
        name: customer_name(order.dig('customer', 'billing_address')),
        phone: nil,
        address1: order.dig('customer', 'billing_address', 'street_1'),
        address2: order.dig('customer', 'billing_address', 'street_2'),
        city: order.dig('customer', 'billing_address', 'city'),
        zip: order.dig('customer', 'billing_address', 'zip_code'),
        country: order.dig('customer', 'billing_address', 'country_iso_code')
      },
      order_lines_attributes: order['order_lines'].map do |order_line|
        {
          line_id: order_line['order_line_id'],
          product_sku: order_line['product_sku'],
          quantity: order_line['quantity'],
          cents_with_vat: order_line['price'],
          shipping_cents_with_vat: order_line['shipping_price']
        }.tap { |order_line_data| set_order_line_id(order_line_data) }
      end,
      raw_data: order
    }
  end

  private

  def shipping_mapping
    @shipping_mapping ||= Mirakl::Services::ShippingMapping.new shipping_mappings, order
  end

  def customer_name(address)
    address['firstname'] + ' ' + address['lastname']
  end

  def set_order_line_id(order_line_data)
    return unless existing_order_data.present?

    order_line_id = existing_order_data['order_lines']&.find do |order_line|
      order_line['line_id'] == order_line_data[:line_id]
    end&.fetch('id')

    return unless order_line_id.present?

    order_line_data.merge! id: order_line_id
  end
end
