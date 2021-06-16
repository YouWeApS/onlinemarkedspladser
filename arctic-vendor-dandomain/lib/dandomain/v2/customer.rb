require 'forwardable'

class Dandomain::V2::Customer
  extend Forwardable

  Error = Class.new StandardError

  attr_reader :shop, :order, :customer, :shipping_mappings

  def initialize(shop, order, shipping_mappings)
    @shop = shop
    @order = order
    @shipping_mappings = shipping_mappings
    lookup_customer
  end

  def save
    if id
      # If we update the customer through the DD V2 API it causes the customer
      # to become invalid.
      # This happens even if we PUT the information that we just got from DD
      # when GETting the customer object.
      # @customer = api.update_customer customer
    else
      @customer = api.create_customer customer
    end
  end

  def id
    @customer['id']
  end

  def email
    @email ||= order.dig('billing_address', 'email')
  end

  def country_valid?
    @customer[:addressInformation][:country][:id] != 0
  end

  private

    def config
      @config ||= shop.fetch 'config'
    end

    def shipping_mapping
      Dandomain::V2::ShippingMapping.new(shipping_mappings,
          order.dig('shipping_method', 'id'),
          order.dig('shipping_carrier', 'id'),
          config.dig('shipment_id'))
    end

    def shipping_method_id
      shipping_mapping.mapped_shipping_method_id
    end

    def lookup_customer
      customers, _ = api.lookup_customer(email: email)
      c = build_customer.merge! (customers.first || {})
      @customer = Hashie::Mash.new c
    end

    def build_customer
      {
        companyName: "",
        comments: "",
        cvr: "",
        ean: "",
        addressInformation: {
          address: order.dig('billing_address', 'address1').presence || "",
          name: order.dig('billing_address', 'name').presence || "",
          address2: order.dig('billing_address', 'address2').presence || "",
          city: order.dig('billing_address', 'city').presence || "",
          state: "",
          zipCode: order.dig('billing_address', 'zip').to_s.gsub(/\s+/, "").strip,
          country: {
            id: api.lookup_country_attribute(order.dig('billing_address', 'country'), shipping_method_id).to_s.to_i,
          },
        },
        reservedFields: {
          reservedField1: "",
          reservedField2: "",
          reservedField3: "",
          reservedField4: "",
          reservedField5: "",
        },
        customerTypeEnum: "PRIVATE",
        contactDetails: {
          phone: order.dig('billing_address', 'phone').presence || "",
          fax: "",
          email: email,
        },
      }
    end

    def api
      @api ||= Dandomain::V2::API.new shop
    end
end
