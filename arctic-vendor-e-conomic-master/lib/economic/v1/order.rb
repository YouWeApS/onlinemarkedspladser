class Economic::V1::Order
  attr_reader :shop, :customer_number, :order

  def initialize(shop:, customer_number:, order:)
    @shop            = shop
    @customer_number = customer_number
    @order           = order
  end

  def save!
    if order['economic_order_id'].present?
      response = api.update_order order: order_data, order_id: order['economic_order_id']
    else
      response = api.create_order order_data
    end

    update_core(response['draftInvoiceNumber'])
  end

  private

  def update_core(economic_order_id)
    core_api.update_order shop.fetch('id'), id: order.fetch('id'), economic_order_id: economic_order_id
  end

  def order_data
    {
      date: date,
      currency: order.fetch('currency'),
      paymentTerms: {
        paymentTermsNumber: config.fetch('paymentTermsNumber').to_i
      },
      customer: {
        customerNumber: customer_number
      },
      recipient: {
        name: recipient_name,
        address: billing_address,
        city: order.dig('billing_address', 'city') || '',
        country: order.dig('billing_address', 'country') || '',
        mobilePhone: order.dig('billing_address', 'phone') || '',
        zip: order.dig('billing_address', 'zip') || '',
        vatZone: {
          vatZoneNumber: config.fetch('vatZoneNumber').to_i
        }
      },
      layout: {
        layoutNumber: config.fetch('layoutNumber').to_i
      },
      delivery: {
        address: shipping_address,
        city: order.dig('shipping_address', 'city')  || '',
        country: order.dig('shipping_address', 'country') || '',
        zip: order.dig('shipping_address', 'zip') || ''
      },
      lines: order_lines,
      notes: {
        heading: order_id
      }
    }
  end

  def date
    @date ||= Time.parse(order['purchased_at']).strftime('%F')
  end

  def recipient_name
    @recipient_name ||= order['amazon_fba'] ? order_id : order.dig('billing_address', 'name')
  end

  def billing_address
    @billing_address ||= \
      if order['amazon_fba']
        order_id
      else
        order.dig('billing_address', 'address1').to_s + ' ' + \
        order.dig('billing_address', 'address2').to_s
      end
  end

  def shipping_address
    @shipping_address ||= \
      if order['amazon_fba']
        order_id
      else
        order.dig('shipping_address', 'address1').to_s + ' ' + \
        order.dig('shipping_address', 'address2').to_s
      end
  end

  def order_id
    @order_id ||= "Amazon: #{order.fetch('order_id')}"
  end

  def order_lines
    @order_lines ||= \
      order.fetch('order_lines', []).map do |order_line|
        product_id = order_line.fetch('product_id')

        product = Economic::V1::Product.new(shop: shop, product_id: product_id, name: order_line.fetch('product_name'))
                                       .find_or_create!

        {
          product: {
            productNumber: product['productNumber']
          },
          quantity: order_line.fetch('quantity'),
          description: product['name'],
          unitNetPrice: order_line_net_price(order_line)
        }
      end
  end

  def order_line_net_price(order_line)
    price = order_line.fetch('cents_with_vat') / 100.0

    unit_price = price / order_line.fetch('quantity')

    (unit_price / "1.#{config.fetch('vatPercentage')}".to_f).round(2)
  end

  def config
    @config ||= shop.fetch 'config'
  end

  def core_api
    @core_api ||= Arctic::Vendor::Collection::API.new
  end

  def api
    @api ||= Economic::V1::API.new shop
  end
end
