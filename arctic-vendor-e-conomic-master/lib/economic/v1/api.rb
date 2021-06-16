class Economic::V1::API
  class InvalidResponse < StandardError
    attr_reader :status

    def initialize(response)
      @status = response.status

      super(response.body)
    end
  end

  attr_reader :shop

  def initialize(shop)
    @shop = shop.as_json
  end

  def auth_config
    @auth_config ||= shop.fetch('auth_config').as_json
  end

  def find_customer(email:)
    response = make_request :get, '/customers', filter: "email$eq:#{email}"

    response['collection'].first
  end

  def create_customer(data)
    make_request :post, '/customers', body: data
  end

  def find_product(product_id:, product_group_number:)
    response = make_request :get, '/products',
      filter: "productNumber$eq:#{product_id}$and:productGroup.productGroupNumber$eq:#{product_group_number}"

    response['collection'].first
  end

  def create_product(data)
    make_request :post, '/products', body: data
  end

  def create_order(order)
    make_request :post, '/invoices/drafts', body: order
  end

  def update_order(order:, order_id:)
    existing_data = find_order(order_id)

    data = existing_data.merge! order.deep_stringify_keys

    make_request :put, "/invoices/drafts/#{order_id}", body: data
  end

  def find_order(id)
    make_request :get, "/invoices/drafts/#{id}"
  end

  private
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
      end

      raise InvalidResponse, response unless response.success?

      JSON.parse response.body
    end

    def connection
      @connection = \
        Faraday.new(ENV.fetch('BASE_URL')) do |connection|
          connection.request  :url_encoded
          connection.response :detailed_logger, Arctic.logger
          connection.headers = {
            'Content-Type' => 'application/json', 'Accept' => 'application/json',
            'X-AppSecretToken' => ENV.fetch('APP_SECRET_TOKEN'),
            'X-AgreementGrantToken' => auth_config['agreement_grant_token']
          }
          connection.adapter Faraday.default_adapter
        end
    end
end
