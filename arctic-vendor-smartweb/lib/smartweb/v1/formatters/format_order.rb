# frozen_string_literal: true

class Smartweb::V1::Formatters::FormatOrder
  attr_reader :order, :shop_id

  def initialize(order, shop_id)
    @order   = order
    @shop_id = shop_id
  end

  def format
    {
      'CurrencyId' => get_currency_id,
      'DeliveryId' => set_delivery_id,
      'ReferenceNumber' => order['order_id'],
      'OrderCustomer' => customer,
      'Origin' => 'Example',
      'LanguageISO' => config.fetch('locale'),
      'OrderLines' => {'item' => get_order_lines},
      'PaymentId' => config.fetch('payment_id'),
      'Vat' => "0.#{vat_amount}".to_f,
    }.tap do |order_hash|
      if vendor_shop_configuration['export_orders_shipping_price'] && delivery_price.present?
        order_hash.merge!('DeliveryPrice' => delivery_price)
      end
    end
  end

  def customer
    {
      'Address' => order.dig('billing_address', 'address1'),
      'Address2' => order.dig('billing_address', 'address2'),
      'Country' => config.fetch('customer_country_code'),
      'City' => order.dig('billing_address', 'city'),
      'State' => order.dig('billing_address', 'region'),
      'Zip' => order.dig('billing_address', 'zip'),
      'Email'=> order.dig('billing_address', 'email'),
      'Firstname' => billing_address_first_name,
      'Lastname' => billing_address_last_name,
      'Mobile' => order.dig('billing_address', 'phone'),
      'Phone' => customer_phone,
      'ShippingAddress' => order.dig('shipping_address', 'address1'),
      'ShippingAddress2' => order.dig('shipping_address', 'address2'),
      'ShippingCountry' => order.dig('shipping_address', 'country'),
      'ShippingCity' => order.dig('shipping_address', 'city'),
      'ShippingEmail' => order.dig('shipping_address', 'email'),
      'ShippingFirstname' => shipping_address_first_name,
      'ShippingLastname' => shipping_address_last_name,
      'ShippingMobile' => order.dig('shipping_address', 'phone'),
      'ShippingPhone' => order.dig('shipping_address', 'phone'),
      'ShippingState' => order.dig('shipping_address', 'region'),
      'ShippingZip' => order.dig('shipping_address', 'zip')
    }.tap do |customer_hash|
      customer_hash.merge!('CountryCode' => billing_address_country_code) if billing_address_country_code.present?
      customer_hash.merge!('ShippingCountryCode' => shipping_address_country_code) \
        if shipping_address_country_code.present?
    end
  end

  def order_lines
    order['order_lines'].map do |order_line|
      product = order_line_product(order_line)

      raise "Product (#{order_line['product_id']}) not found on SmartWeb" unless product.present?
      if product[:stock].to_i <= 0 && product[:disable_on_empty] == false
        # disable_on_empty == false means that product is not active when sold out
        raise "Product (#{order_line['product_id']}) is out of stock"
      end

      {
        'Amount' => order_line['quantity'],
        'Price'  => order_line_buy_price(order_line),
        'Weight' => product[:weight]
      }.tap do |formatted_order_line|
        if product[:product_id].present? # means that this product is variant
          formatted_order_line.merge! 'ProductId' => product[:product_id], 'VariantId' => product[:id]
        else
          formatted_order_line.merge! 'ProductId' => product[:id]
        end
      end
    end
  end

  def order_line_buy_price(order_line)
    price = order_line.fetch('cents_with_vat') / 100.0

    unit_price = price / order_line.fetch('quantity')

    # calculate price without vat
    (unit_price / "1.#{vat_amount}".to_f).round(2)
  end

  def order_line_product(order_line)
    core_product = order_line['product']

    if core_product['master'].present?
      smartweb_product = api.get_product(core_product.dig('master', 'sku'))

      variants = [smartweb_product.dig(:variants, :item)].flatten(1).compact

      variants.find { |variant| variant[:item_number] == core_product['sku'] }
    else
      api.get_product(core_product['sku'])
    end
  end

  def get_order_lines
    @order_lines ||= order_lines
  end

  def get_currency_id
    currency = config.fetch('currency')
    currency_obj = api.get_currency(currency)
    currency_obj.fetch(:id)
  end

  def set_delivery_id
    weight_bound.present? ? delivery_id_based_on_weight : config.fetch('delivery_id_1')
  end

  def customer_phone
    @customer_phone ||= \
      order['amazon_fba'] ? order.fetch('order_id') : order.dig('billing_address', 'phone')
  end

  def delivery_id_based_on_weight
    order_lines = get_order_lines

    order_total_weight = \
      if order_lines.any?
        total_weight = 0
        order_lines.each do |order_line|
          amount = order_line['Amount']
          weight = order_line['Weight']
          total_weight += (amount.to_i * weight.to_f)
        end

        total_weight
      else
        0
      end

    order_total_weight >= weight_bound.to_f ? config.fetch('delivery_id_2') : config.fetch('delivery_id_1')
  end

  def delivery_price
    cents_with_vat = order['order_lines'].collect { |order_line| order_line['shipping_cents_with_vat'] }
                                         .compact
                                         .inject(:+)

    return unless cents_with_vat.present?

    # calculate price without vat
    ((cents_with_vat / 100.0) / "1.#{vat_amount}".to_f).round(2)
  end

  def vat_amount
    @vat_amount ||= config.fetch('vat')
  end

  def billing_address_country_code
    @billing_address_country_code ||= order.dig('billing_address', 'country_code')
  end

  def shipping_address_country_code
    @shipping_address_country_code ||= order.dig('shipping_address', 'country_code')
  end

  private

  def weight_bound
    @weight_bound ||= config.fetch('weight_bound')
  end

  def billing_address_first_name
    @billing_address_first_name ||= \
      if order['amazon_fba']
        'Amazon FBA customer'
      else
        order.dig('billing_address', 'name') ? order.dig('billing_address', 'name').split(' ')[0] : ''
      end
  end

  def billing_address_last_name
    @billing_address_last_name ||= \
      if order['amazon_fba']
        ''
      else
        order.dig('billing_address', 'name') ? order.dig('billing_address', 'name').split(' ')[1] : ''
      end
  end

  def shipping_address_first_name
    @shipping_address_first_name ||= \
      if order['amazon_fba']
        'Amazon FBA customer'
      else
        order.dig('shipping_address', 'name') ? order.dig('shipping_address', 'name').split(' ')[0] : ''
      end
  end

  def shipping_address_last_name
    @shipping_address_last_name ||= \
      if order['amazon_fba']
        ''
      else
        order.dig('shipping_address', 'name') ? order.dig('shipping_address', 'name').split(' ')[1] : ''
      end
  end

  def core
    @core ||= Arctic::Vendor::Collection::API.new
  end

  def shop
    @shop ||= core.get_shop shop_id
  end

  def config
    return @config if defined? @config

    general_config = vendor_shop_configuration.fetch('config')

    @config = \
      if order['amazon_fba']
        general_config.merge! amazon_fba_orders_setting
      else
        general_config
      end
  end

  def amazon_fba_orders_setting
    @amazon_fba_orders_setting ||= \
      vendor_shop_configuration.fetch('amazon_fba_orders_config').delete_if { |_k, v| v.blank? && v != false }
  end

  def vendor_shop_configuration
    @vendor_shop_configuration ||= core.get_vendor_shop_configuration shop_id
  end

  def api
    @api ||= Smartweb::V1::API.new(shop)
  end
end
