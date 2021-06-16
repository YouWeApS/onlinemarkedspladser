require 'forwardable'

class Dandomain::V2::Order
  extend Forwardable

  Error = Class.new StandardError

  attr_reader :shop, :data, :api, :customer, :raw_data, :shipping_mappings

  def initialize(shop, customer, data, shipping_mappings)
    @shipping_mappings = shipping_mappings
    @shop = Hashie::Mash.new shop.as_json
    @api = Dandomain::V2::API.new @shop
    @customer = customer
    @raw_data = data.as_json
    @data = format_data data.as_json
    lookup_order_information
  end

  def save
    if raw_data['receipt_id'].present?
      response = api.update_order data
    else
      response = api.create_order data
      api.complete_order response['id']
      data['id'] = raw_data['receipt_id'] = response['id']
      api.update_order_state data
    end

    data['id'] = raw_data['receipt_id'] = response['id']

    update_billing_address
    update_delivery_address
    update_reference_id
  end

  def uuid
    raw_data.fetch 'id', nil
  end

  def id
    data.fetch('id', nil)
  end

  private

    def update_reference_id
      core_api.update_order shop.fetch('id'), {
        id: uuid,
        receipt_id: id,
        track_and_trace_reference: data['trackNumber'],
      }
    end

    def update_billing_address
      api.update_order_billing_address id, format_address(raw_data['billing_address'])
    rescue Dandomain::V2::API::InvalidResponse => e
      Arctic.logger.warn "Unable to update billing address for Order(#{id} / #{uuid}): #{e.message}"
    end

    def update_delivery_address
      api.update_order_delivery_address id, format_address(raw_data['shipping_address'])
    rescue Dandomain::V2::API::InvalidResponse => e
      Arctic.logger.warn "Unable to update delivery address for Order(#{id} / #{uuid}): #{e.message}"
    end

    def format_address(address)
      {
        name: address.dig('name'),
        address: address.dig('address1'),
        address2: address.dig('address2'),
        zipCode: address.dig('zip').to_s.gsub(/\s+/, "").strip,
        city: address.dig('city'),
        country: api.lookup_country_attribute(address.dig('country'), shipping_method_id, :name),
        phone: address.dig('phone'),
        email: address.dig('email'),
      }
    end

    def lookup_order_information
      data.merge! api.lookup_order id if id
    end

    def format_data(json)
      {
        id: json['receipt_id'],
        customerId: customer.id,
        paymentMethodId: payment_method_id,
        shippingMethodId: shipping_method_id,
        orderStateId: new_order_state_id,
        currencyCode: json['currency_conversion'] || json['currency'],
        referenceNumber: json['order_id'],
        deliveryInfo: format_address(raw_data['shipping_address']),
        siteID: site_id,
        orderlines: order_lines,
      }.as_json
    end

    def order_lines
      @order_lines ||= raw_data.fetch('order_lines', []).collect do |ol|
        {
          productNumber: extract_product_id(ol.fetch('product_id')),
          quantity: ol.fetch('quantity'),
        }
      end
    end

    # This looks up the product first directly by the product_id, then using
    # the product_id as the EAN.
    def extract_product_id(order_line_product_id)
      api.lookup_product(order_line_product_id)['number']
    end

    def site_id
      @site_id ||= config.fetch 'site_id'
    end

    def vat
      @vat ||= config.fetch 'vat'
    end

    def config
      @config ||= shop.fetch 'config'
    end

    def payment_method_id
      @payment_method_id ||= config.dig('payment_id')
    end

    def shipping_mapping
      Dandomain::V2::ShippingMapping.new(shipping_mappings, 
                      raw_data.dig('shipping_method', 'id'),
                      raw_data.dig('shipping_carrier', 'id'),
                      config.dig('shipment_id'))
    end

    def shipping_method_id
      shipping_mapping.mapped_shipping_method_id
    end

    def new_order_state_id
      @new_order_state_id ||= config.dig('new_order_state_id')
    end

    def core_api
      @core_api ||= Arctic::Vendor::Collection::API.new
    end

    def api
      @api ||= Dandomain::V2::API.new shop
    end
end
