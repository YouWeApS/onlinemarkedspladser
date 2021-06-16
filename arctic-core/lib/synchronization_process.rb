require 'faraday/detailed_logger'

class SynchronizationProcess
  attr_reader :vendor, :shop

  def initialize(vendor, shop)
    @vendor = vendor
    @shop = shop
  end

  def send
    Rails.logger.info "Disperse products for vendor #{vendor.id}"
    json = JSON.parse response.body
    @errors = json.deep_symbolize_keys
  rescue Faraday::ConnectionFailed, JSON::ParserError => e
    Rails.logger.fatal "Unable to reach Vendor(#{vendor.id}) (#{e.class}): #{e.message}"
    @errors = {
        no_connection: 'Could not reach the vendor',
    }
  end

private

  def response
    options = {
        shop: shop,
        vendor: vendor,
        channel: vendor.channel,
    }
    shop_json = V1::Vendors::ShopBlueprint.render_as_hash shop, options

    @response ||= begin

      connection.post do |req|
        req.body = {
            options: {
                shop: shop_json,
            },
        }.to_json
      end
    end
  end

  def connection
    @connection ||= Faraday.new(url: faraday_url(vendor.validation_url), **faraday_options) do |faraday|
      faraday.request :url_encoded
      faraday.response :detailed_logger, logger, 'Push products to Dispersal Vendor' if ENV.fetch('LOG_LEVEL', '') == 'debug'
      faraday.adapter Faraday.default_adapter
    end
  end

  def faraday_options
    @faraday_options ||= {
        headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'Authorization' => Faraday::Request::BasicAuthentication.header(vendor.id, vendor.token),
        },
    }
  end

  def faraday_url(url)
    url.gsub("validate","disperse")
  end
end