# frozen_string_literal: true

# rubocop:disable Layout/AlignHash
# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

class CDON::V1::OrderFormatter
  attr_reader :data, :postage

  def initialize(order)
    @data = order.data
  end

  def format
    {
      id: order_id,
      order_id: data.dig('OrderDetails', 'OrderId'),
      total: data.dig('OrderDetails', 'TotalSalesAmount'),
      currency: data.dig('OrderDetails', 'CurrencyCode'),
      raw_data: data,
      billing_address: billing_address,
      shipping_address: shipping_address,
      order_lines: order_lines,
      invoices: invoices,
      purchased_at: data.dig('OrderDetails', 'CreatedDateUtc'),
      shipping_fee: postage,
    }
  end

  private

    def order_id
      @order_id ||= data.dig('OrderDetails', 'OrderId')
    end

    def invoices
      data.fetch('Invoices', []).collect do |invoice|
        {
          invoice_id: invoice.fetch('InvoiceNumber'),
          order_lines: invoice.fetch('Rows', []).collect { |line| line.fetch('OrderRowId') },
          amount: invoice.fetch('TotalAmount'),
          currency: invoice.fetch('CurrencyCode'),
          status: normalize_status(invoice.fetch('Status')),
        }
      end
    end

    def normalize_status(status)
      case status.to_s.downcase
      when 'awaitingpayment' then 'awaiting_payment'
      when 'pending' then 'created'
      else status.to_s.downcase
      end
    end

    def order_lines_status(status)
      case normalize_status(status)
      when 'delivered' then 'shipped'
      else normalize_status(status)
      end
    end

    def order_lines
      lines = data.dig('OrderDetails', 'OrderRows') || []
      lines = lines.collect do |line|
        {
          line_id: line.fetch('OrderRowId'),
          status: order_lines_status(line.fetch('FulfillmentStatus')),
          product_id: line.fetch('ProductId'),
          quantity: line.fetch('Quantity'),
          track_and_trace_reference: tracking_id(line),
          cents_with_vat: line_price(line),
        }
      end

      # Exclude Postage order lines
      postage_lines = lines.select do |ol|
        ol[:product_id] == 'Postage'
      end
      @postage = postage_lines.collect { |ol| ol[:cents_with_vat] }.map(&:to_i).sum

      lines - postage_lines
    end

    def line_price(line)
      line.fetch('PricePerUnit').to_s.to_f *
        line.fetch('Quantity').to_s.to_f *
        100.0
    end

    def tracking_id(order_line)
      [
        order_line.fetch('PackageCarrierId', nil).to_s.strip.presence,
        order_line.fetch('PackageId', nil).to_s.strip.presence,
      ].compact.join(':').presence
    end

    def shipping_address
      {
        name:     data.dig('OrderDetails', 'CustomerInfo', 'ShippingAddress', 'Name'),
        address1: data.dig('OrderDetails', 'CustomerInfo', 'ShippingAddress', 'StreetAddress'),
        address2: data.dig('OrderDetails', 'CustomerInfo', 'ShippingAddress', 'CoAddress'),
        city:     data.dig('OrderDetails', 'CustomerInfo', 'ShippingAddress', 'City'),
        zip:      data.dig('OrderDetails', 'CustomerInfo', 'ShippingAddress', 'ZipCode'),
        country:  data.dig('OrderDetails', 'CustomerInfo', 'ShippingAddress', 'Country'),
        email:    email,
        phone:    extract_phone,
      }
    end

    def billing_address
      {
        name:     data.dig('OrderDetails', 'CustomerInfo', 'BillingAddress', 'Name'),
        address1: data.dig('OrderDetails', 'CustomerInfo', 'BillingAddress', 'StreetAddress'),
        address2: data.dig('OrderDetails', 'CustomerInfo', 'BillingAddress', 'CoAddress'),
        city:     data.dig('OrderDetails', 'CustomerInfo', 'BillingAddress', 'City'),
        zip:      data.dig('OrderDetails', 'CustomerInfo', 'BillingAddress', 'ZipCode'),
        country:  data.dig('OrderDetails', 'CustomerInfo', 'BillingAddress', 'Country'),
        email:    email,
        phone:    extract_phone,
      }
    end

    def email
      @email ||= data.dig('OrderDetails', 'CustomerInfo', 'EmailAddress').to_s.strip.presence ||
                 "#{order_id}-no-email@example.dk"
    end

    def extract_phone
      data.dig('OrderDetails', 'CustomerInfo', 'Phones', 'PhoneMobile') ||
        data.dig('OrderDetails', 'CustomerInfo', 'Phones', 'PhoneHome') ||
        data.dig('OrderDetails', 'CustomerInfo', 'Phones', 'PhoneWork')
    end
end

# rubocop:enable Layout/AlignHash
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
