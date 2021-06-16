# frozen_string_literal: true

require 'faraday/detailed_logger'

class ProductValidator
  attr_reader :product, :options, :json, :errors

  def initialize(product, **options)
    @options = options
    # try to fix images load
    product.images.where(position: 1).take
    @product = ProductMerger.new(product, **options).result
    @json = V1::Vendors::ProductBlueprint.render_as_hash @product, **options
    @errors = {}
  end

  def valid?
    if vendor.validation_url.blank?
      Rails.logger.warn "Vendor(#{vendor.id}) validation_url is blank. Failing product match!"
      @errors[:validation_url] = 'Validation url is missing from the vendor'
      return false
    end

    validate_match

    errors.empty?
  end

  private

    def validate_match
      Rails.logger.info "Validating #{product.id}"
      json = JSON.parse response.body
      @errors = json.deep_symbolize_keys
    rescue Faraday::ConnectionFailed, JSON::ParserError => e
      Rails.logger.fatal "Unable to reach Vendor(#{vendor.id}) (#{e.class}): #{e.message}"
      @errors = {
        no_connection: 'Could not reach the vendor',
      }
    end

    def connection
      @connection ||= Faraday.new(url: vendor.validation_url, **faraday_options) do |faraday|
        faraday.request :url_encoded
        faraday.response :detailed_logger, logger, 'Product Validator' if ENV.fetch('LOG_LEVEL', '') == 'debug'
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

    def vendor
      @vendor ||= options[:vendor] || :missing_vendor
    end

    def response
      @response ||= begin
        shop_json = V1::Vendors::ShopBlueprint.render_as_hash product.shop, options

        connection.post do |req|
          req.body = {
            product: json,
            options: {
              shop: shop_json,
            },
          }.to_json
        end
      end
    end
end
