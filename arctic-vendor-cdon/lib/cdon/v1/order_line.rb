# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize

class CDON::V1::OrderLine < CDON::V1::API
  Error = Class.new StandardError
  InvalidResponse = Class.new Error
  InvalidOrderState = Class.new Error

  attr_reader :attributes
  attr_reader :order_id

  def initialize(shop, attributes, order_id)
    @shop = shop.as_json
    @order_id = order_id
    @attributes = attributes.as_json
  end

  def deliver!
    raise InvalidOrderState, order['OrderDetails']['State'] unless order['OrderDetails']['State'] == 'Pending'

    body = {
      OrderId: order_id,
      Products: delivered_products,
    }.to_json

    response = connection.post 'api/orderdelivery' do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = body
    end

    msg = <<~MSG
      Unable to mark order line (#{line_id}) for order #{order_id} as delivered.
      Response body is: #{response.body}
    MSG
    raise InvalidResponse, msg unless response.success?

    true
  end

  def method_missing(name, *args)
    return attributes[name.to_s] if respond_to_missing? name

    super name, *args
  end

  def respond_to_missing?(name, include_private = false)
    return true if attributes.key? name.to_s

    super name, include_private
  end

  private

    def order
      @order ||= JSON.parse connection.get("api/order/#{order_id}").body
    end

    # Retrieve original order lines, then only set track_and_trace_reference for
    # this one.
    # We need to retrieve the original order, and use it's order lines because
    # we need to send the exact, matching OrderRows JSON object that we
    # originally received from the CDON API. And we don't store the original one
    # in the Core API because we move the postage to the shipping_fee order
    # attribute.
    def delivered_products
      @delivered_products ||= begin
        products = order['OrderDetails']['OrderRows']
        products.each do |ol|
          if ol['OrderRowId'].to_s == line_id.to_s
            ol['QuantityToDeliver'] = quantity
            ol['PackageId'] = track_and_trace_reference
          end

          if ol['ProductId'] == 'Postage'
            ol['QuantityToDeliver'] = 1
            ol['PackageId'] = track_and_trace_reference
          end
        end
        products.collect do |pr|
          pr.slice 'OrderRowId', 'QuantityToDeliver', 'PackageId'
        end
      end
    end
end

# rubocop:enable Metrics/AbcSize
