# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength

class Amazon::Formatters::Order
  attr_reader :order_data, :order_lines_data, :shipping_mappings

  def initialize(order_data, order_lines_data = [], shipping_mappings)
    @order_data = order_data.as_json
    @order_lines_data = order_lines_data.as_json
    @shipping_mappings = shipping_mappings
    # p ['formatting order', order_data]
    # p ['order lines', order_lines_data]
  end

  # Returns a json hash thats suitible for use with the designated platform
  def for(platform)
    case platform.to_s
    when 'amazon' then for_amazon
    when 'core_api' then for_core
    end
  end

  private

    #
    # This converts from Amazon data structure to Arctic Core API order structure.
    #
    # Amazon Order data documentation here: https://amzn.to/2PN5CM0
    # Arctic Core API documentation here: http://bit.ly/2PPIJr2
    #
    def for_core
      {
        order_id: order_data.fetch('AmazonOrderId'),
        purchased_at: order_data.fetch('PurchaseDate'),
        status: order_data.fetch('OrderStatus'),
        currency: order_lines_data.dig(0, 'ItemPrice', 'CurrencyCode'),
        shipping_method_id: shipping_method_id,
        shipping_carrier_id: shipping_carrier_id,

        shipping_address: {
          email: order_data.dig('BuyerEmail'),
          name: order_data.dig('ShippingAddress', 'Name'),
          phone: order_data.dig('ShippingAddress', 'Phone'),
          address1: (
            order_data.dig('ShippingAddress', 'AddressLine1') ||
            order_data.dig('ShippingAddress', 'AddressLine2')
          ),
          city: order_data.dig('ShippingAddress', 'City'),
          zip: order_data.dig('ShippingAddress', 'PostalCode'),
          country: order_data.dig('ShippingAddress', 'CountryCode'),
        },

        # Because Amazon doesn't expose the billing address, we use the same
        # information as for the shipping address.
        billing_address: {
          email: order_data.dig('BuyerEmail'),
          name: order_data.dig('ShippingAddress', 'Name'),
          phone: order_data.dig('ShippingAddress', 'Phone'),
          address1: (
            order_data.dig('ShippingAddress', 'AddressLine1') ||
            order_data.dig('ShippingAddress', 'AddressLine2')
          ),
          city: order_data.dig('ShippingAddress', 'City'),
          zip: order_data.dig('ShippingAddress', 'PostalCode'),
          country: order_data.dig('ShippingAddress', 'CountryCode'),
        },

        order_lines_attributes: order_lines_data.collect do |ol|
          {
            product_id: ol.fetch('SellerSKU'),
            quantity: ol.fetch('QuantityOrdered'),
            cents_with_vat: (ol.dig('ItemPrice', 'Amount').to_f * 100.0).round(2).to_s,
          }
        end,

        raw_data: order_data,
      }
    end

    def shipping_mapping
      Amazon::ShippingMapping.new(@shipping_mappings, 
                                  order_data.dig('ShipmentServiceLevelCategory'),
                                  order_data.dig('FulfillmentChannel'))
    end

    def shipping_method_id
      shipping_mapping.method_id_for_service_level
    end

    def shipping_carrier_id
      shipping_mapping.carrier_id_for_service_level
    end
end

# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength
