class Economic::V1::Customer
  attr_reader :shop, :order, :customer

  def initialize(shop:, order:)
    @shop  = shop
    @order = order
  end

  def find_or_create!
    find || create
  end

  private

  def find
    api.find_customer(email: email)
  end

  def create
    api.create_customer(customer_data)
  end

  def email
    @email ||= order.dig('billing_address', 'email')
  end

  def name
    @name ||= order['amazon_fba'] ? order_id : order.dig('billing_address', 'name')
  end

  def order_id
    @order_id ||= "Amazon: #{order.fetch('order_id')}"
  end

  def config
    @config ||= shop.fetch 'config'
  end

  def customer_data
    {
      name: name,
      email: email,
      currency: config['currency'],
      customerGroup: {
        customerGroupNumber: config['customerGroupNumber'].to_i
      },
      paymentTerms: {
        paymentTermsNumber: config['paymentTermsNumber'].to_i
      },
      vatZone: {
        vatZoneNumber: config['vatZoneNumber'].to_i
      }
    }
  end

  def api
    @api ||= Economic::V1::API.new shop
  end
end
