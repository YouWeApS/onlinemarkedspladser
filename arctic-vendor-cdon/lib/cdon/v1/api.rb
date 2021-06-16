# frozen_string_literal: true

class CDON::V1::API
  attr_reader :shop

  private

    def connection
      @connection ||= Faraday.new(connection_options)
    end

    def connection_options
      {
        url: url,
        headers: {
          'Authorization': "api #{api_key}",
        },
      }
    end

    def api_key
      @api_key ||= shop.fetch('auth_config').fetch('api_key')
    end

    def url
      ENV.fetch('MARKETPLACE_URL', 'https://integration-admin.marketplace.cdon.com')
    end

    def core_api
      @core_api ||= Arctic::Vendor::Dispersal::API.new
    end
end
