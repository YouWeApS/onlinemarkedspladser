class Dandomain::V2::API
  Error = Class.new StandardError
  InvalidResponse = Class.new Error
  TooManyPages = Class.new Error

  attr_reader :shop

  def initialize(shop)
    @shop = shop.as_json
  end

  def config
    @config ||= shop.fetch('config').as_json
  end

  def auth_config
    @auth_config ||= shop.fetch('auth_config').as_json
  end

  def products(modifiedStartDate: nil, limit: 100, offset: 0, &block)
    endpoint = "sites/#{site_id}/products"

    fetch_paginated(endpoint, modifiedStartDate: modifiedStartDate) do |product|
      begin
        product_details = product product['productNumber']
        yield product_details
      rescue => e
        Arctic.logger.error "Failed to retrieve details about #{product['productNumber']}"
        yield nil
      end
    end
  end

  def update_product(product_id, data, encode = false)
    endpoint = encode ? encode(product_id) : product_id
    make_request :patch, "products/#{endpoint}", body: data
  end

  def update_order_billing_address(order_id, address)
    make_request :patch, "orders/#{order_id}/customeraddress", body: address
  end

  def update_order_delivery_address(order_id, address)
    make_request :patch, "orders/#{order_id}/deliveryaddress", body: address
  end

  def lookup_order(id)
    make_request :get, "orders/#{id}"
  end

  def lookup_country_attribute(country_code, shipment_id, field = :id)
    fetch_paginated "sites/#{site_id}/shipping-methods/#{shipment_id}/countries" do |country|
      if country.dig('code') == country_code
        Arctic.logger.info "Found country: #{country}"
        return country[field.to_s]
      end
    end
  end

  def lookup_customer(email: nil)
    options = { email: email }
    fetch_items 'customers', options
  end

  def create_customer(data)
    make_request :post, 'customers', body: data
  end

  def update_customer(customer)
    make_request :put, "customers/#{customer.id}", body: customer.as_json
  end

  def create_product(*)
    raise NotImplementedError, "we don't support creating products on the Dandomain platform"
  end

  def orders(startLastModified: nil, &block)
    fetch_paginated("orders", startLastModified: startLastModified) do |order|
      begin
        yield order
      rescue => e
        Arctic.logger.error "Failed to retrieve details about order #{order['id']}"
        yield nil
      end
    end
  end

  def create_order(order)
    make_request :post, 'orders', body: order.as_json.except('id')
  end

  def complete_order(order_id)
    make_request :put, "orders/#{order_id}/complete"
  end

  def update_order(order)
    id = order['id']
    make_request :patch, "orders/#{id}", body: order
  end

  def update_order_state(order)
    update_order(order)
  end

  # Fetch all variants and variant groups
  # http://bit.ly/2LBLYoO
  def variantgroups
    @variantgroups ||= begin
      [].tap do |arr|
        fetch_paginated("variantgroups", include: :variants) do |group|
          arr << group if group['siteId'].to_s == site_id.to_s
        end
      end
    end
  end

  def lookup_product(sku_or_ean, encode = false)
    endpoint = encode ? encode(sku_or_ean) : sku_or_ean
    make_request :get, "products/#{endpoint}"
  rescue InvalidResponse
    data = make_request :get, "products", barcode: sku_or_ean
    data['items'].first
  end

  private

    # Look up the specific product
    def product(id, **options)
      id = CGI.escape id

      options.reverse_merge! \
        include: 'description,customfields,manufacturers,categories,media,prices,variants'

      details = make_request :get, "sites/#{site_id}/products/#{id}", options

      details['variantgroups'] = {
        items: variantgroups
      }.as_json

      Dandomain::V2::Format.new(shop, details).as_json
    end

    def site_id
      @site_id ||= config.fetch 'site_id'
    end

    def fetch_paginated(endpoint, **options)
      no_more = false
      loops = 0

      options.reverse_merge! \
        offset: 0

      until no_more
        loops += 1
        raise TooManyPages, "cannot handle more than 1000 pages" if loops > 1000

        items, has_more = fetch_items(endpoint, **options)

        items.each { |item| yield item }

        if has_more
          options[:offset] += 100
        else
          no_more = true
        end
      end
    end

    def fetch_items(endpoint, **options)
      options.reverse_merge! \
        offset: 0,
        limit: 100,
        notHidden: true

      json = make_request :get, endpoint, options

      [
        json.fetch('items'),
        json.fetch('hasMore'),
      ]
    end

    def encode(text)
      URI.encode(text).sub! '/', '%2F'
    end

    def make_request(method, endpoint, **options)
      Arctic.logger.info "#{method.to_s.upcase} #{endpoint}: #{options[:body].to_json}"
      response = connection.public_send(method, endpoint) do |req|
        options.each do |k, v|
          if k.to_s == 'body'
            req.body = v.to_json if v.present?
          else
            req.params[k] = v if v.present?
          end
        end

        req.headers['Content-Type'] = 'application/json' if %w[put patch post].include? method.to_s
      end

      raise InvalidResponse, response.body unless response.success?

      JSON.parse response.body
    end

    def connection
      @connection ||= begin
        url = "#{config.fetch('host')}/admin/WEBAPI/v2"

        c = Faraday.new(url) do |f|
          f.request  :url_encoded
          f.response :detailed_logger, Arctic.logger
          f.adapter Faraday.default_adapter
        end

        c.basic_auth('', auth_config.fetch('api_key'))

        c
      end
    end
end
